package com.capsuladeltiempo.digital

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.nearby.Nearby
import com.google.android.gms.nearby.connection.*
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.InputStream
import java.util.UUID
import java.util.concurrent.Executors

/** One explicitly confirmed peer per foreground session. STREAM keeps data in private cache. */
class NearbyTransferBridge(
    private val activity: FlutterFragmentActivity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    companion object {
        private const val SERVICE = "com.capsuladeltiempo.digital.capsule.v1"
        private const val PERMISSIONS = 9476
        private const val MAX_BYTES = 1024L * 1024L * 1024L
    }
    private val client = Nearby.getConnectionsClient(activity)
    private val methods = MethodChannel(messenger, "ctd/nearby")
    private val events = EventChannel(messenger, "ctd/nearby/events")
    private val io = Executors.newSingleThreadExecutor()
    private val receivedDirectory = File(activity.cacheDir, "nearby_received").apply { mkdirs() }
    private var sink: EventChannel.EventSink? = null
    @Volatile private var generation = 0
    private var endpoint: String? = null
    private var connected = false
    private var receiver = false
    private var deviceName = ""
    private var pendingStart: MethodChannel.Result? = null
    private var expectedBytes = 0L
    private var receivingId: Long? = null
    private var sendingId: Long? = null
    private var receivedFile: File? = null
    private var streamSucceeded = false
    @Volatile private var incoming: InputStream? = null
    private var outgoing: InputStream? = null

    init {
        methods.setMethodCallHandler(this)
        events.setStreamHandler(this)
    }

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) { sink = eventSink }
    override fun onCancel(arguments: Any?) { sink = null; stop() }

    private fun emit(session: Int, type: String, values: Map<String, Any?> = emptyMap()) {
        activity.runOnUiThread {
            if (session == generation) sink?.success(mapOf("type" to type) + values)
        }
    }

    private fun permissions(): Array<String> = buildList {
        if (Build.VERSION.SDK_INT <= 32) {
            add(Manifest.permission.ACCESS_COARSE_LOCATION)
            add(Manifest.permission.ACCESS_FINE_LOCATION)
        }
        if (Build.VERSION.SDK_INT >= 31) {
            add(Manifest.permission.BLUETOOTH_SCAN)
            add(Manifest.permission.BLUETOOTH_CONNECT)
            add(Manifest.permission.BLUETOOTH_ADVERTISE)
        }
        if (Build.VERSION.SDK_INT >= 33) add(Manifest.permission.NEARBY_WIFI_DEVICES)
        if (Build.VERSION.SDK_INT >= 37 && activity.applicationInfo.targetSdkVersion >= 37) {
            add("android.permission.ACCESS_LOCAL_NETWORK")
        }
    }.filter { ContextCompat.checkSelfPermission(activity, it) != PackageManager.PERMISSION_GRANTED }.toTypedArray()

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "start" -> {
                    stop()
                    if (GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(activity) != ConnectionResult.SUCCESS) {
                        result.error("PLAY_SERVICES", "Google Play services are required.", null)
                        return
                    }
                    receiver = call.argument<String>("mode") == "receive"
                    deviceName = (call.argument<String>("name") ?: "Capsula").take(40)
                    pendingStart = result
                    val needed = permissions()
                    if (needed.isEmpty()) begin() else ActivityCompat.requestPermissions(activity, needed, PERMISSIONS)
                }
                "request" -> {
                    check(!receiver && endpoint == null)
                    val id = requireNotNull(call.argument<String>("id"))
                    client.requestConnection(deviceName, id, lifecycle(generation))
                        .addOnSuccessListener { result.success(null) }
                        .addOnFailureListener { result.error("CONNECTION", "Connection failed.", null) }
                }
                "accept" -> {
                    val id = requireNotNull(endpoint)
                    client.acceptConnection(id, payloads(generation))
                        .addOnSuccessListener { result.success(null) }
                        .addOnFailureListener { result.error("CONNECTION", "Unable to accept.", null) }
                }
                "reject" -> {
                    endpoint?.let { client.rejectConnection(it) }
                    stop()
                    result.success(null)
                }
                "message" -> {
                    check(connected)
                    val bytes = requireNotNull(call.argument<String>("message")).toByteArray(Charsets.UTF_8)
                    require(bytes.size <= 32768)
                    client.sendPayload(requireNotNull(endpoint), Payload.fromBytes(bytes))
                        .addOnSuccessListener { result.success(null) }
                        .addOnFailureListener { result.error("TRANSFER", "Unable to send message.", null) }
                }
                "receiveStream" -> {
                    check(receiver && connected && receivingId == null && expectedBytes == 0L)
                    val size = requireNotNull(call.argument<Number>("size")).toLong()
                    require(size in 16..MAX_BYTES)
                    if (receivedDirectory.usableSpace < size * 3 + 32 * 1024 * 1024) {
                        result.error("SPACE", "Not enough free storage.", null)
                    } else {
                        expectedBytes = size
                        result.success(null)
                    }
                }
                "sendStream" -> {
                    check(!receiver && connected && sendingId == null)
                    val file = File(requireNotNull(call.argument<String>("path"))).canonicalFile
                    require(file.toPath().startsWith(activity.cacheDir.canonicalFile.toPath()))
                    require(file.length() in 16..MAX_BYTES)
                    outgoing = FileInputStream(file)
                    val payload = Payload.fromStream(requireNotNull(outgoing))
                    sendingId = payload.id
                    expectedBytes = file.length()
                    client.sendPayload(requireNotNull(endpoint), payload)
                        .addOnSuccessListener { result.success(null) }
                        .addOnFailureListener { closeStreams(); result.error("TRANSFER", "Unable to send file.", null) }
                }
                "release" -> {
                    val file = File(requireNotNull(call.argument<String>("path"))).canonicalFile
                    require(file.parentFile == receivedDirectory.canonicalFile)
                    file.delete()
                    result.success(null)
                }
                "stop" -> { stop(); result.success(null) }
                else -> result.notImplemented()
            }
        } catch (_: Exception) {
            result.error("NEARBY", "Operation unavailable. Check permissions and wireless settings.", null)
        }
    }

    fun onPermissionsResult(requestCode: Int) {
        if (requestCode != PERMISSIONS || pendingStart == null) return
        if (permissions().isNotEmpty()) {
            pendingStart?.error("PERMISSION", "Nearby permissions were denied.", null)
            pendingStart = null
        } else begin()
    }

    private fun begin() {
        val result = pendingStart ?: return
        pendingStart = null
        val session = generation
        val task = if (receiver) {
            client.startAdvertising(deviceName, SERVICE, lifecycle(session),
                AdvertisingOptions.Builder().setStrategy(Strategy.P2P_POINT_TO_POINT).build())
        } else {
            client.startDiscovery(SERVICE, object : EndpointDiscoveryCallback() {
                override fun onEndpointFound(id: String, info: DiscoveredEndpointInfo) {
                    if (info.serviceId == SERVICE) emit(session, "found", mapOf("id" to id, "name" to info.endpointName.take(40)))
                }
                override fun onEndpointLost(id: String) { emit(session, "lost", mapOf("id" to id)) }
            }, DiscoveryOptions.Builder().setStrategy(Strategy.P2P_POINT_TO_POINT).build())
        }
        task.addOnSuccessListener { result.success(null) }
            .addOnFailureListener { result.error("RADIOS", "Enable Bluetooth, Wi-Fi and (on older Android) location.", null) }
    }

    private fun lifecycle(session: Int) = object : ConnectionLifecycleCallback() {
        override fun onConnectionInitiated(id: String, info: ConnectionInfo) {
            if (session != generation || endpoint != null) { client.rejectConnection(id); return }
            endpoint = id
            client.stopDiscovery()
            client.stopAdvertising()
            emit(session, "pairing", mapOf("id" to id, "name" to info.endpointName.take(40), "code" to info.authenticationDigits))
        }
        override fun onConnectionResult(id: String, resolution: ConnectionResolution) {
            if (session != generation || id != endpoint) return
            if (resolution.status.isSuccess) {
                connected = true
                emit(session, "connected", mapOf("id" to id))
            } else {
                emit(session, "error", mapOf("code" to "CONNECTION"))
            }
        }
        override fun onDisconnected(id: String) {
            if (session == generation && id == endpoint) {
                connected = false
                closeStreams()
                emit(session, "disconnected")
            }
        }
    }

    private fun payloads(session: Int) = object : PayloadCallback() {
        override fun onPayloadReceived(id: String, payload: Payload) {
            if (session != generation || !connected || id != endpoint) { client.cancelPayload(payload.id); return }
            when (payload.type) {
                Payload.Type.BYTES -> {
                    val bytes = payload.asBytes() ?: return
                    if (bytes.size <= 32768) emit(session, "message", mapOf("message" to String(bytes, Charsets.UTF_8)))
                }
                Payload.Type.STREAM -> {
                    if (!receiver || expectedBytes == 0L || receivingId != null) { client.cancelPayload(payload.id); return }
                    receivingId = payload.id
                    val input = payload.asStream()?.asInputStream() ?: return
                    incoming = input
                    val size = expectedBytes
                    io.execute {
                        val file = File(receivedDirectory, "${UUID.randomUUID()}.ctdshare")
                        var keep = false
                        try {
                            var count = 0L
                            var lastUpdate = 0L
                            input.use { source ->
                                file.outputStream().use { destination ->
                                    val buffer = ByteArray(65536)
                                    while (true) {
                                        check(session == generation)
                                        val read = source.read(buffer)
                                        if (read < 0) break
                                        count += read
                                        require(count <= size)
                                        destination.write(buffer, 0, read)
                                        val now = System.currentTimeMillis()
                                        if (now - lastUpdate > 200) {
                                            emit(session, "progress", mapOf("bytes" to count, "total" to size))
                                            lastUpdate = now
                                        }
                                    }
                                }
                            }
                            require(count == size)
                            check(session == generation)
                            keep = true
                            activity.runOnUiThread {
                                if (session == generation) {
                                    receivedFile = file
                                    deliverReceived(session)
                                } else file.delete()
                            }
                        } catch (_: Exception) {
                            client.cancelPayload(payload.id)
                            emit(session, "error", mapOf("code" to "TRANSFER"))
                        } finally {
                            if (!keep) file.delete()
                            if (session == generation) incoming = null
                        }
                    }
                }
                else -> client.cancelPayload(payload.id)
            }
        }

        override fun onPayloadTransferUpdate(id: String, update: PayloadTransferUpdate) {
            if (session != generation || id != endpoint) return
            if (update.payloadId != sendingId && update.payloadId != receivingId) return
            when (update.status) {
                PayloadTransferUpdate.Status.SUCCESS -> {
                    if (update.payloadId == receivingId) {
                        streamSucceeded = true
                        deliverReceived(session)
                    } else {
                        runCatching { outgoing?.close() }; outgoing = null
                        emit(session, "sent")
                    }
                }
                PayloadTransferUpdate.Status.FAILURE, PayloadTransferUpdate.Status.CANCELED -> {
                    closeStreams()
                    emit(session, "error", mapOf("code" to "TRANSFER"))
                }
                else -> if (update.payloadId == sendingId) emit(session, "progress",
                    mapOf("bytes" to update.bytesTransferred, "total" to expectedBytes))
            }
        }
    }

    private fun deliverReceived(session: Int) {
        val file = receivedFile ?: return
        if (!streamSucceeded) return
        receivedFile = null
        emit(session, "received", mapOf("path" to file.path))
    }

    private fun stop() {
        generation++
        pendingStart?.error("CANCELLED", "Cancelled.", null)
        pendingStart = null
        client.stopAdvertising()
        client.stopDiscovery()
        client.stopAllEndpoints()
        closeStreams()
        receivedFile?.delete(); receivedFile = null
        endpoint = null; connected = false
        expectedBytes = 0; receivingId = null; sendingId = null; streamSucceeded = false
    }

    private fun closeStreams() {
        runCatching { incoming?.close() }; incoming = null
        runCatching { outgoing?.close() }; outgoing = null
    }

    fun dispose() {
        stop()
        methods.setMethodCallHandler(null)
        events.setStreamHandler(null)
        io.shutdownNow()
    }
}
