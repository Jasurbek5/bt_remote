import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/hid_service.dart';
import '../widgets/trackpad_widget.dart';

class TrackpadScreen extends StatelessWidget {
  final HidService hidService;
  const TrackpadScreen({super.key, required this.hidService});

  // PROFESSIONAL INDIGO PALITRASI
  static const Color _primaryColor = Color(0xFF5E35B1);
  static const Color _scaffoldBg = Color(0xFFF8F9FA);

  Future<void> _click(BuildContext context, int button) async {
    if (!hidService.isConnected) {
      _showNotConnectedSnack(context);
      return;
    }
    HapticFeedback.heavyImpact();
    // Tugmani bosish
    await hidService.sendMouse(buttons: button);
    // Biroz kutib qo'yib yuborish
    await Future.delayed(const Duration(milliseconds: 80));
    await hidService.sendMouse(buttons: 0);
  }

  void _showNotConnectedSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.bluetooth_disabled_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('Qurilma ulanmagan!', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _scaffoldBg,
      child: Column(
        children: [
          // Trackpad Maydoni
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: TrackpadWidget(
                    hidService: hidService,
                    showScrollBars: true,
                  ),
                ),
              ),
            ),
          ),
          
          // Sichqoncha tugmalari
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildMouseButton(
                    context,
                    label: 'CHAP',
                    icon: Icons.mouse_rounded,
                    isPrimary: true,
                    onTap: () => _click(context, 1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMouseButton(
                    context,
                    label: 'O\'NG',
                    icon: Icons.ads_click_rounded,
                    isPrimary: false,
                    onTap: () => _click(context, 2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMouseButton(BuildContext context, {
    required String label, 
    required IconData icon, 
    required bool isPrimary, 
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isPrimary ? _primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isPrimary ? null : Border.all(color: _primaryColor.withValues(alpha: 0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: isPrimary ? _primaryColor.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: isPrimary ? Colors.white : _primaryColor, 
              size: 22
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : _primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
