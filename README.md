# BT Remote — Bluetooth Keyboard & Mouse (Flutter)

Ushbu Flutter ilovasi Android telefonni Bluetooth orqali **klaviatura, sichqoncha va multimedia pultiga** aylantiradi.

---

## 📁 Fayl Tuzilmasi

```
bt_remote/
├── lib/
│   ├── main.dart                    # Ilova kirish nuqtasi
│   ├── services/
│   │   └── bluetooth_service.dart   # BT scan, connect, disconnect
│   ├── screens/
│   │   ├── home_screen.dart         # Asosiy ekran (AppBar + BottomNav)
│   │   ├── keyboard_screen.dart     # PC klaviaturasi ekrani
│   │   ├── trackpad_screen.dart     # Sichqoncha/trackpad ekrani
│   │   └── multimedia_screen.dart   # Multimedia pult ekrani
│   └── widgets/
│       ├── trackpad_widget.dart     # Qayta ishlatiladigan trackpad
│       └── device_selector.dart     # Qurilma tanlash bottom sheet
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml      # Bluetooth ruxsatlar
└── pubspec.yaml                     # Paketlar
```

---

## ⚙️ O'rnatish

### 1. Flutter loyiha yarating
```bash
flutter create bt_remote
cd bt_remote
```

### 2. Barcha fayllarni ko'chiring
Bu papkadagi barcha fayllarni tegishli joylarga ko'chiring.

### 3. Paketlarni o'rnating
```bash
flutter pub get
```

### 4. Android minSdk versiyasini belgilang
`android/app/build.gradle` faylida:
```gradle
android {
    defaultConfig {
        minSdkVersion 21   // ← Kamida 21 bo'lishi shart
        targetSdkVersion 34
    }
}
```

### 5. Ishga tushiring
```bash
flutter run
```

---

## 📱 Ekranlar va Funksiyalar

### 1. PC Klaviaturasi (Keyboard Screen)
- **F1-F12** funksiya tugmalari
- **QWERTY** to'liq klaviatura
- **Caps Lock** va **Shift** ishlaydi
- **100+ til** tanlash (English, O'zbek, Rus, ...)
- **Makro** tugmasi (kelajakda)
- Yuqorida **trackpad** joylashgan

### 2. Sichqoncha / Trackpad (Trackpad Screen)
- **Katta touchpad** — barmoq bilan suring, sichqoncha harakat qiladi
- **Scroll** — chap/o'ng yon scroll chiziqlar
- **Sol/O'ng tugma** — pastda 2 ta katta tugma

### 3. Multimedia (Multimedia Screen)
- **Ovoz**: o'chirish, kamaytirish, oshirish
- **Media**: oldingi, keyingi, orqaga, oldinga
- **Trackpad** — o'rtada mini trackpad
- **D-pad**: yuqori, pastga, chap, o'ng, OK
- **Play/Pause** — yashil katta tugma
- **Back / Home / Menu** — pastda

---

## 🔗 Qurilmaga Ulanish

1. AppBar'dagi qurilma nomiga bosing (yoki "Ulanish...")
2. **DeviceSelector** bottom sheet ochiladi
3. Bluetooth skanerlash avtomatik boshlanadi
4. Topilgan qurilmani tanlang → **"Ulash"** tugmasini bosing
5. Ulanganda: **yashil** bildirishnoma va qurilma nomi ko'rinadi
6. Ulanmagan holda klaviatura/sichqoncha bosilsa → **qizil** ogohlantirish chiqadi

---

## ⚠️ Muhim: HID Protokoli

Haqiqiy Bluetooth klaviatura/sichqoncha ishlashi uchun **Bluetooth HID** protokoli kerak.  
Flutter tomonidan bu to'liq qo'llab-quvvatlanmaydi — shuning uchun ikki yo'l bor:

### Yo'l A: Flutter Plugin (tavsiya etiladi)
`flutter_hid` yoki `bluetooth_hid` kutubxonasini ulang (experimental).

### Yo'l B: Native Android (ishonchli)
`BluetoothHidDevice` API orqali Java/Kotlin'da yozing:
```kotlin
// android/app/src/main/kotlin/MainActivity.kt
val hidDevice = BluetoothHidDevice(...)
hidDevice.sendReport(device, reportId, byteArray)
```
Flutter'dan `MethodChannel` orqali chaqiriladi:
```dart
const channel = MethodChannel('bt_hid');
await channel.invokeMethod('sendKey', {'keyCode': 0x04}); // 'a' harfi
```

---

## 🔑 HID Key Codes (asosiylar)

| Harf | HID Kod | Harf | HID Kod |
|------|---------|------|---------|
| a    | 0x04    | z    | 0x1D    |
| Enter| 0x28    | Space| 0x2C    |
| Esc  | 0x29    | Del  | 0x4C    |
| ↑    | 0x52    | ↓    | 0x51    |
| ←    | 0x50    | →    | 0x4F    |

---

## 🐛 Xatolar va Yechimlar

| Xato | Yechim |
|------|--------|
| "Bluetooth ruxsat yo'q" | Telefon sozlamalarida Bluetooth ruxsatini bering |
| Qurilmalar ko'rinmaydi | Location ruxsatini ham bering (Android talab qiladi) |
| Ulana olmayapdi | Qurilmada BT HID qo'llab-quvvatlanishini tekshiring |
| minSdk xatosi | `build.gradle`'da `minSdkVersion 21` qiling |
