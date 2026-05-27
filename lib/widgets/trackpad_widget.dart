import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/hid_service.dart';

class TrackpadWidget extends StatefulWidget {
  final HidService hidService;
  final bool showScrollBars;
  final bool showMouseButtons;

  const TrackpadWidget({
    super.key,
    required this.hidService,
    this.showScrollBars = true,
    this.showMouseButtons = false,
  });

  @override
  State<TrackpadWidget> createState() => _TrackpadWidgetState();
}

class _TrackpadWidgetState extends State<TrackpadWidget> {
  // YANGI RANG: Slate Gray / Deep Blue-Grey
  static const Color _trackpadColor = Color(0xFF263238); 

  static const double _sensitivity = 1.5;
  static const double _scrollSensitivity = 0.3;

  double _accumX = 0.0;
  double _accumY = 0.0;

  Timer? _moveThrottle;
  int _pendingDx = 0;
  int _pendingDy = 0;

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.hidService.isConnected) return;

    _accumX += details.delta.dx * _sensitivity;
    _accumY += details.delta.dy * _sensitivity;

    final dx = _accumX.truncate();
    final dy = _accumY.truncate();

    if (dx != 0 || dy != 0) {
      _accumX -= dx;
      _accumY -= dy;
      _pendingDx += dx;
      _pendingDy += dy;

      // Timer allaqachon ishlayotgan bo'lsa, faqat pending qiymatlarni to'playmiz
      // Timer tugaganda o'zi yuboradi
      _moveThrottle ??= Timer(const Duration(milliseconds: 8), _flushMouseMove);
    }
  }

  void _flushMouseMove() {
    _moveThrottle = null;
    if (_pendingDx != 0 || _pendingDy != 0) {
      widget.hidService.sendMouse(
        dx: _pendingDx.clamp(-127, 127),
        dy: _pendingDy.clamp(-127, 127),
      );
      _pendingDx = 0;
      _pendingDy = 0;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _accumX = 0;
    _accumY = 0;
    _pendingDx = 0;
    _pendingDy = 0;
    _moveThrottle?.cancel();
  }

  void _onScrollUpdate(DragUpdateDetails details) {
    if (!widget.hidService.isConnected) return;
    final scroll = (-details.delta.dy * _scrollSensitivity).truncate();
    if (scroll != 0) {
      widget.hidService.sendMouse(scroll: scroll.clamp(-127, 127));
    }
  }

  void _onTap() {
    if (!widget.hidService.isConnected) return;
    HapticFeedback.mediumImpact();
    widget.hidService.sendMouse(buttons: 1);
    Future.delayed(const Duration(milliseconds: 50), () {
      widget.hidService.sendMouse(buttons: 0);
    });
  }

  @override
  void dispose() {
    _moveThrottle?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _onTap,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: _trackpadColor,
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.mouse_rounded,
                    color: Colors.white10,
                    size: 80,
                  ),
                ),
                if (!widget.hidService.isConnected)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bluetooth_disabled_rounded,
                              color: Colors.white70, size: 40),
                          SizedBox(height: 12),
                          Text(
                            'ULANMAGAN',
                            style: TextStyle(
                              color: Colors.white70, 
                              fontSize: 12, 
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.showScrollBars) ...[
          _buildScrollIndicator(left: 8),
          _buildScrollIndicator(right: 8),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 40,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: _onScrollUpdate,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildScrollIndicator({double? left, double? right}) {
    return Positioned(
      left: left, right: right, top: 20, bottom: 20,
      child: IgnorePointer(
        child: Container(
          width: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
