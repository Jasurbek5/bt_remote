import 'dart:async';
import 'dart:io';
import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class PairedDevice {
  final String address;
  final String name;

  PairedDevice({required this.address, required this.name});

  factory PairedDevice.fromMap(Map map) {
    return PairedDevice(
      address: map['address'] as String,
      name: map['name'] as String,
    );
  }
}

class HidService extends ChangeNotifier {
  static final HidService _instance = HidService._internal();
  factory HidService() => _instance;
  HidService._internal();

  static const MethodChannel _channel = MethodChannel('bt_remote/hid');
  static const EventChannel _eventChannel = EventChannel('bt_remote/hid_events');

  bool _isConnected = false;
  bool _isPermissionGranted = false;
  bool _isInitializing = false;
  String? _connectedDeviceName;
  StreamSubscription? _eventSubscription;

  bool get isConnected => _isConnected;
  bool get isPermissionGranted => _isPermissionGranted;
  bool get isInitializing => _isInitializing;
  String? get connectedDeviceName => _connectedDeviceName;

  /// Ruxsatnomalarni tekshirish va so'rash
  Future<bool> checkAndRequestPermissions() async {
    if (!Platform.isAndroid) {
      _isPermissionGranted = true;
      return true;
    }

    // Android 12+ (API 31+) uchun ruxsatlar
    // Location ruxsati kerak EMAS — faqat juftlangan qurilmalar ishlatiladi
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();

    _isPermissionGranted = statuses.values.every((status) => status.isGranted);
    notifyListeners();
    return _isPermissionGranted;
  }

  Future<void> initialize() async {
    if (_isInitializing) return;
    _isInitializing = true;
    notifyListeners();

    try {
      // Avval ruxsatlarni tekshiramiz
      bool hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        _isInitializing = false;
        notifyListeners();
        return;
      }

      await _channel.invokeMethod('initialize');
      _eventSubscription?.cancel();
      _eventSubscription = _eventChannel.receiveBroadcastStream().listen((event) {
        final map = Map<String, dynamic>.from(event as Map);
        _isConnected = map['connected'] as bool;
        _connectedDeviceName = (_isConnected && (map['deviceName'] as String).isNotEmpty)
            ? map['deviceName'] as String
            : null;
        notifyListeners();
      }, onError: (err) {
        debugPrint('EventChannel error: $err');
      });
    } catch (e) {
      debugPrint('HidService initialize error: $e');
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<List<PairedDevice>> getPairedDevices() async {
    if (!_isPermissionGranted) {
      bool granted = await checkAndRequestPermissions();
      if (!granted) return [];
    }
    
    try {
      final result = await _channel.invokeMethod<List>('getPairedDevices');
      return (result ?? [])
          .map((e) => PairedDevice.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('getPairedDevices error: $e');
      return [];
    }
  }

  Future<bool> connect(String address) async {
    if (!_isPermissionGranted) return false;
    try {
      final result = await _channel.invokeMethod<bool>('connect', {'address': address});
      return result ?? false;
    } catch (e) {
      debugPrint('connect error: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('disconnect');
      _isConnected = false;
      _connectedDeviceName = null;
      notifyListeners();
    } catch (e) {
      debugPrint('disconnect error: $e');
    }
  }

  Future<bool> sendKey({int modifier = 0, List<int> keyCodes = const []}) async {
    if (!_isConnected) return false;
    try {
      final result = await _channel.invokeMethod<bool>('sendKey', {
        'modifier': modifier,
        'keyCodes': keyCodes,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('sendKey error: $e');
      return false;
    }
  }

  Future<void> sendText(String text, {bool capsLock = false, bool shift = false}) async {
    for (final char in text.characters) {
      final isUpper = char == char.toUpperCase() && char != char.toLowerCase();
      final needShift = shift || isUpper || capsLock;
      final mod = needShift ? KeyMod.lShift : KeyMod.none;
      final code = KeyCode.fromChar(char, needShift);
      if (code != KeyCode.none) {
        await sendKey(modifier: mod, keyCodes: [code]);
        await Future.delayed(const Duration(milliseconds: 15));
        await sendKey(modifier: 0, keyCodes: []);
        await Future.delayed(const Duration(milliseconds: 15));
      }
    }
  }

  Future<bool> sendMouse({int buttons = 0, int dx = 0, int dy = 0, int scroll = 0}) async {
    if (!_isConnected) return false;
    try {
      final result = await _channel.invokeMethod<bool>('sendMouse', {
        'buttons': buttons,
        'dx': dx,
        'dy': dy,
        'scroll': scroll,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('sendMouse error: $e');
      return false;
    }
  }

  Future<bool> sendMedia(int consumerCode) async {
    if (!_isConnected) return false;
    try {
      final result = await _channel.invokeMethod<bool>('sendMedia', {'code': consumerCode});
      return result ?? false;
    } catch (e) {
      debugPrint('sendMedia error: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}

class MediaCode {
  static const int playPause  = 0x00CD;
  static const int nextTrack  = 0x00B5;
  static const int prevTrack  = 0x00B6;
  static const int stop       = 0x00B7;
  static const int fastForward = 0x00B3;
  static const int rewind     = 0x00B4;
  static const int volUp      = 0x00E9;
  static const int volDown    = 0x00EA;
  static const int mute       = 0x00E2;
  static const int power      = 0x0030;
  static const int arrowUp    = 0x0042;
  static const int arrowDown  = 0x0043;
  static const int arrowLeft  = 0x0044;
  static const int arrowRight = 0x0045;
  static const int menu       = 0x0040;
  static const int back       = 0x0224;
  static const int home       = 0x0223;
  static const int ok         = 0x0041;
}

class KeyMod {
  static const int none     = 0x00;
  static const int lCtrl    = 0x01;
  static const int lShift   = 0x02;
  static const int lAlt     = 0x04;
  static const int lGui     = 0x08;
}

class KeyCode {
  static const int none     = 0x00;
  static const int a = 0x04; static const int b = 0x05; static const int c = 0x06;
  static const int d = 0x07; static const int e = 0x08; static const int f = 0x09;
  static const int g = 0x0A; static const int h = 0x0B; static const int i = 0x0C;
  static const int j = 0x0D; static const int k = 0x0E; static const int l = 0x0F;
  static const int m = 0x10; static const int n = 0x11; static const int o = 0x12;
  static const int p = 0x13; static const int q = 0x14; static const int r = 0x15;
  static const int s = 0x16; static const int t = 0x17; static const int u = 0x18;
  static const int v = 0x19; static const int w = 0x1A; static const int x = 0x1B;
  static const int y = 0x1C; static const int z = 0x1D;
  static const int k1 = 0x1E; static const int k2 = 0x1F; static const int k3 = 0x20;
  static const int k4 = 0x21; static const int k5 = 0x22; static const int k6 = 0x23;
  static const int k7 = 0x24; static const int k8 = 0x25; static const int k9 = 0x26;
  static const int k0 = 0x27;
  static const int enter = 0x28; static const int escape = 0x29;
  static const int backspace = 0x2A; static const int tab = 0x2B;
  static const int space = 0x2C; static const int capsLock = 0x39;
  static const int f1 = 0x3A; static const int f2 = 0x3B; static const int f3 = 0x3C;
  static const int f4 = 0x3D; static const int f5 = 0x3E; static const int f6 = 0x3F;
  static const int f7 = 0x40; static const int f8 = 0x41; static const int f9 = 0x42;
  static const int f10 = 0x43; static const int f11 = 0x44; static const int f12 = 0x45;
  static const int delete = 0x4C; static const int arrowRight = 0x4F;
  static const int arrowLeft = 0x50; static const int arrowDown = 0x51;
  static const int arrowUp = 0x52;

  static const Map<String, int> _charToCode = {
    'a': a, 'b': b, 'c': c, 'd': d, 'e': e, 'f': f, 'g': g, 'h': h, 'i': i, 'j': j,
    'k': k, 'l': l, 'm': m, 'n': n, 'o': o, 'p': p, 'q': q, 'r': r, 's': s, 't': t,
    'u': u, 'v': v, 'w': w, 'x': x, 'y': y, 'z': z, '1': k1, '2': k2, '3': k3,
    '4': k4, '5': k5, '6': k6, '7': k7, '8': k8, '9': k9, '0': k0, ' ': space,
    '\n': enter,
  };

  static int fromChar(String char, bool shift) {
    return _charToCode[char.toLowerCase()] ?? none;
  }
}
