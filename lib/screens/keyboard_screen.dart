import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/hid_service.dart';
import '../widgets/trackpad_widget.dart';

class KeyboardScreen extends StatefulWidget {
  final HidService hidService;
  const KeyboardScreen({super.key, required this.hidService});

  @override
  State<KeyboardScreen> createState() => _KeyboardScreenState();
}

class _KeyboardScreenState extends State<KeyboardScreen> {
  static const Color _primaryColor = Color(0xFF5E35B1);
  static const Color _keyActiveColor = Color(0xFF5E35B1);
  static const Color _keyBgColor = Colors.white;
  static const Color _specialKeyBg = Color(0xFFE8EAF6);

  bool _capsLock = false;
  bool _shift = false;
  String _selectedLang = 'English US';
  final TextEditingController _textController = TextEditingController();

  final List<String> _languages = [
    'English US', 'Русский', '한국어 (Korean)', 'عربي (Arabic)', 'हिन्दी (Hindi)', '中文 (Chinese)'
  ];

  // Tillarga mos klaviatura xaritalari
  final Map<String, List<List<String>>> _layouts = {
    'English US': [
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '\\'],
      ['z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/']
    ],
    'Русский': [
      ['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ'],
      ['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э', '\\'],
      ['я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю', '.']
    ],
    '한국어 (Korean)': [
      ['ㅂ', 'ㅈ', 'ㄷ', 'ㄱ', 'ㅅ', 'ㅛ', 'ㅕ', 'ㅑ', 'ㅐ', 'ㅔ', '[', ']'],
      ['ㅁ', 'ㄴ', 'ㅇ', 'ㄹ', 'ㅎ', 'ㅗ', 'ㅓ', 'ㅏ', 'ㅣ', ';', "'", '\\'],
      ['ㅋ', 'ㅌ', 'ㅊ', 'ㅍ', 'ㅠ', 'ㅜ', 'ㅡ', ',', '.', '/']
    ],
    'عربي (Arabic)': [
      ['ض', 'ص', 'ث', 'ق', 'ف', 'غ', 'ع', 'ه', 'خ', 'ح', 'ج', 'د'],
      ['ش', 'س', 'ي', 'ب', 'ل', 'ا', 'ت', 'ن', 'م', 'ك', 'ط', 'ذ'],
      ['ئ', 'ء', 'ؤ', 'ر', 'لا', 'ى', 'ة', 'و', 'ز', 'ظ']
    ],
    'हिन्दी (Hindi)': [
      ['ौ', 'ै', 'ा', 'ी', 'ू', 'ब', 'ह', 'ग', 'द', 'ज', 'ड', 'ृ'],
      ['ो', 'े', '्', 'ि', 'ु', 'प', 'र', 'क', 'त', 'च', 'ट', '़'],
      ['ॄ', 'अ', 'इ', 'उ', 'ए', 'न', 'म', 'ल', 'स', 'य']
    ],
    '中文 (Chinese)': [
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '\\'],
      ['z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/']
    ],
  };

  // Belgilarni HID US QWERTY pozitsiyasiga moslash
  static const Map<String, String> _charToUS = {
    'й': 'q', 'ц': 'w', 'у': 'e', 'к': 'r', 'е': 't', 'н': 'y', 'г': 'u', 'ш': 'i', 'щ': 'o', 'з': 'p', 'х': '[', 'ъ': ']',
    'ф': 'a', 'ы': 's', 'в': 'd', 'а': 'f', 'п': 'g', 'р': 'h', 'о': 'j', 'л': 'k', 'д': 'l', 'ж': ';', 'э': "'",
    'я': 'z', 'ч': 'x', 'с': 'c', 'м': 'v', 'и': 'b', 'т': 'n', 'ь': 'm', 'б': ',', 'ю': '.',
    'ض': 'q', 'ص': 'w', 'ث': 'e', 'ق': 'r', 'ف': 't', 'غ': 'y', 'ع': 'u', 'ه': 'i', 'خ': 'o', 'ح': 'p', 'ج': '[', 'د': ']',
    'ش': 'a', 'س': 's', 'ي': 'd', 'ب': 'f', 'ل': 'g', 'ا': 'h', 'ت': 'j', 'ن': 'k', 'م': 'l', 'ك': ';', 'ط': "'", 'ذ': '\\',
    'ئ': 'z', 'ء': 'x', 'ؤ': 'c', 'ر': 'v', 'لا': 'b', 'ى': 'n', 'ة': 'm', 'و': ',', 'ز': '.', 'ظ': '/',
    'ㅂ': 'q', 'ㅈ': 'w', 'ㄷ': 'e', 'ㄱ': 'r', 'ㅅ': 't', 'ㅛ': 'y', 'ㅕ': 'u', 'ㅑ': 'i', 'ㅐ': 'o', 'ㅔ': 'p',
    'ㅁ': 'a', 'ㄴ': 's', 'ㅇ': 'd', 'ㄹ': 'f', 'ㅎ': 'g', 'ㅗ': 'h', 'ㅓ': 'j', 'ㅏ': 'k', 'ㅣ': 'l',
    'ㅋ': 'z', 'ㅌ': 'x', 'ㅊ': 'c', 'ㅍ': 'v', 'ㅠ': 'b', 'ㅜ': 'n', 'ㅡ': 'm',
  };

  static const Map<String, int> _specialKeyCodes = {
    'Esc': KeyCode.escape, 'F1': KeyCode.f1, 'F2': KeyCode.f2, 'F3': KeyCode.f3,
    'F4': KeyCode.f4, 'F5': KeyCode.f5, 'F6': KeyCode.f6, 'F7': KeyCode.f7,
    'F8': KeyCode.f8, 'F9': KeyCode.f9, 'F10': KeyCode.f10, 'F11': KeyCode.f11,
    'F12': KeyCode.f12, 'Del': KeyCode.delete, '⌫': KeyCode.backspace,
    'Tab': KeyCode.tab, 'Caps': KeyCode.capsLock, 'Enter': KeyCode.enter,
    'Space': KeyCode.space, '←': KeyCode.arrowLeft, '→': KeyCode.arrowRight,
    '↑': KeyCode.arrowUp, '↓': KeyCode.arrowDown,
  };

  Future<void> _sendKey(String key) async {
    if (!widget.hidService.isConnected) { _showNotConnectedSnack(); return; }
    HapticFeedback.lightImpact();

    if (key == 'Caps') {
      setState(() => _capsLock = !_capsLock);
      await widget.hidService.sendKey(keyCodes: [KeyCode.capsLock]);
      await Future.delayed(const Duration(milliseconds: 20));
      await widget.hidService.sendKey(keyCodes: []);
      return;
    }

    int modifier = KeyMod.none;
    if (_shift) modifier |= KeyMod.lShift;

    if (_specialKeyCodes.containsKey(key)) {
      await widget.hidService.sendKey(keyCodes: [_specialKeyCodes[key]!]);
      await Future.delayed(const Duration(milliseconds: 20));
      await widget.hidService.sendKey(keyCodes: []);
    } else {
      String targetChar = _charToUS[key] ?? key;
      if (_capsLock && targetChar.length == 1 && RegExp(r'[a-zA-Z]').hasMatch(targetChar)) {
        modifier |= KeyMod.lShift;
      }
      int code = KeyCode.fromChar(targetChar.toLowerCase(), false);
      if (code != KeyCode.none) {
        await widget.hidService.sendKey(modifier: modifier, keyCodes: [code]);
        await Future.delayed(const Duration(milliseconds: 20));
        await widget.hidService.sendKey(modifier: modifier, keyCodes: []);
      }
    }
    if (_shift) setState(() => _shift = false);
  }

  Future<void> _sendFullText(String text) async {
    if (text.isEmpty) return;
    if (!widget.hidService.isConnected) { _showNotConnectedSnack(); return; }
    await widget.hidService.sendText(text);
    if (!mounted) return;
    _textController.clear();
    FocusScope.of(context).unfocus();
  }

  void _showNotConnectedSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Qurilma ulanmagan!'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildKey(String label, {int flex = 1, Color? bg, Color? textColor, VoidCallback? onTapOverride, bool expanded = true}) {
    String display = (_capsLock || _shift) && label.length == 1 ? label.toUpperCase() : label;
    Widget keyWidget = GestureDetector(
      onTap: onTapOverride ?? () => _sendKey(label),
      child: Container(
        height: 46,
        margin: const EdgeInsets.all(0.8),
        decoration: BoxDecoration(
          color: bg ?? _keyBgColor,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1, offset: Offset(0, 1))],
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              display,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor ?? const Color(0xFF37474F)),
            ),
          ),
        ),
      ),
    );

    if (expanded) {
      return Expanded(
        flex: flex,
        child: keyWidget,
      );
    }
    return keyWidget;
  }

  @override
  Widget build(BuildContext context) {
    final currentLayout = _layouts[_selectedLang] ?? _layouts['English US']!;

    return Column(
      children: [
        // Trackpad
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: TrackpadWidget(hidService: widget.hidService, showScrollBars: true),
            ),
          ),
        ),

        // Matn yuborish (Smart Input)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Matnni yozib bittada yuboring...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: _sendFullText,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: _primaryColor),
                onPressed: () => _sendFullText(_textController.text),
              ),
            ],
          ),
        ),

        // Til va Status paneli
        Container(
          color: const Color(0xFFF5F7FA),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              ActionChip(
                avatar: const Icon(Icons.language_rounded, size: 16, color: Colors.white),
                label: Text(_selectedLang, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                backgroundColor: _primaryColor,
                onPressed: _showLangPicker,
                padding: EdgeInsets.zero,
              ),
              const Spacer(),
              _statusIndicator('Shift', _shift),
              const SizedBox(width: 8),
              _statusIndicator('Caps', _capsLock),
            ],
          ),
        ),

        // Klaviatura qismi
        Container(
          color: const Color(0xFFDDE2E8),
          padding: const EdgeInsets.fromLTRB(2, 2, 2, 8),
          child: Column(
            children: [
              // Function Keys
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Esc', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 'Del']
                      .map((k) => Container(
                            width: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 0.5),
                            child: _buildKey(k, bg: _specialKeyBg, expanded: false),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 2),
              // Row 1
              Row(children: [
                _buildKey('Tab', flex: 3, bg: _specialKeyBg),
                ...currentLayout[0].map((k) => _buildKey(k, flex: 2)),
                _buildKey('⌫', flex: 3, bg: _specialKeyBg),
              ]),
              // Row 2
              Row(children: [
                _buildKey('Caps', flex: 4, bg: _capsLock ? _keyActiveColor : _specialKeyBg, textColor: _capsLock ? Colors.white : null, onTapOverride: () => setState(() => _capsLock = !_capsLock)),
                ...currentLayout[1].map((k) => _buildKey(k, flex: 3)),
                _buildKey('Enter', flex: 4, bg: _specialKeyBg),
              ]),
              // Row 3
              Row(children: [
                _buildKey('Shift', flex: 4, bg: _shift ? _keyActiveColor : _specialKeyBg, textColor: _shift ? Colors.white : null, onTapOverride: () => setState(() => _shift = !_shift)),
                ...currentLayout[2].map((k) => _buildKey(k, flex: 3)),
                _buildKey('↑', flex: 2),
                _buildKey('Shift', flex: 4, bg: _shift ? _keyActiveColor : _specialKeyBg, textColor: _shift ? Colors.white : null, onTapOverride: () => setState(() => _shift = !_shift)),
              ]),
              // Bottom Row
              Row(children: [
                _buildKey('Ctrl', flex: 6, bg: _specialKeyBg),
                _buildKey('Win', flex: 5, bg: _specialKeyBg),
                _buildKey('Alt', flex: 5, bg: _specialKeyBg),
                _buildKey('Space', flex: 18),
                _buildKey('←', flex: 4),
                _buildKey('↓', flex: 4),
                _buildKey('→', flex: 4),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusIndicator(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: active ? _primaryColor.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? _primaryColor : Colors.grey.shade300),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active ? _primaryColor : Colors.grey)),
    );
  }

  void _showLangPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Klaviatura tilini tanlang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _languages.map((l) => ListTile(
                  leading: const Icon(Icons.language_rounded, color: _primaryColor),
                  title: Text(l, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: _selectedLang == l ? const Icon(Icons.check_circle, color: _primaryColor) : null,
                  onTap: () { setState(() => _selectedLang = l); Navigator.pop(context); },
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
