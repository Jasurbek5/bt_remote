package com.example.bt_remote

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "bt_remote/hid"
    private val EVENT_CHANNEL = "bt_remote/hid_events"

    private lateinit var hidService: HidDeviceService
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        hidService = HidDeviceService(applicationContext)

        hidService.onConnectionChanged = { connected, name ->
            runOnUiThread {
                eventSink?.success(mapOf(
                    "connected" to connected,
                    "deviceName" to (name ?: "")
                ))
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "initialize" -> {
                        // Ruxsatnomalar Flutter qismida tekshiriladi
                        hidService.initialize()
                        result.success(true)
                    }
                    "getPairedDevices" -> result.success(hidService.getPairedDevices())
                    "connect" -> {
                        val address = call.argument<String>("address") ?: ""
                        result.success(hidService.connect(address))
                    }
                    "disconnect" -> {
                        hidService.disconnect()
                        result.success(true)
                    }
                    "sendKey" -> {
                        val modifier = call.argument<Int>("modifier") ?: 0
                        val keyCodes = call.argument<List<Int>>("keyCodes") ?: emptyList()
                        hidService.sendKey(modifier, keyCodes)
                        result.success(true)
                    }
                    "sendMouse" -> {
                        val buttons = call.argument<Int>("buttons") ?: 0
                        val dx = call.argument<Int>("dx") ?: 0
                        val dy = call.argument<Int>("dy") ?: 0
                        val scroll = call.argument<Int>("scroll") ?: 0
                        result.success(hidService.sendMouse(buttons, dx, dy, scroll))
                    }
                    "sendMedia" -> {
                        val code = call.argument<Int>("code") ?: 0
                        result.success(hidService.sendMedia(code))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        hidService.release()
        super.onDestroy()
    }
}
