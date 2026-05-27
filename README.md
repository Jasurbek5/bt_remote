# BT Remote — Bluetooth HID Keyboard, Mouse & Media Controller

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Kotlin-0095D5?style=for-the-badge&logo=kotlin&logoColor=white" alt="Kotlin" />
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/Bluetooth-0082FC?style=for-the-badge&logo=bluetooth&logoColor=white" alt="Bluetooth HID" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License" />
</p>

---

## 🌐 Language Options / Til Tanlash
* [English Version (Scroll down or click here)](#-english-version)
* [O'zbekcha Talqini (Pastga tushing yoki bu yerga bosing)](#-ozbekcha-talqini)

---

# 🇬🇧 English Version

**BT Remote** is a powerful, modern, open-source Flutter application that transforms your Android device into a **wireless Bluetooth HID Keyboard, Mouse (Trackpad), and Media Remote Controller**.

Unlike traditional remote control apps, **BT Remote requires ABSOLUTELY NO server software, companion apps, or clients installed on your PC/TV**. It emulates a physical Bluetooth hardware device (like a real USB/Bluetooth keyboard or mouse) directly via Android's native Bluetooth HID profile. Simply pair your phone to your PC, Mac, TV, Linux machine, or game console, and you're ready to go!

---

## ✨ Features

### 1. ⌨️ Full PC Keyboard
* **Complete QWERTY Keyboard** layout with direct keys.
* **Function Keys (F1 - F12)**, **Escape**, **Tab**, **Backspace**, **Delete**, and Arrow keys.
* **Modifier Keys Support**: Full support for `Shift`, `Ctrl`, `Alt`, and `GUI` (Windows/Command key).
* **Multi-Language Text Input**: Send entire text lines dynamically using native character mappings.
* **Mini Trackpad**: Integrated directly above the keyboard layout for seamless navigation without switching screens.

### 2. 🖱️ Fluid Trackpad & Mouse Emulation
* **Large Touchpad Space** for comfortable finger navigation.
* **Smooth Mouse Motion**: Optimized cursor movement utilizing an advanced throttling algorithm to prevent stuttering.
* **Left & Right Click Buttons**: Large, responsive buttons at the bottom of the screen.
* **Dedicated Scroll Bar**: Precise vertical scrolling strip on the side for reading documents or browsing web pages.

### 3. 📺 Smart Multimedia Remote
* **TV/Media D-Pad Layout**: Large tactile Navigation Keys (Up, Down, Left, Right, OK) to navigate menus.
* **Volume Control**: Mute, Volume Up, and Volume Down buttons.
* **Playback Controls**: Play/Pause, Stop, Previous Track, Next Track, Fast Forward, and Rewind.
* **System Shortcuts**: Direct buttons for `Power`, `Menu`, `Back`, and `Home` keys.

### 4. 🧭 Modern Navigation & UI
* **Material 3 Design**: Visually stunning, dark-themed UI featuring modern gradients, clean alignment, and glassmorphic details.
* **Interactive Navigation Drawer**: Connection states, beautiful header design, and clean menu navigation to hop between screens easily.
* **Smart Device Connection Status**: Real-time status in the Drawer and AppBar showing if you are connected or disconnected.

---

## 🛠️ How It Works (Technical Overview)

This app works on the native **Bluetooth HID (Human Interface Device) Profile** via Flutter's `MethodChannel` and `EventChannel` communicating with native Android Kotlin code. 

```
┌──────────────────┐               MethodChannel               ┌─────────────────────┐
│  Flutter UI      │  ────────── sendKey/Mouse ──────────────> │ Kotlin MainActivity │
│  (Dart Logic)    │  <───────── Connection Events ──────────  │ & HidDeviceService  │
└──────────────────┘               EventChannel                └─────────────────────┘
                                                                          │
                                                                   Bluetooth HID
                                                                          │
                                                                          ▼
                                                              ┌─────────────────────┐
                                                              │ Target Device       │
                                                              │ (PC, Mac, Smart TV) │
                                                              └─────────────────────┘
```

### 1. The HID Descriptor
On the native Android layer (`HidDeviceService.kt`), a custom HID Report Descriptor is registered with the Bluetooth SDP (Service Discovery Protocol). It supports three report IDs:

1. **Keyboard (Report ID 1)**: Sends 8-byte reports matching standard USB boot keyboard protocols (1 byte modifier keys, 1 byte reserved, 6 bytes active keycodes).
2. **Mouse (Report ID 2)**: Sends 4-byte reports (1 byte buttons state, 1 byte relative dX, 1 byte relative dY, 1 byte scroll wheel).
3. **Consumer Control (Report ID 3)**: Sends 2-byte reports containing 16-bit consumer control codes (like Play, Pause, Vol Up/Down) matching the Consumer Usage Page (`0x0C`).

### 2. High-Performance Throttling
For mouse input, cursor position updates generate hundreds of gestures per second. To prevent Bluetooth buffer congestion and UI stuttering, `trackpad_widget.dart` uses a smart throttle timer that bundles and sends mouse events optimally:
```dart
_moveThrottle ??= Timer(const Duration(milliseconds: 15), () {
  // Bundled coordinate offsets are sent via MethodChannel
  HidService().sendMouse(buttons: _buttonsState, dx: accumulatedDx, dy: accumulatedDy);
  // Reset accumulator
});
```

---

## ⚙️ Prerequisites & System Requirements

* **Android 12+ (API 31+)**: The native Android `BluetoothHidDevice` API is fully supported on modern Android versions.
* **Device Bluetooth Profile Support**: Your Android phone's hardware/OS firmware must support the Bluetooth HID Peripheral profile (most modern smartphones do).
* **Flutter SDK**: `>=3.10.0`
* **Dart SDK**: `>=3.0.0 <4.0.0`

---

## 📥 Installation & Setup

To build and run this application locally on your machine:

### 1. Clone the Repository
```bash
git clone https://github.com/Jasurbek5/bt_remote.git
cd bt_remote
```

### 2. Fetch Flutter Dependencies
```bash
flutter pub get
```

### 3. Build & Run
Connect your Android device (with USB debugging enabled) and run:
```bash
flutter run
```

---

## 🔒 Permissions & Security

We value user privacy! The application only requests necessary Bluetooth permissions on Android 12+ (API 31+):
* `BLUETOOTH_CONNECT`: Needed to connect to bonded devices.
* `BLUETOOTH_SCAN`: Needed to find nearby Bluetooth devices.

> [!NOTE]
> **No Location Permission (`ACCESS_FINE_LOCATION`) is required!** Because the app relies entirely on already **bonded (paired) Bluetooth devices** to make HID connections, we removed coarse/fine location permission scans entirely, making the app much more private and lightweight.

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📜 License

Distributed under the **MIT License**. See `LICENSE` for more information.

---

## 👨‍💻 Developer & Contacts

**Jasurbek Rahimov** — *Lead Mobile & Native Android Developer*

If you have any questions, feedback, or want to contribute to this project, feel free to reach out:

* **GitHub**: [@Jasurbek5](https://github.com/Jasurbek5)
* **Instagram**: [@the_jasur_2005](https://instagram.com/the_jasur_2005)
* **Email**: [rahimovjasurbek885@gmail.com](mailto:rahimovjasurbek885@gmail.com)

---
---

# 🇺🇿 O'zbekcha

**BT Remote** — bu Android qurilmangizni **simsiz Bluetooth HID klaviatura, sichqoncha (trackpad) va multimedia masofaviy boshqaruv pulti**ga aylantiradigan kuchli, zamonaviy va ochiq kodli Flutter ilovasi.

Boshqa pult ilovalaridan farqli o'laroq, **BT Remote sizning kompyuteringiz yoki televizoringizga hech qanday server yoki maxsus dastur o'rnatishni talab qilmaydi**. Ilova Android-ning native Bluetooth HID profili orqali to'g'ridan-to'g'ri jismoniy Bluetooth qurilmasini (xuddi haqiqiy USB/Bluetooth klaviatura yoki sichqonchadek) simulyatsiya qiladi. Telefoningizni kompyuter (PC, Mac, Linux), Smart TV yoki o'yin konsoliga Bluetooth orqali ulashingiz kifoya!

---

## ✨ Imkoniyatlar

### 1. ⌨️ To'liq kompyuter klaviaturasi
* To'liq **QWERTY klaviatura** tartibi.
* **F1 - F12 funksional tugmalari**, **Escape**, **Tab**, **Backspace**, **Delete** va yo'nalish ko'rsatkichlari.
* **Modifikator tugmalar**: `Shift`, `Ctrl`, `Alt` va `GUI` (Windows/Command tugmasi) birgalikda mukammal ishlaydi.
* **Ko'p tilli matn kiritish**: Alohida harflarni native kodlar yordamida tezkor ravishda jo'natish.
* **Mini Trackpad**: Ekranni o'zgartirmasdan turib boshqarish uchun klaviaturaning yuqori qismiga o'rnatilgan ixcham trackpad.

### 2. 🖱️ Silliq Trackpad & Sichqoncha Emulyatsiyasi
* Barmoq bilan qulay harakatlantirish uchun **Katta Sensorli Panel (Touchpad)**.
* **Silliq sichqoncha harakati**: Sichqoncha ko'rsatkichi qotib-qotib qolmasdan ravon harakatlanishi uchun maxsus **throttling algoritmi** bilan optimallashtirilgan.
* **Chap va O'ng tugmalar**: Ekran pastki qismida joylashgan katta va sezgir tugmalar.
* **Maxsus Scroll chizig'i**: Hujjatlar yoki veb-sahifalarni oson varaqlash uchun o'ng yon tomondagi aylantirish chizig'i.

### 3. 📺 Smart Multimedia Pulti
* **Televizor/Media D-Pad tartibi**: Menyularda osongina harakatlanish uchun katta boshqaruv tugmalari (Tepaga, Pastga, Chapga, O'ngga, OK).
* **Ovoz Boshqaruvi**: Ovozni o'chirish (Mute), balandlatish va pasaytirish tugmalari.
* **Media Boshqaruvi**: Play/Pause, Stop, Oldingi/Keyingi trek, tezkor orqaga/oldinga o'tkazish.
* **Tizim tugmalari**: `Power` (O'chirish), `Menu`, `Back` (Orqaga) va `Home` (Bosh ekran) tugmalari.

### 4. 🧭 Zamonaviy Navigatsiya & UI
* **Material 3 Dizayn**: Chiroyli gradientlar, to'q fon va shaffof (glassmorphism) elementlar.
* **Zamonaviy Drawer menyusi**: Ulanish holati, chiroyli sarlavha va ekranlararo oson o'tish uchun qulay menyu.
* **Ulanish holatini real vaqtda ko'rsatish**: Drawer va ilova sarlavhasida (AppBar) qurilma ulanishi yoki uzilgani darhol aks etadi.

---

## 🛠️ Qanday Ishlaydi (Texnik Sharh)

Ilova Android-ning native **Bluetooth HID (Human Interface Device) profili** asosida ishlaydi. Flutter (`Dart`) qismi `MethodChannel` va `EventChannel` orqali native Android (`Kotlin`) kodiga buyruqlar yuboradi va ulanish holatini nazorat qiladi.

```
┌──────────────────┐               MethodChannel               ┌─────────────────────┐
│  Flutter UI      │  ────────── sendKey/Mouse ──────────────> │ Kotlin MainActivity │
│  (Dart Logic)    │  <───────── Connection Events ──────────  │ & HidDeviceService  │
└──────────────────┘               EventChannel                └─────────────────────┘
                                                                          │
                                                                   Bluetooth HID
                                                                          │
                                                                          ▼
                                                              ┌─────────────────────┐
                                                              │ Target Device       │
                                                              │ (PC, Mac, Smart TV) │
                                                              └─────────────────────┘
```

### 1. HID Deskriptor tuzilishi
Android qismida (`HidDeviceService.kt`), Bluetooth SDP tizimida maxsus HID Report Descriptor ro'yxatdan o'tkaziladi. U 3 ta Report ID'ga ega:

1. **Keyboard (Report ID 1)**: Standart USB boot klaviaturaga mos keluvchi 8 baytlik paketlarni yuboradi (1 bayt modifikatorlar, 1 bayt zaxira, 6 bayt faol tugma kodlari).
2. **Mouse (Report ID 2)**: 4 baytlik paket yuboradi (1 bayt tugmalar holati, 1 bayt nisbiy X siljishi, 1 bayt nisbiy Y siljishi, 1 bayt skrol).
3. **Consumer Control (Report ID 3)**: Televizor yoki multimedia boshqaruvi uchun 2 baytlik paketda 16-bitli buyruq kodlarini (Play, Pause, Vol Up/Down) yuboradi (Consumer Usage Page `0x0C`).

### 2. Yuqori unumdorlik va Silliqlik (Throttling)
Sichqoncha harakatlanganda soniyasiga yuzlab koordinata yangilanishlari yuzaga keladi. Bluetooth kanalini tiqilib qolishdan va sichqoncha qotishidan saqlash uchun `trackpad_widget.dart` maxsus taymer orqali paketlarni birlashtirib jo'natadi:
```dart
_moveThrottle ??= Timer(const Duration(milliseconds: 15), () {
  // Koordinata o'zgarishlari yig'ilib MethodChannel orqali yuboriladi
  HidService().sendMouse(buttons: _buttonsState, dx: accumulatedDx, dy: accumulatedDy);
  // Yig'gichni tozalash
});
```

---

## ⚙️ Tizim Talablari

* **Android 12+ (API 31+)**: Native `BluetoothHidDevice` API faqat zamonaviy Android versiyalarida to'liq ishlaydi.
* **Qurilmada HID qo'llab-quvvatlanishi**: Telefoningiz proshivkasi/apparat qismi Bluetooth HID Peripheral rejimini qo'llab-quvvatlashi zarur.
* **Flutter SDK**: `>=3.10.0`
* **Dart SDK**: `>=3.0.0 <4.0.0`

---

## 📥 Loyihani O'rnatish & Ishga Tushirish

Loyihani o'z kompyuteringizda yig'ish va ishga tushirish uchun:

### 1. Repozitoriyani yuklab oling
```bash
git clone https://github.com/Jasurbek5/bt_remote.git
cd bt_remote
```

### 2. Flutter paketlarni o'rnating
```bash
flutter pub get
```

### 3. Ishga tushiring
Android qurilmangizni ulang (USB debugging yoqilgan holda) va quyidagilarni bajaring:
```bash
flutter run
```

---

## 🔒 Ruxsatnomalar va Xavfsizlik

Foydalanuvchi maxfiyligi biz uchun juda muhim! Ilova Android 12+ (API 31+) tizimida faqat eng zarur ruxsatlarni so'raydi:
* `BLUETOOTH_CONNECT`: Juftlangan qurilmalarga ulanish uchun.
* `BLUETOOTH_SCAN`: Bluetooth qurilmalarini aniqlash uchun.

> [!NOTE]
> **Joylashuv Ruxsati (`ACCESS_FINE_LOCATION`) talab qilinmaydi!** Chunki dastur faqat **juftlangan (paired) Bluetooth qurilmalar** bilan ishlaydi. Skanerlash va joylashuv ruxsatlarini olib tashlash orqali ilovani xavfsizroq va yengilroq qildik.

---

## 👨‍💻 Dasturchi & Kontaktlar

**Jasurbek Rahimov** — *Lead Mobile & Native Android Developer*

Savollar, takliflar yoki loyihaga hissa qo'shish istagi bo'lsa, quyidagi tarmoqlar orqali bog'lanishingiz mumkin:

* **GitHub**: [@Jasurbek5](https://github.com/Jasurbek5)
* **Instagram**: [@the_jasur_2005](https://instagram.com/the_jasur_2005)
* **Email**: [rahimovjasurbek885@gmail.com](mailto:rahimovjasurbek885@gmail.com)

---

## 📜 Litsenziya

Ushbu loyiha **MIT License** ostida tarqatiladi. Batafsil ma'lumotni `LICENSE` faylida ko'rishingiz mumkin.
