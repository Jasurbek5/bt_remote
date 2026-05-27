package com.example.bt_remote

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothHidDevice
import android.bluetooth.BluetoothHidDeviceAppSdpSettings
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.content.Context
import android.os.Handler
import android.os.Looper
import java.util.concurrent.Executor

@SuppressLint("MissingPermission")
class HidDeviceService(private val context: Context) {

    companion object {
        // HID Report Descriptor: Keyboard (ID=1) + Mouse (ID=2) + Consumer (ID=3)
        private val HID_DESCRIPTOR = byteArrayOf(
            // ===== KEYBOARD (Report ID 1) =====
            0x05.toByte(), 0x01.toByte(),  // Usage Page (Generic Desktop)
            0x09.toByte(), 0x06.toByte(),  // Usage (Keyboard)
            0xA1.toByte(), 0x01.toByte(),  // Collection (Application)
            0x85.toByte(), 0x01.toByte(),  //   Report ID (1)
            // Modifier keys
            0x05.toByte(), 0x07.toByte(),  //   Usage Page (Key Codes)
            0x19.toByte(), 0xE0.toByte(),  //   Usage Minimum (224) - Left Ctrl
            0x29.toByte(), 0xE7.toByte(),  //   Usage Maximum (231) - Right GUI
            0x15.toByte(), 0x00.toByte(),  //   Logical Minimum (0)
            0x25.toByte(), 0x01.toByte(),  //   Logical Maximum (1)
            0x75.toByte(), 0x01.toByte(),  //   Report Size (1)
            0x95.toByte(), 0x08.toByte(),  //   Report Count (8)
            0x81.toByte(), 0x02.toByte(),  //   Input (Data, Variable, Absolute)
            // Reserved byte
            0x95.toByte(), 0x01.toByte(),  //   Report Count (1)
            0x75.toByte(), 0x08.toByte(),  //   Report Size (8)
            0x81.toByte(), 0x01.toByte(),  //   Input (Constant)
            // Key array (6 keys)
            0x95.toByte(), 0x06.toByte(),  //   Report Count (6)
            0x75.toByte(), 0x08.toByte(),  //   Report Size (8)
            0x15.toByte(), 0x00.toByte(),  //   Logical Minimum (0)
            0x25.toByte(), 0x65.toByte(),  //   Logical Maximum (101)
            0x05.toByte(), 0x07.toByte(),  //   Usage Page (Key Codes)
            0x19.toByte(), 0x00.toByte(),  //   Usage Minimum (0)
            0x29.toByte(), 0x65.toByte(),  //   Usage Maximum (101)
            0x81.toByte(), 0x00.toByte(),  //   Input (Data, Array)
            0xC0.toByte(),                 // End Collection

            // ===== MOUSE (Report ID 2) =====
            0x05.toByte(), 0x01.toByte(),  // Usage Page (Generic Desktop)
            0x09.toByte(), 0x02.toByte(),  // Usage (Mouse)
            0xA1.toByte(), 0x01.toByte(),  // Collection (Application)
            0x85.toByte(), 0x02.toByte(),  //   Report ID (2)
            0x09.toByte(), 0x01.toByte(),  //   Usage (Pointer)
            0xA1.toByte(), 0x00.toByte(),  //   Collection (Physical)
            // Buttons
            0x05.toByte(), 0x09.toByte(),  //     Usage Page (Button)
            0x19.toByte(), 0x01.toByte(),  //     Usage Minimum (1)
            0x29.toByte(), 0x03.toByte(),  //     Usage Maximum (3)
            0x15.toByte(), 0x00.toByte(),  //     Logical Minimum (0)
            0x25.toByte(), 0x01.toByte(),  //     Logical Maximum (1)
            0x95.toByte(), 0x03.toByte(),  //     Report Count (3)
            0x75.toByte(), 0x01.toByte(),  //     Report Size (1)
            0x81.toByte(), 0x02.toByte(),  //     Input (Data, Variable, Absolute)
            // Padding
            0x95.toByte(), 0x01.toByte(),  //     Report Count (1)
            0x75.toByte(), 0x05.toByte(),  //     Report Size (5)
            0x81.toByte(), 0x01.toByte(),  //     Input (Constant)
            // X, Y movement
            0x05.toByte(), 0x01.toByte(),  //     Usage Page (Generic Desktop)
            0x09.toByte(), 0x30.toByte(),  //     Usage (X)
            0x09.toByte(), 0x31.toByte(),  //     Usage (Y)
            0x09.toByte(), 0x38.toByte(),  //     Usage (Wheel)
            0x15.toByte(), 0x81.toByte(),  //     Logical Minimum (-127)
            0x25.toByte(), 0x7F.toByte(),  //     Logical Maximum (127)
            0x75.toByte(), 0x08.toByte(),  //     Report Size (8)
            0x95.toByte(), 0x03.toByte(),  //     Report Count (3)
            0x81.toByte(), 0x06.toByte(),  //     Input (Data, Variable, Relative)
            0xC0.toByte(),                 //   End Collection
            0xC0.toByte(),                 // End Collection

            // ===== CONSUMER CONTROL / MEDIA (Report ID 3) =====
            0x05.toByte(), 0x0C.toByte(),  // Usage Page (Consumer)
            0x09.toByte(), 0x01.toByte(),  // Usage (Consumer Control)
            0xA1.toByte(), 0x01.toByte(),  // Collection (Application)
            0x85.toByte(), 0x03.toByte(),  //   Report ID (3)
            0x15.toByte(), 0x00.toByte(),  //   Logical Minimum (0)
            0x26.toByte(), 0xFF.toByte(), 0x03.toByte(), // Logical Maximum (1023)
            0x19.toByte(), 0x00.toByte(),  //   Usage Minimum (0)
            0x2A.toByte(), 0xFF.toByte(), 0x03.toByte(), // Usage Maximum (1023)
            0x75.toByte(), 0x10.toByte(),  //   Report Size (16)
            0x95.toByte(), 0x01.toByte(),  //   Report Count (1)
            0x81.toByte(), 0x00.toByte(),  //   Input (Data, Array)
            0xC0.toByte()                  // End Collection
        )

        private val SDP_NAME = "BT Remote"
        private val SDP_DESCRIPTION = "Bluetooth HID Remote Control"
        private val SDP_PROVIDER = "BT Remote App"
        private const val QOS_TOKEN_RATE = 800
        private const val QOS_TOKEN_BUCKET_SIZE = 9
        private const val QOS_PEAK_BANDWIDTH = 0
        private const val QOS_LATENCY = 11250
    }

    private val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val bluetoothAdapter: BluetoothAdapter? = bluetoothManager.adapter

    private var hidDevice: BluetoothHidDevice? = null
    private var connectedDevice: BluetoothDevice? = null
    private var registrationState = false

    var onConnectionChanged: ((Boolean, String?) -> Unit)? = null

    private val hidCallback = object : BluetoothHidDevice.Callback() {
        override fun onAppStatusChanged(pluggedDevice: BluetoothDevice?, registered: Boolean) {
            registrationState = registered
            if (!registered) {
                connectedDevice = null
                onConnectionChanged?.invoke(false, null)
            }
        }

        override fun onConnectionStateChanged(device: BluetoothDevice, state: Int) {
            when (state) {
                BluetoothProfile.STATE_CONNECTED -> {
                    connectedDevice = device
                    onConnectionChanged?.invoke(true, device.name ?: device.address)
                }
                BluetoothProfile.STATE_DISCONNECTED -> {
                    if (connectedDevice?.address == device.address) {
                        connectedDevice = null
                        onConnectionChanged?.invoke(false, null)
                    }
                }
            }
        }
    }

    private val profileListener = object : BluetoothProfile.ServiceListener {
        override fun onServiceConnected(profile: Int, proxy: BluetoothProfile) {
            if (profile == BluetoothProfile.HID_DEVICE) {
                hidDevice = proxy as BluetoothHidDevice
                val sdp = BluetoothHidDeviceAppSdpSettings(
                    SDP_NAME, SDP_DESCRIPTION, SDP_PROVIDER,
                    BluetoothHidDevice.SUBCLASS1_COMBO, HID_DESCRIPTOR
                )
                val executor: Executor = Executor { command -> Handler(Looper.getMainLooper()).post(command) }
                hidDevice?.registerApp(sdp, null, null, executor, hidCallback)
            }
        }

        override fun onServiceDisconnected(profile: Int) {
            if (profile == BluetoothProfile.HID_DEVICE) {
                hidDevice = null
                registrationState = false
            }
        }
    }

    fun initialize() {
        bluetoothAdapter?.getProfileProxy(context, profileListener, BluetoothProfile.HID_DEVICE)
    }

    fun getPairedDevices(): List<Map<String, String>> {
        val devices = bluetoothAdapter?.bondedDevices ?: return emptyList()
        return devices.map { device ->
            mapOf(
                "address" to device.address,
                "name" to (device.name ?: device.address)
            )
        }
    }

    fun connect(address: String): Boolean {
        val device = bluetoothAdapter?.getRemoteDevice(address) ?: return false
        return hidDevice?.connect(device) ?: false
    }

    fun disconnect(): Boolean {
        val device = connectedDevice ?: return false
        val result = hidDevice?.disconnect(device) ?: false
        if (result) {
            connectedDevice = null
        }
        return result
    }

    fun isConnected(): Boolean = connectedDevice != null

    fun getConnectedDeviceName(): String? = connectedDevice?.name

    // Send keyboard report: modifier + 6 keycodes
    fun sendKey(modifier: Int, keyCodes: List<Int>): Boolean {
        val device = connectedDevice ?: return false
        val hid = hidDevice ?: return false
        val report = ByteArray(8)
        report[0] = modifier.toByte()
        report[1] = 0x00 // reserved
        for (i in 0 until minOf(6, keyCodes.size)) {
            report[2 + i] = keyCodes[i].toByte()
        }
        return hid.sendReport(device, 1, report)
    }

    // Release all keys
    fun releaseKeys(): Boolean {
        val device = connectedDevice ?: return false
        val hid = hidDevice ?: return false
        return hid.sendReport(device, 1, ByteArray(8))
    }

    // Send mouse report: buttons + dx + dy + scroll
    fun sendMouse(buttons: Int, dx: Int, dy: Int, scroll: Int): Boolean {
        val device = connectedDevice ?: return false
        val hid = hidDevice ?: return false
        val report = ByteArray(4)
        report[0] = buttons.toByte()
        report[1] = clampToByte(dx)
        report[2] = clampToByte(dy)
        report[3] = clampToByte(scroll)
        return hid.sendReport(device, 2, report)
    }

    // Send media/consumer report
    fun sendMedia(consumerCode: Int): Boolean {
        val device = connectedDevice ?: return false
        val hid = hidDevice ?: return false
        val report = ByteArray(2)
        report[0] = (consumerCode and 0xFF).toByte()
        report[1] = ((consumerCode shr 8) and 0xFF).toByte()
        val sent = hid.sendReport(device, 3, report)
        // Release after 50ms
        Handler(Looper.getMainLooper()).postDelayed({
            hid.sendReport(device, 3, ByteArray(2))
        }, 50)
        return sent
    }

    private fun clampToByte(value: Int): Byte {
        return value.coerceIn(-127, 127).toByte()
    }

    fun release() {
        hidDevice?.unregisterApp()
        bluetoothAdapter?.closeProfileProxy(BluetoothProfile.HID_DEVICE, hidDevice)
        hidDevice = null
    }
}
