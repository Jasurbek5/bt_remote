import 'package:flutter/material.dart';
import '../services/hid_service.dart';
import 'keyboard_screen.dart';
import 'trackpad_screen.dart';
import 'multimedia_screen.dart';
import '../widgets/device_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final HidService _hidService = HidService();

  // YANGI RANG PALETASI
  static const Color _primaryColor = Color(0xFF5E35B1); // Deep Indigo
  static const Color _scaffoldBg = Color(0xFFF4F7F9);
  static const Color _appBarBg = Colors.white;

  @override
  void initState() {
    super.initState();
    _hidService.addListener(_onChanged);
    _hidService.initialize();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _hidService.removeListener(_onChanged);
    super.dispose();
  }

  void _showDeviceSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeviceSelector(hidService: _hidService),
    );
  }

  String get _pageTitle {
    switch (_currentIndex) {
      case 0: return 'Klaviatura';
      case 1: return 'Sichqoncha';
      case 2: return 'Media Pult';
      default: return 'BT Remote';
    }
  }

  IconData get _pageIcon {
    switch (_currentIndex) {
      case 0: return Icons.keyboard_rounded;
      case 1: return Icons.mouse_rounded;
      case 2: return Icons.settings_input_component_rounded;
      default: return Icons.bluetooth_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      KeyboardScreen(hidService: _hidService),
      TrackpadScreen(hidService: _hidService),
      MultimediaScreen(hidService: _hidService),
    ];

    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: AppBar(
        backgroundColor: _appBarBg,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF263238)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _pageTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF263238),
                letterSpacing: -0.5,
              ),
            ),
            GestureDetector(
              onTap: _showDeviceSelector,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: _hidService.isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _hidService.connectedDeviceName ?? 'Ulanmagan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth_searching_rounded, color: _primaryColor),
            onPressed: _showDeviceSelector,
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: _buildDrawer(),
      body: screens[_currentIndex],
    );
  }

  Widget _buildDrawer() {
    final drawerItems = [
      _DrawerItem(
        icon: Icons.keyboard_rounded,
        title: 'Klaviatura',
        subtitle: 'HID klaviatura va trackpad',
        index: 0,
      ),
      _DrawerItem(
        icon: Icons.mouse_rounded,
        title: 'Sichqoncha',
        subtitle: 'Trackpad va tugmalar',
        index: 1,
      ),
      _DrawerItem(
        icon: Icons.settings_input_component_rounded,
        title: 'Media Pult',
        subtitle: 'TV/Media boshqaruvi',
        index: 2,
      ),
    ];

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, _primaryColor.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.bluetooth_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'BT Remote',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bluetooth HID Controller',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Ulanish holati
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _hidService.isConnected
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _hidService.isConnected
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                ),
              ),
              child: InkWell(
                onTap: _showDeviceSelector,
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: _hidService.isConnected ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _hidService.isConnected ? 'ULANGAN' : 'ULANMAGAN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              color: _hidService.isConnected ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                          if (_hidService.connectedDeviceName != null)
                            Text(
                              _hidService.connectedDeviceName!,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.bluetooth_searching_rounded,
                      size: 18,
                      color: _hidService.isConnected ? Colors.green : Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Navigatsiya elementlari
            ...drawerItems.map((item) => _buildDrawerTile(item)),

            const Spacer(),

            // Pastdagi tugmalar
            const Divider(height: 1),
            if (_hidService.isConnected)
              ListTile(
                leading: const Icon(Icons.bluetooth_disabled_rounded, color: Colors.redAccent, size: 22),
                title: const Text('Ulanishni uzish', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                onTap: () {
                  _hidService.disconnect();
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: Icon(Icons.info_outline_rounded, color: Colors.grey.shade600, size: 22),
              title: const Text('Dastur haqida', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile(_DrawerItem item) {
    final isSelected = _currentIndex == item.index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? _primaryColor.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: isSelected ? _primaryColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            item.icon,
            color: isSelected ? Colors.white : Colors.grey.shade600,
            size: 20,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 15,
            color: isSelected ? _primaryColor : const Color(0xFF263238),
          ),
        ),
        subtitle: Text(
          item.subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  color: _primaryColor,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: () {
          setState(() => _currentIndex = item.index);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final int index;

  _DrawerItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.index,
  });
}
