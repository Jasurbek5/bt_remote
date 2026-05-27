import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/hid_service.dart';
import '../widgets/trackpad_widget.dart';

class MultimediaScreen extends StatefulWidget {
  final HidService hidService;
  const MultimediaScreen({super.key, required this.hidService});

  @override
  State<MultimediaScreen> createState() => _MultimediaScreenState();
}

class _MultimediaScreenState extends State<MultimediaScreen> {
  // YANGI RANG PALETASI
  static const Color _primaryColor = Color(0xFF5E35B1); // Deep Indigo
  static const Color _secondaryColor = Color(0xFF455A64); // Slate Blue/Gray
  static const Color _accentColor = Color(0xFF00BFA5); // Teal accent (for OK/Play)
  
  ScrollPhysics _scrollPhysics = const BouncingScrollPhysics();

  Future<void> _send(BuildContext context, String label, int code) async {
    if (!widget.hidService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.bluetooth_disabled_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text('$label: Avval Bluetooth qurilmaga ulaning!'),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    await widget.hidService.sendMedia(code);
  }

  Widget _btn(BuildContext context,
      {required IconData icon, required String label, required int code,
      Color? color, double size = 28}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _send(context, label, code),
        child: Container(
          height: 60,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color ?? _primaryColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (color ?? _primaryColor).withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }

  Widget _navBtn(BuildContext context,
      {required IconData icon, required String label, required int code}) {
    return GestureDetector(
      onTap: () => _send(context, label, code),
      child: Container(
        width: 80, height: 64,
        decoration: BoxDecoration(
          color: _secondaryColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: _scrollPhysics,
      child: Column(
        children: [
          // Ovoz + Power
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                _btn(context, icon: Icons.mic_rounded, label: 'Mic',
                    code: 0x00CF, color: const Color(0xFF78909C)),
                _btn(context, icon: Icons.volume_off_rounded, label: 'Mute',
                    code: MediaCode.mute, color: const Color(0xFF78909C)),
                _btn(context, icon: Icons.volume_down_rounded, label: 'Vol-',
                    code: MediaCode.volDown),
                _btn(context, icon: Icons.volume_up_rounded, label: 'Vol+',
                    code: MediaCode.volUp),
                _btn(context, icon: Icons.power_settings_new_rounded, label: 'Power',
                    code: MediaCode.power, color: Colors.redAccent.shade400),
              ],
            ),
          ),
          // Media boshqaruv
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
            child: Row(
              children: [
                _btn(context, icon: Icons.skip_previous_rounded, label: 'Prev',
                    code: MediaCode.prevTrack),
                _btn(context, icon: Icons.skip_next_rounded, label: 'Next',
                    code: MediaCode.nextTrack),
                _btn(context, icon: Icons.fast_rewind_rounded, label: 'Rew',
                    code: MediaCode.rewind),
                _btn(context, icon: Icons.fast_forward_rounded, label: 'Fwd',
                    code: MediaCode.fastForward),
              ],
            ),
          ),
          
          // Trackpad
          Listener(
            onPointerDown: (_) => setState(() => _scrollPhysics = const NeverScrollableScrollPhysics()),
            onPointerUp: (_) => setState(() => _scrollPhysics = const BouncingScrollPhysics()),
            onPointerCancel: (_) => setState(() => _scrollPhysics = const BouncingScrollPhysics()),
            child: Container(
              height: 220,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: TrackpadWidget(
                  hidService: widget.hidService,
                  showScrollBars: true,
                ),
              ),
            ),
          ),

          // D-pad
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                _navBtn(context, icon: Icons.keyboard_arrow_up_rounded,
                    label: 'Up', code: MediaCode.arrowUp),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _navBtn(context, icon: Icons.keyboard_arrow_left_rounded,
                        label: 'Left', code: MediaCode.arrowLeft),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _send(context, 'OK', MediaCode.ok),
                      child: Container(
                        width: 80, height: 64,
                        decoration: BoxDecoration(
                          color: _accentColor,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: _accentColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text('OK',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _navBtn(context, icon: Icons.keyboard_arrow_right_rounded,
                        label: 'Right', code: MediaCode.arrowRight),
                  ],
                ),
                const SizedBox(height: 8),
                _navBtn(context, icon: Icons.keyboard_arrow_down_rounded,
                    label: 'Down', code: MediaCode.arrowDown),
              ],
            ),
          ),
          
          // Play/Pause
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () => _send(context, 'Play/Pause', MediaCode.playPause),
              child: Container(
                width: double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _primaryColor.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                    Icon(Icons.pause_rounded, color: Colors.white, size: 32),
                    SizedBox(width: 8),
                    Text('PLAY / PAUSE',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2)),
                  ],
                ),
              ),
            ),
          ),
          
          // Back / Home / Menu
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            child: Row(
              children: [
                Expanded(child: _bottomBtn(context, 'BACK', MediaCode.back, Icons.arrow_back_ios_new_rounded)),
                Expanded(child: _bottomBtn(context, 'HOME', MediaCode.home, Icons.home_rounded)),
                Expanded(child: _bottomBtn(context, 'MENU', MediaCode.menu, Icons.menu_rounded)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBtn(BuildContext context, String label, int code, IconData icon) {
    return GestureDetector(
      onTap: () => _send(context, label, code),
      child: Container(
        height: 56,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: _secondaryColor),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: _secondaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
