import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../core/navigation/app_navigation.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/transfer/capsule_transfer_service.dart';
import '../../core/transfer/nearby_transport.dart';
import '../../l10n/l10n.dart';
import '../capsules/domain/capsule_models.dart';

enum _Phase {
  idle,
  discovering,
  waiting,
  connecting,
  pairing,
  preparing,
  awaitingOffer,
  awaitingAccept,
  sending,
  receiving,
  importing,
  awaitingSave,
  sent,
  saved,
  error,
}

class NearbyTransferScreen extends ConsumerStatefulWidget {
  const NearbyTransferScreen({super.key, this.capsuleId});
  final String? capsuleId;

  @override
  ConsumerState<NearbyTransferScreen> createState() =>
      _NearbyTransferScreenState();
}

class _NearbyTransferScreenState extends ConsumerState<NearbyTransferScreen> {
  final _transport = NearbyTransport();
  final _name = TextEditingController(
    text: 'Cápsula-${const Uuid().v4().substring(0, 4)}',
  );
  final _peers = <String, String>{};
  StreamSubscription<Map<String, dynamic>>? _subscription;
  Timer? _timeout;
  DialogRoute<bool>? _dialog;
  PreparedCapsuleTransfer? _prepared;
  CapsuleTransferOffer? _offer;
  String? _selectedId;
  String? _savedId;
  String? _errorCode;
  bool _receiver = false;
  bool _notificationWarning = false;
  double? _progress;
  int _session = 0;
  _Phase _phase = _Phase.idle;

  bool get _finished =>
      _phase == _Phase.sent || _phase == _Phase.saved || _phase == _Phase.error;
  bool _active(int session) => mounted && session == _session && !_finished;
  void _check(int session) {
    if (!_active(session)) throw TransferCancelled();
  }

  void _set(_Phase phase) {
    if (mounted) {
      setState(() {
        _phase = phase;
        _progress = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedId = widget.capsuleId;
  }

  @override
  void dispose() {
    _session++;
    _timeout?.cancel();
    _subscription?.cancel();
    unawaited(_cleanup());
    _name.dispose();
    super.dispose();
  }

  Future<void> _cleanup() async {
    try {
      await _transport.stop();
    } catch (_) {
      /* May already be detached. */
    }
    final prepared = _prepared;
    _prepared = null;
    try {
      await prepared?.dispose();
    } catch (_) {
      /* Encrypted temporary copy only. */
    }
  }

  Future<void> _start(bool receive) async {
    if (_phase != _Phase.idle) return;
    FocusScope.of(context).unfocus();
    _receiver = receive;
    final session = ++_session;
    _set(receive ? _Phase.waiting : _Phase.discovering);
    _subscription = _transport.events.listen(
      (event) => unawaited(
        _event(
          event,
          session,
        ).catchError((Object error) => _fail(error, session)),
      ),
      onError: (Object error) => unawaited(_fail(error, session)),
    );
    _deadline(session, const Duration(minutes: 3));
    try {
      await _transport.start(
        receive: receive,
        name: _name.text.trim().isEmpty ? 'Cápsula' : _name.text.trim(),
      );
    } catch (error) {
      await _fail(error, session);
    }
  }

  void _deadline(int session, Duration duration) {
    _timeout?.cancel();
    _timeout = Timer(
      duration,
      () => unawaited(_fail(StateError('TIMEOUT'), session)),
    );
  }

  Future<bool> _confirm(
    Widget title,
    Widget content,
    String acceptLabel,
  ) async {
    final route = DialogRoute<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: title,
        content: SingleChildScrollView(child: content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(acceptLabel),
          ),
        ],
      ),
    );
    _dialog = route;
    final answer = await Navigator.of(context, rootNavigator: true).push(route);
    if (_dialog == route) _dialog = null;
    return answer == true;
  }

  Future<void> _event(Map<String, dynamic> event, int session) async {
    // A delivered private cache file must be released even if the screen closed.
    if (event['type'] == 'received') {
      final path = event['path'] as String;
      try {
        if (_active(session) && _receiver && _phase == _Phase.receiving) {
          await _import(path, session);
        }
      } finally {
        try {
          await _transport.release(path);
        } catch (_) {
          /* Private encrypted cache. */
        }
      }
      return;
    }
    if (!_active(session)) return;
    switch (event['type']) {
      case 'found':
        if (_phase == _Phase.discovering) {
          setState(
            () => _peers[event['id'] as String] = event['name'] as String,
          );
        }
      case 'lost':
        if (_phase == _Phase.discovering) {
          setState(() => _peers.remove(event['id']));
        }
      case 'pairing':
        if (_phase != _Phase.connecting && _phase != _Phase.waiting) return;
        _set(_Phase.pairing);
        final code = event['code'] as String?;
        if (code == null || code.isEmpty) {
          throw const FormatException('Missing authentication code.');
        }
        final accepted = await _confirm(
          Text(context.l10n.nearbyPairing),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(event['name'] as String, textAlign: TextAlign.center),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  code,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge?.copyWith(letterSpacing: 6),
                ),
              ),
              Text(context.l10n.nearbyCodeHint),
            ],
          ),
          context.l10n.nearbyConfirm,
        );
        _check(session);
        if (!accepted) {
          await _transport.reject();
          throw StateError('DECLINED');
        }
        _set(_Phase.connecting);
        await _transport.accept();
      case 'connected':
        if (_phase != _Phase.connecting) return;
        _deadline(session, const Duration(minutes: 30));
        if (_receiver) {
          _set(_Phase.awaitingOffer);
        } else {
          await _prepare(session);
        }
      case 'message':
        await _message(
          jsonDecode(event['message'] as String) as Map<String, dynamic>,
          session,
        );
      case 'progress':
        if (_phase == _Phase.sending || _phase == _Phase.receiving) {
          final total = (event['total'] as num).toDouble();
          if (total > 0) {
            setState(
              () =>
                  _progress = ((event['bytes'] as num) / total).clamp(0.0, 1.0),
            );
          }
        }
      case 'sent':
        if (!_receiver && _phase == _Phase.sending) _set(_Phase.awaitingSave);
      case 'disconnected':
        // A fully received file can still be verified and saved after disconnect.
        if (_phase != _Phase.importing) throw StateError('DISCONNECTED');
      case 'error':
        if (_phase != _Phase.importing) {
          throw StateError(event['code'] as String? ?? 'TRANSFER');
        }
    }
  }

  CapsuleTransferService _service() => CapsuleTransferService(
    repository: ref.read(capsuleRepositoryProvider),
    encryption: ref.read(encryptionProvider),
  );

  Future<void> _prepare(int session) async {
    _set(_Phase.preparing);
    final service = _service();
    final key = await ref.read(keyServiceProvider).getOrCreateMasterKey();
    final temporary = await getTemporaryDirectory();
    _check(session);
    final prepared = await service.prepare(
      capsuleId: _selectedId!,
      localKey: key,
      temporaryRoot: temporary,
      checkCancelled: () => _check(session),
    );
    if (!_active(session)) {
      await prepared.dispose();
      return;
    }
    _prepared = prepared;
    _offer = prepared.offer;
    _set(_Phase.awaitingAccept);
    await _transport.message(prepared.offer.toJson());
  }

  Future<void> _message(Map<String, dynamic> message, int session) async {
    switch (message['type']) {
      case 'offer':
        if (!_receiver || _phase != _Phase.awaitingOffer || _offer != null) {
          return;
        }
        final offer = CapsuleTransferOffer.fromJson(message);
        _offer = offer;
        _set(_Phase.awaitingAccept);
        final date = DateFormat.yMMMMd(
          Localizations.localeOf(context).toString(),
        ).add_Hm().format(offer.unlockAt.toLocal());
        final accepted = await _confirm(
          Text(context.l10n.nearbyAcceptTitle),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(offer.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text('${(offer.size / (1024 * 1024)).toStringAsFixed(1)} MB'),
              Text(context.l10n.unlockOn(date)),
              const SizedBox(height: 16),
              Text(context.l10n.nearbyAcceptHint),
            ],
          ),
          context.l10n.nearbyReceive,
        );
        _check(session);
        if (!accepted) {
          await _transport.message({
            'type': 'declined',
            'transferId': offer.transferId,
          });
          throw StateError('DECLINED');
        }
        await _transport.receiveStream(offer.size);
        _check(session);
        _set(_Phase.receiving);
        await _transport.message({
          'type': 'ready',
          'transferId': offer.transferId,
        });
      case 'ready':
        if (_receiver ||
            _phase != _Phase.awaitingAccept ||
            message['transferId'] != _offer?.transferId) {
          return;
        }
        _set(_Phase.sending);
        await _transport.sendStream(_prepared!.file.path);
      case 'saved':
        if (_receiver ||
            (_phase != _Phase.sending && _phase != _Phase.awaitingSave) ||
            message['transferId'] != _offer?.transferId) {
          return;
        }
        _timeout?.cancel();
        _set(_Phase.sent);
        await _cleanup();
      case 'declined':
        if (message['transferId'] == _offer?.transferId) {
          throw StateError('DECLINED');
        }
      case 'failed':
        if (message['transferId'] == _offer?.transferId) {
          throw StateError(
            message['code'] == 'CAPSULE_ALREADY_EXISTS'
                ? 'CAPSULE_ALREADY_EXISTS'
                : 'TRANSFER',
          );
        }
      default:
        throw const FormatException('Invalid protocol message.');
    }
  }

  Future<void> _import(String path, int session) async {
    _set(_Phase.importing);
    final service = _service();
    final keys = ref.read(keyServiceProvider);
    final storage = ref.read(storageProvider);
    final notifications = ref.read(notificationProvider);
    final preferences = ref.read(appPreferencesProvider).value;
    try {
      final key = await keys.getOrCreateMasterKey();
      final vault = await storage.vaultDirectory;
      final temporary = await getTemporaryDirectory();
      _check(session);
      final capsule = await service.receive(
        package: File(path),
        offer: _offer!,
        localKey: key,
        vault: vault,
        temporaryRoot: temporary,
        checkCancelled: () => _check(session),
      );
      // Import is committed: a notification/ack failure must never undo the capsule.
      _savedId = capsule.id;
      if (_active(session)) {
        _timeout?.cancel();
        _set(_Phase.saved);
        ref.invalidate(capsuleProvider(capsule.id));
        ref.invalidate(capsulesProvider);
        try {
          await _transport.message({
            'type': 'saved',
            'transferId': _offer!.transferId,
          });
        } catch (_) {
          /* Saved locally; sender may have disconnected. */
        }
      }
      try {
        await notifications.scheduleCapsule(
          capsule,
          NotificationPreferences(
            opening: preferences.openingNotifications,
            dayBefore: preferences.dayReminder,
            weekBefore: preferences.weekReminder,
          ),
        );
      } catch (_) {
        if (mounted) setState(() => _notificationWarning = true);
      }
    } catch (error) {
      if (_active(session)) {
        try {
          await _transport.message({
            'type': 'failed',
            'transferId': _offer?.transferId,
            'code': _code(error),
          });
        } catch (_) {
          /* Connection may be lost. */
        }
      }
      rethrow;
    }
  }

  String _code(Object error) => error is PlatformException
      ? error.code
      : error is StateError
      ? error.message
      : 'TRANSFER';

  Future<void> _fail(Object error, int session) async {
    if (!_active(session) || error is TransferCancelled) return;
    _errorCode = _code(error);
    _timeout?.cancel();
    final dialog = _dialog;
    if (dialog != null && dialog.isActive) {
      dialog.navigator?.removeRoute(dialog, false);
    }
    _set(_Phase.error);
    await _cleanup();
  }

  String get _status {
    final s = context.l10n;
    return switch (_phase) {
      _Phase.idle => s.nearbyIntro,
      _Phase.discovering => s.nearbyDiscovering,
      _Phase.waiting => s.nearbyWaiting,
      _Phase.connecting => s.nearbyConnecting,
      _Phase.pairing => s.nearbyPairing,
      _Phase.preparing => s.nearbyPreparing,
      _Phase.awaitingOffer => s.nearbyAwaitingOffer,
      _Phase.awaitingAccept => s.nearbyAwaitingAccept,
      _Phase.sending => s.nearbySending,
      _Phase.receiving => s.nearbyReceiving,
      _Phase.importing => s.nearbyImporting,
      _Phase.awaitingSave => s.nearbyAwaitingSave,
      _Phase.sent => s.nearbySent,
      _Phase.saved => s.nearbySaved,
      _Phase.error => switch (_errorCode) {
        'PERMISSION' => s.nearbyPermission,
        'PLAY_SERVICES' => s.nearbyPlayServices,
        'SPACE' => s.nearbySpace,
        'TRANSFER_TOO_LARGE' => s.nearbyTooLarge,
        'CAPSULE_ALREADY_EXISTS' => s.nearbyDuplicate,
        'DECLINED' => s.nearbyDeclined,
        'DISCONNECTED' => s.nearbyDisconnected,
        'TIMEOUT' => s.nearbyTimeout,
        _ => s.nearbyError,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = context.l10n;
    final capsules = ref.watch(capsulesProvider);
    final available = (capsules.valueOrNull ?? <Capsule>[])
        .where(
          (c) =>
              c.persistedStatus != CapsuleStatus.draft &&
              c.persistedStatus != CapsuleStatus.trashed &&
              c.sealedAt != null,
        )
        .toList();
    final selected = available.any((c) => c.id == _selectedId)
        ? _selectedId
        : null;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/capsules'),
        title: Text(s.nearbyTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Icon(
              _phase == _Phase.saved || _phase == _Phase.sent
                  ? Icons.check_circle_outline_rounded
                  : Icons.wifi_tethering_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            if (!NearbyTransport.supported) ...[
              Text(s.nearbyUnsupported),
            ] else if (_phase == _Phase.idle) ...[
              Text(s.nearbyIntro),
              const SizedBox(height: 16),
              Text(s.nearbyPrivacy),
              const SizedBox(height: 24),
              TextField(
                controller: _name,
                maxLength: 40,
                decoration: InputDecoration(labelText: s.nearbyName),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _start(true),
                icon: const Icon(Icons.download_rounded),
                label: Text(s.nearbyReceive),
              ),
              const SizedBox(height: 24),
              if (capsules.isLoading)
                const LinearProgressIndicator()
              else if (available.isEmpty)
                Text(s.nearbyEmpty)
              else ...[
                DropdownButtonFormField<String>(
                  initialValue: selected,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: s.nearbyChoose),
                  items: [
                    for (final capsule in available)
                      DropdownMenuItem(
                        value: capsule.id,
                        child: Text(
                          capsule.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _selectedId = value),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: selected == null ? null : () => _start(false),
                  icon: const Icon(Icons.near_me_outlined),
                  label: Text(s.nearbySend),
                ),
              ],
            ] else ...[
              Text(
                _status,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (!_finished) ...[
                const SizedBox(height: 24),
                LinearProgressIndicator(value: _progress),
                if (_progress != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${(_progress! * 100).round()} %',
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                Text(s.nearbyKeepOpen),
              ],
              if (_phase == _Phase.discovering) ...[
                for (final peer in _peers.entries)
                  ListTile(
                    leading: const Icon(Icons.phone_android_rounded),
                    title: Text(peer.value),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final session = _session;
                      _set(_Phase.connecting);
                      try {
                        await _transport.request(peer.key);
                      } catch (error) {
                        await _fail(error, session);
                      }
                    },
                  ),
              ],
              if (_notificationWarning)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(s.nearbyNotificationWarning),
                ),
              const SizedBox(height: 24),
              if (_savedId != null)
                FilledButton(
                  onPressed: () => context.go('/capsule/$_savedId'),
                  child: Text(s.myCapsules),
                )
              else if (_finished)
                FilledButton(
                  onPressed: () => popOrGo(context, '/capsules'),
                  child: Text(s.nearbyBack),
                )
              else
                OutlinedButton(
                  onPressed: () => popOrGo(context, '/capsules'),
                  child: Text(s.cancel),
                ),
            ],
            if (_phase == _Phase.idle) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () => context.push('/settings/backups'),
                icon: const Icon(Icons.ios_share_rounded),
                label: Text(s.nearbyExport),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
