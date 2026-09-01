import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../app/theme/app_theme.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/navigation/app_navigation.dart';
import '../../core/storage/custom_cover_id.dart';
import '../../core/tutorial/tutorial_helper.dart';
import '../../core/widgets/capsule_cover.dart';
import '../../l10n/l10n.dart';
import '../capsules/domain/capsule_models.dart';
import '../capsules/domain/unlock_policy.dart';
import '../categories/category_localization.dart';

class CreationScreen extends ConsumerStatefulWidget {
  const CreationScreen({
    super.key,
    this.quickType,
    this.quickDays,
    this.pickDateOnStart = false,
    this.tutorial = false,
  });
  final CapsuleItemType? quickType;
  final int? quickDays;
  final bool pickDateOnStart;
  final bool tutorial;

  @override
  ConsumerState<CreationScreen> createState() => _CreationScreenState();
}

class _CreationScreenState extends ConsumerState<CreationScreen> {
  final _pageController = PageController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customCategoryController = TextEditingController();
  final _textTutorialKey = GlobalKey();
  final _categoryTutorialKey = GlobalKey();
  final _coversTutorialKey = GlobalKey();
  final _quickDatesTutorialKey = GlobalKey();
  final _dateTutorialKey = GlobalKey();
  final _timeTutorialKey = GlobalKey();
  final _sealTutorialKey = GlobalKey();
  final _picker = ImagePicker();
  final _uuid = const Uuid();
  final List<CapsuleItem> _items = [];
  Capsule? _draft;
  int _step = 0;
  bool _busy = false;
  String _categoryId = 'personal';
  String _coverId = 'cover_01';
  late DateTime _unlockAt;
  bool _includesTime = false;
  bool _tutorialShowing = false;
  Timer? _tutorialTimer;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _unlockAt =
        widget.quickDays == null
            ? DateTime(now.year + 1, now.month, now.day)
            : DateTime(
              now.year,
              now.month,
              now.day,
            ).add(Duration(days: widget.quickDays!));
    _initializeDraft();
  }

  Future<void> _initializeDraft() async {
    final draft = await ref
        .read(capsuleRepositoryProvider)
        .createDraft(unlockAt: _unlockAt);
    if (!mounted) return;
    setState(() => _draft = draft);
    if (widget.tutorial) {
      _titleController.text = 'Prueba de cápsula';
      await _storeTextItem(
        title: 'Prueba de cápsula',
        body: 'Prueba de cápsula',
      );
      if (mounted) _scheduleTutorialStep();
    } else if (widget.quickType != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _addType(widget.quickType!),
      );
    } else if (widget.pickDateOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pickDate());
    }
  }

  @override
  void dispose() {
    _tutorialTimer?.cancel();
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              _step == 0 ? Icons.close_rounded : Icons.arrow_back_rounded,
            ),
            onPressed: _handleBack,
          ),
          title: Text(context.l10n.createCapsule),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: (_step + 1) / 4,
              minHeight: 3,
              backgroundColor: AppColors.line,
            ),
          ),
        ),
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _contentStep(),
                _nameStep(),
                _dateStep(),
                _reviewStep(),
              ],
            ),
            if (_busy)
              ColoredBox(
                color: AppColors.cream.withValues(alpha: .88),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 18),
                      Text(context.l10n.working),
                    ],
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: FilledButton(
              key: widget.tutorial ? _sealTutorialKey : null,
              onPressed: _busy ? null : (_step == 3 ? _confirmSeal : _nextStep),
              child: Text(
                _step == 3 ? context.l10n.sealCapsule : context.l10n.next,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heading(String title, String subtitle) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: emotionalTitle(context, size: 34)),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryInk),
        ),
      ],
    ),
  );

  Widget _contentStep() {
    final actions = [
      (
        CapsuleItemType.image,
        context.l10n.addPhoto,
        Icons.photo_outlined,
        AppColors.paleRose,
      ),
      (
        CapsuleItemType.video,
        context.l10n.addVideo,
        Icons.videocam_outlined,
        AppColors.paleSage,
      ),
      (
        CapsuleItemType.audio,
        context.l10n.addAudio,
        Icons.mic_none_rounded,
        const Color(0xFFE8DAC8),
      ),
      (
        CapsuleItemType.text,
        context.l10n.addText,
        Icons.description_outlined,
        AppColors.lavender,
      ),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      children: [
        _heading(context.l10n.whatToSave, context.l10n.addContent),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final action in actions)
              _AddTile(
                key:
                    widget.tutorial && action.$1 == CapsuleItemType.text
                        ? _textTutorialKey
                        : null,
                label: action.$2,
                icon: action.$3,
                color: action.$4,
                onTap: () => _addType(action.$1),
              ),
          ],
        ),
        const SizedBox(height: 26),
        for (final item in _items)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: _itemPreview(item),
              title: Text(_typeLabel(item.type)),
              subtitle: Text(context.l10n.itemsCount(1)),
              trailing: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => _removeItem(item),
              ),
            ),
          ),
      ],
    );
  }

  Widget _nameStep() {
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? const <CapsuleCategory>[];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      children: [
        _heading(context.l10n.nameStep, context.l10n.futureSelfBody),
        TextField(
          controller: _titleController,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: context.l10n.title),
          maxLength: 80,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: context.l10n.descriptionOptional,
          ),
          maxLines: 3,
          maxLength: 240,
        ),
        const SizedBox(height: 12),
        KeyedSubtree(
          key: widget.tutorial ? _categoryTutorialKey : null,
          child: DropdownButtonFormField<String>(
            initialValue:
                categories.any((c) => c.id == _categoryId) ? _categoryId : null,
            decoration: InputDecoration(labelText: context.l10n.category),
            items: [
              for (final category in categories)
                DropdownMenuItem(
                  value: category.id,
                  child: Text(categoryLabel(context, category)),
                ),
            ],
            onChanged:
                (value) => setState(() => _categoryId = value ?? 'personal'),
          ),
        ),
        if (_categoryId == 'other') ...[
          const SizedBox(height: 12),
          TextField(
            controller: _customCategoryController,
            textCapitalization: TextCapitalization.words,
            maxLength: 40,
            decoration: InputDecoration(
              labelText: context.l10n.customCategoryName,
              prefixIcon: const Icon(Icons.edit_outlined),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          context.l10n.cover,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: capsuleCoverIds.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisExtent: 94,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            if (index == 0) return _customCoverTile();
            final id = capsuleCoverIds[index - 1];
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _busy ? null : () => unawaited(_selectBuiltInCover(id)),
              child: Stack(
                children: [
                  CapsuleCover(coverId: id, height: 94),
                  if (_coverId == id)
                    const Positioned(
                      right: 6,
                      top: 6,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.dustyRose,
                        child: Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _customCoverTile() {
    final selected = isCustomCoverId(_coverId);
    return InkWell(
      key: widget.tutorial ? _coversTutorialKey : null,
      borderRadius: BorderRadius.circular(20),
      onTap: _busy ? null : _pickCustomCover,
      child: Stack(
        children: [
          if (selected)
            CapsuleCover(coverId: _coverId, height: 94)
          else
            Container(
              height: 94,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.paleRose,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.dustyRose),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppColors.dustyRose,
                    size: 29,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    context.l10n.customCover,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          if (selected)
            const Positioned(
              right: 6,
              top: 6,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.dustyRose,
                child: Icon(Icons.check_rounded, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dateStep() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
    children: [
      _heading(context.l10n.whenStep, context.l10n.chooseWhenBody),
      Wrap(
        key: widget.tutorial ? _quickDatesTutorialKey : null,
        spacing: 9,
        runSpacing: 9,
        children: [
          ActionChip(
            label: Text(context.l10n.quickOneMonth),
            onPressed: () => _quickDate(months: 1),
          ),
          ActionChip(
            label: Text(context.l10n.quickSixMonths),
            onPressed: () => _quickDate(months: 6),
          ),
          ActionChip(
            label: Text(context.l10n.quickOneYear),
            onPressed: () => _quickDate(years: 1),
          ),
          ActionChip(
            label: Text(context.l10n.quickFiveYears),
            onPressed: () => _quickDate(years: 5),
          ),
        ],
      ),
      const SizedBox(height: 22),
      Card(
        key: widget.tutorial ? _dateTutorialKey : null,
        child: ListTile(
          contentPadding: const EdgeInsets.all(18),
          leading: const Icon(Icons.calendar_month_outlined, size: 30),
          title: Text(
            DateFormat.yMMMMd(
              Localizations.localeOf(context).toString(),
            ).format(_unlockAt),
          ),
          subtitle:
              _includesTime ? Text(DateFormat.Hm().format(_unlockAt)) : null,
          trailing: const Icon(Icons.edit_outlined),
          onTap: _pickDate,
        ),
      ),
      const SizedBox(height: 14),
      SwitchListTile(
        key: widget.tutorial ? _timeTutorialKey : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        title: Text(context.l10n.includeExactTime),
        value: _includesTime,
        onChanged: (value) async {
          setState(() => _includesTime = value);
          if (value) await _pickTime();
          if (!value) {
            setState(
              () =>
                  _unlockAt = normalizeUnlockDate(
                    _unlockAt,
                    includesTime: false,
                  ),
            );
          }
        },
      ),
    ],
  );

  Widget _reviewStep() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
    children: [
      _heading(context.l10n.reviewStep, context.l10n.sealWarning),
      CapsuleCover(coverId: _coverId, height: 180, showLock: true),
      const SizedBox(height: 24),
      Text(_titleController.text, style: emotionalTitle(context, size: 34)),
      const SizedBox(height: 16),
      _ReviewRow(
        icon: Icons.collections_bookmark_outlined,
        label: context.l10n.itemsCount(_items.length),
      ),
      _ReviewRow(icon: Icons.folder_outlined, label: _selectedCategoryLabel()),
      _ReviewRow(
        icon: Icons.event_outlined,
        label: DateFormat.yMMMMd(
          Localizations.localeOf(context).toString(),
        ).add_Hm().format(_unlockAt),
      ),
      const SizedBox(height: 18),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.paleRose,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_outline_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.sealWarning,
                style: const TextStyle(height: 1.45),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Future<void> _nextStep() async {
    if (_step == 0 && _items.isEmpty) {
      return _message(context.l10n.noContentError);
    }
    if (_step == 1 && _titleController.text.trim().isEmpty) {
      return _message(context.l10n.titleError);
    }
    if (_step == 1 &&
        _categoryId == 'other' &&
        _customCategoryController.text.trim().isEmpty) {
      return _message(context.l10n.customCategoryError);
    }
    if (_step == 2 && !_unlockAt.isAfter(DateTime.now())) {
      return _message(context.l10n.dateError);
    }
    if (_step == 1 || _step == 2) await _saveDraft();
    setState(() => _step++);
    await _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _saveDraft() async {
    final draft = _draft;
    if (draft == null) return;
    final repository = ref.read(capsuleRepositoryProvider);
    var savedCategoryId = _categoryId;
    if (_categoryId == 'other') {
      final customCategory = await repository.findOrCreateCategory(
        _customCategoryController.text,
      );
      savedCategoryId = customCategory.id;
    }
    _draft = draft.copyWith(
      title: _titleController.text.trim(),
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      categoryId: savedCategoryId,
      coverId: _coverId,
      unlockAt: normalizeUnlockDate(_unlockAt, includesTime: _includesTime),
      unlockIncludesTime: _includesTime,
    );
    await repository.updateDraft(_draft!);
  }

  Future<void> _confirmSeal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.l10n.sealQuestion),
            content: Text(context.l10n.sealWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.back),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.sealForFuture),
              ),
            ],
          ),
    );
    if (confirmed != true || _draft == null) return;
    setState(() => _busy = true);
    try {
      await _saveDraft();
      final now = DateTime.now();
      await ref.read(capsuleRepositoryProvider).seal(_draft!.id, now);
      final sealed = await ref
          .read(capsuleRepositoryProvider)
          .getCapsule(_draft!.id);
      final preferences = ref.read(appPreferencesProvider).value;
      try {
        await ref.read(notificationProvider).requestPermission();
        await ref
            .read(notificationProvider)
            .scheduleCapsule(
              sealed,
              NotificationPreferences(
                opening: preferences.openingNotifications,
                dayBefore: preferences.dayReminder,
                weekBefore: preferences.weekReminder,
              ),
            );
      } catch (_) {
        // The capsule remains safely sealed even when Android rejects scheduling.
      }
      ref.invalidate(capsulesProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.sealedSuccess)));
        if (widget.tutorial) {
          context.go('/capsules?tutorial=true');
        } else {
          context.pushReplacement('/capsule/${sealed.id}');
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addType(CapsuleItemType type) async {
    if (_draft == null || _busy) return;
    switch (type) {
      case CapsuleItemType.image:
        await _pickImage();
      case CapsuleItemType.video:
        await _pickVideo();
      case CapsuleItemType.audio:
        await _chooseAudio();
      case CapsuleItemType.text:
        await _writeText();
    }
  }

  Future<ImageSource?> _sourceDialog() => showModalBottomSheet<ImageSource>(
    context: context,
    builder:
        (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(context.l10n.camera),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.folder_open_outlined),
                title: Text(context.l10n.importLabel),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
  );

  Future<void> _pickCustomCover() async {
    final draft = _draft;
    if (draft == null || _busy) return;
    final source = await _sourceDialog();
    if (source == null) return;
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 88,
    );
    if (file == null || !mounted) return;

    setState(() => _busy = true);
    String? encryptedPath;
    try {
      final key = await ref.read(keyServiceProvider).getOrCreateMasterKey();
      encryptedPath = await ref
          .read(storageProvider)
          .importAndEncrypt(
            file.path,
            key,
            deleteSource: source == ImageSource.camera,
          );
      final newCoverId = customCoverId(encryptedPath);
      final updatedDraft = draft.copyWith(coverId: newCoverId);
      await ref.read(capsuleRepositoryProvider).updateDraft(updatedDraft);

      final previousPath = customCoverPath(_coverId);
      if (mounted) {
        setState(() {
          _draft = updatedDraft;
          _coverId = newCoverId;
        });
      }
      if (previousPath != null && previousPath != encryptedPath) {
        await _deleteCoverFileQuietly(previousPath);
      }
    } catch (_) {
      if (encryptedPath != null) {
        await _deleteCoverFileQuietly(encryptedPath);
      }
      if (mounted) _message(context.l10n.importError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _selectBuiltInCover(String coverId) async {
    if (_coverId == coverId || _busy) return;
    final draft = _draft;
    if (draft == null) {
      setState(() => _coverId = coverId);
      return;
    }

    setState(() => _busy = true);
    try {
      final previousPath = customCoverPath(_coverId);
      final updatedDraft = draft.copyWith(coverId: coverId);
      await ref.read(capsuleRepositoryProvider).updateDraft(updatedDraft);
      if (mounted) {
        setState(() {
          _draft = updatedDraft;
          _coverId = coverId;
        });
      }
      if (previousPath != null) {
        await _deleteCoverFileQuietly(previousPath);
      }
    } catch (_) {
      if (mounted) _message(context.l10n.importError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteCoverFileQuietly(String path) async {
    try {
      await ref.read(storageProvider).deleteEncryptedFiles([path]);
    } catch (_) {
      // A stale encrypted cover can be cleaned up by storage maintenance later.
    }
  }

  Future<void> _pickImage() async {
    final source = await _sourceDialog();
    if (source == null) return;
    final file = await _picker.pickImage(source: source, imageQuality: 95);
    if (file != null) {
      await _importFile(
        file.path,
        CapsuleItemType.image,
        _mime(file.path, 'image/jpeg'),
        deleteSource: source == ImageSource.camera,
      );
    }
  }

  Future<void> _pickVideo() async {
    final source = await _sourceDialog();
    if (source == null) return;
    final file = await _picker.pickVideo(source: source);
    if (file != null) {
      await _importFile(
        file.path,
        CapsuleItemType.video,
        _mime(file.path, 'video/mp4'),
        deleteSource: source == ImageSource.camera,
      );
    }
  }

  Future<void> _chooseAudio() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.mic_none_rounded),
                  title: Text(context.l10n.record),
                  onTap: () => Navigator.pop(context, 'record'),
                ),
                ListTile(
                  leading: const Icon(Icons.folder_open_outlined),
                  title: Text(context.l10n.importLabel),
                  onTap: () => Navigator.pop(context, 'import'),
                ),
              ],
            ),
          ),
    );
    if (action == 'record') return _recordAudio();
    if (action == 'import') {
      final result = await FilePicker.pickFiles(
        type: FileType.audio,
        withData: false,
      );
      final path = result?.files.single.path;
      if (path != null) {
        await _importFile(
          path,
          CapsuleItemType.audio,
          _mime(path, 'audio/mpeg'),
        );
      }
    }
  }

  Future<void> _recordAudio() async {
    final recorder = AudioRecorder();
    try {
      final permitted = await recorder.hasPermission();
      if (!mounted) return;
      if (!permitted) {
        return _message(context.l10n.importError);
      }
      final temp = await getTemporaryDirectory();
      final path = p.join(temp.path, '${_uuid.v4()}.m4a');
      await recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: Text(context.l10n.record),
              content: const SizedBox(
                height: 70,
                child: Center(
                  child: Icon(
                    Icons.graphic_eq_rounded,
                    size: 54,
                    color: AppColors.dustyRose,
                  ),
                ),
              ),
              actions: [
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.stop_rounded),
                  label: Text(context.l10n.save),
                ),
              ],
            ),
      );
      final recorded = await recorder.stop();
      if (recorded != null) {
        await _importFile(
          recorded,
          CapsuleItemType.audio,
          'audio/mp4',
          deleteSource: true,
        );
      }
    } finally {
      await recorder.dispose();
    }
  }

  Future<void> _writeText() async {
    final title = TextEditingController();
    final body = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.l10n.addText),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: title,
                      decoration: InputDecoration(
                        labelText: context.l10n.textTitleOptional,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: body,
                      minLines: 6,
                      maxLines: 12,
                      decoration: InputDecoration(
                        labelText: context.l10n.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed:
                    () => Navigator.pop(context, body.text.trim().isNotEmpty),
                child: Text(context.l10n.save),
              ),
            ],
          ),
    );
    if (accepted != true || _draft == null) return;
    await _storeTextItem(
      title: title.text.trim().isEmpty ? null : title.text.trim(),
      body: body.text,
    );
    title.dispose();
    body.dispose();
  }

  Future<bool> _storeTextItem({String? title, required String body}) async {
    if (_draft == null || body.trim().isEmpty) return false;
    setState(() => _busy = true);
    try {
      final key = await ref.read(keyServiceProvider).getOrCreateMasterKey();
      final encrypted = await ref
          .read(encryptionProvider)
          .encryptText(body, key);
      final encryptedTitle =
          title == null || title.trim().isEmpty
              ? null
              : await ref
                  .read(encryptionProvider)
                  .encryptText(title.trim(), key);
      final item = CapsuleItem(
        id: _uuid.v4(),
        capsuleId: _draft!.id,
        type: CapsuleItemType.text,
        encryptedText: encrypted,
        textTitle: encryptedTitle,
        byteSize: body.length,
        createdAt: DateTime.now(),
        orderIndex: _items.length,
      );
      await ref.read(capsuleRepositoryProvider).addItem(item);
      if (mounted) setState(() => _items.add(item));
      return true;
    } catch (_) {
      if (mounted) _message(context.l10n.importError);
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _scheduleTutorialStep() {
    if (_tutorialShowing || (_tutorialTimer?.isActive ?? false)) return;
    _tutorialTimer = Timer(const Duration(milliseconds: 450), () {
      if (mounted) _showTutorialStep();
    });
  }

  void _showTutorialStep() {
    if (!mounted || !widget.tutorial || _tutorialShowing) return;
    final targets = switch (_step) {
      0 => [
        tutorialTarget(
          id: 'creation-text',
          key: _textTutorialKey,
          title: context.l10n.tutorialTextTitle,
          body: context.l10n.tutorialTextBody,
          align: ContentAlign.top,
        ),
      ],
      1 => [
        tutorialTarget(
          id: 'creation-category',
          key: _categoryTutorialKey,
          title: context.l10n.tutorialCategoryTitle,
          body: context.l10n.tutorialCategoryBody,
        ),
        tutorialTarget(
          id: 'creation-covers',
          key: _coversTutorialKey,
          title: context.l10n.tutorialCoversTitle,
          body: context.l10n.tutorialCoversBody,
          align: ContentAlign.top,
        ),
      ],
      2 => [
        tutorialTarget(
          id: 'creation-quick-dates',
          key: _quickDatesTutorialKey,
          title: context.l10n.tutorialQuickDatesTitle,
          body: context.l10n.tutorialQuickDatesBody,
        ),
        tutorialTarget(
          id: 'creation-date',
          key: _dateTutorialKey,
          title: context.l10n.tutorialDateTitle,
          body: context.l10n.tutorialDateBody,
          align: ContentAlign.top,
        ),
        tutorialTarget(
          id: 'creation-time',
          key: _timeTutorialKey,
          title: context.l10n.tutorialTimeTitle,
          body: context.l10n.tutorialTimeBody,
        ),
      ],
      _ => [
        tutorialTarget(
          id: 'creation-seal',
          key: _sealTutorialKey,
          title: context.l10n.tutorialSealTitle,
          body: context.l10n.tutorialSealBody,
          align: ContentAlign.top,
        ),
      ],
    };
    if (targets.any((target) => target.keyTarget?.currentContext == null)) {
      _scheduleTutorialStep();
      return;
    }
    _tutorialShowing = true;
    showTutorial(
      context: context,
      targets: targets,
      skipLabel: context.l10n.skip,
      onFinish: () {
        _tutorialShowing = false;
        _finishTutorialStep();
      },
      onSkip: _skipTutorial,
    );
  }

  Future<void> _finishTutorialStep() async {
    if (!mounted) return;
    if (_step < 3) {
      await _nextStep();
      if (mounted) _scheduleTutorialStep();
    } else {
      await _confirmSeal();
    }
  }

  Future<void> _skipTutorial() async {
    await ref.read(appPreferencesProvider).completeTutorial();
    if (mounted) context.go('/');
  }

  Future<void> _importFile(
    String path,
    CapsuleItemType type,
    String mime, {
    bool deleteSource = false,
  }) async {
    if (_draft == null) return;
    setState(() => _busy = true);
    try {
      final key = await ref.read(keyServiceProvider).getOrCreateMasterKey();
      final encryptedPath = await ref
          .read(storageProvider)
          .importAndEncrypt(path, key, deleteSource: deleteSource);
      final item = CapsuleItem(
        id: _uuid.v4(),
        capsuleId: _draft!.id,
        type: type,
        encryptedPath: encryptedPath,
        mimeType: mime,
        byteSize:
            await File(path).exists()
                ? await File(path).length()
                : await File(encryptedPath).length(),
        createdAt: DateTime.now(),
        orderIndex: _items.length,
      );
      await ref.read(capsuleRepositoryProvider).addItem(item);
      if (mounted) setState(() => _items.add(item));
    } catch (_) {
      if (mounted) _message(context.l10n.importError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removeItem(CapsuleItem item) async {
    await ref
        .read(capsuleRepositoryProvider)
        .removeItem(item.capsuleId, item.id);
    if (item.encryptedPath != null) {
      await ref.read(storageProvider).deleteEncryptedFiles([
        item.encryptedPath!,
      ]);
    }
    setState(() => _items.remove(item));
  }

  void _quickDate({int months = 0, int years = 0}) {
    final now = DateTime.now();
    setState(
      () =>
          _unlockAt = DateTime(
            now.year + years,
            now.month + months,
            now.day,
            _includesTime ? now.hour : 0,
            _includesTime ? now.minute : 0,
          ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _unlockAt.isAfter(DateTime.now())
              ? _unlockAt
              : DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 100)),
    );
    if (date == null) return;
    setState(
      () =>
          _unlockAt = DateTime(
            date.year,
            date.month,
            date.day,
            _includesTime ? _unlockAt.hour : 0,
            _includesTime ? _unlockAt.minute : 0,
          ),
    );
    if (_includesTime) await _pickTime();
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_unlockAt),
    );
    if (time != null) {
      setState(
        () =>
            _unlockAt = DateTime(
              _unlockAt.year,
              _unlockAt.month,
              _unlockAt.day,
              time.hour,
              time.minute,
            ),
      );
    }
  }

  Future<void> _handleBack() async {
    if (_step > 0) {
      setState(() => _step--);
      return _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }
    final discard = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.l10n.cancel),
            content: Text(context.l10n.sealWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.back),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.cancel),
              ),
            ],
          ),
    );
    if (discard == true && _draft != null) {
      final paths = await ref
          .read(capsuleRepositoryProvider)
          .discardDraft(_draft!.id);
      await ref.read(storageProvider).deleteEncryptedFiles(paths);
      if (mounted) popOrGo(context, '/');
    }
  }

  void _message(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
  IconData _typeIcon(CapsuleItemType type) => switch (type) {
    CapsuleItemType.image => Icons.photo_outlined,
    CapsuleItemType.video => Icons.videocam_outlined,
    CapsuleItemType.audio => Icons.mic_none_rounded,
    CapsuleItemType.text => Icons.description_outlined,
  };
  Widget _itemPreview(CapsuleItem item) {
    final path = item.encryptedPath;
    if (item.type != CapsuleItemType.image || path == null) {
      return CircleAvatar(
        backgroundColor: _typeColor(item.type),
        child: Icon(_typeIcon(item.type), color: AppColors.ink),
      );
    }

    final preview = ref.watch(privateImageBytesProvider(path));
    return SizedBox.square(
      dimension: 40,
      child: ClipOval(
        child: preview.when(
          loading: () => _imagePreviewFallback(showProgress: true),
          error: (_, __) => _imagePreviewFallback(),
          data:
              (bytes) =>
                  bytes == null
                      ? _imagePreviewFallback()
                      : Image.memory(
                        bytes,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => _imagePreviewFallback(),
                      ),
        ),
      ),
    );
  }

  Widget _imagePreviewFallback({bool showProgress = false}) => ColoredBox(
    color: AppColors.paleRose,
    child: Center(
      child:
          showProgress
              ? const SizedBox.square(
                dimension: 15,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(
                Icons.photo_outlined,
                size: 22,
                color: AppColors.ink,
              ),
    ),
  );
  Color _typeColor(CapsuleItemType type) => switch (type) {
    CapsuleItemType.image => AppColors.paleRose,
    CapsuleItemType.video => AppColors.paleSage,
    CapsuleItemType.audio => const Color(0xFFE8DAC8),
    CapsuleItemType.text => AppColors.lavender,
  };
  String _typeLabel(CapsuleItemType type) => switch (type) {
    CapsuleItemType.image => context.l10n.photo,
    CapsuleItemType.video => context.l10n.video,
    CapsuleItemType.audio => context.l10n.audio,
    CapsuleItemType.text => context.l10n.text,
  };
  String _selectedCategoryLabel() {
    if (_categoryId == 'other') {
      return _customCategoryController.text.trim();
    }
    final categories =
        ref.read(categoriesProvider).valueOrNull ?? const <CapsuleCategory>[];
    for (final category in categories) {
      if (category.id == _categoryId) {
        return categoryLabel(context, category);
      }
    }
    return _categoryId;
  }

  String _mime(String path, String fallback) {
    final extension = p.extension(path).toLowerCase();
    return switch (extension) {
      '.png' => 'image/png',
      '.webp' => 'image/webp',
      '.heic' => 'image/heic',
      '.mov' => 'video/quicktime',
      '.mkv' => 'video/x-matroska',
      '.wav' => 'audio/wav',
      '.m4a' => 'audio/mp4',
      '.ogg' => 'audio/ogg',
      _ => fallback,
    };
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: color,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, size: 21, color: AppColors.secondaryInk),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
      ],
    ),
  );
}
