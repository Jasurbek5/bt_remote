import 'package:flutter/material.dart';
import '../services/hid_service.dart';

class DeviceSelector extends StatefulWidget {
  final HidService hidService;
  const DeviceSelector({super.key, required this.hidService});

  @override
  State<DeviceSelector> createState() => _DeviceSelectorState();
}

class _DeviceSelectorState extends State<DeviceSelector> {
  // MAVZU RANGI
  static const Color _primaryColor = Color(0xFF5E35B1); 
  
  List<PairedDevice> _devices = [];
  bool _loading = true;
  bool _connecting = false;
  String? _connectingAddress;

  @override
  void initState() {
    super.initState();
    widget.hidService.addListener(_onChanged);
    _loadDevices();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadDevices() async {
    setState(() => _loading = true);
    final devices = await widget.hidService.getPairedDevices();
    if (mounted) {
      setState(() {
        _devices = devices;
        _loading = false;
      });
    }
  }

  Future<void> _connectDevice(PairedDevice device) async {
    setState(() {
      _connecting = true;
      _connectingAddress = device.address;
    });

    final success = await widget.hidService.connect(device.address);

    if (!mounted) return;

    setState(() {
      _connecting = false;
      _connectingAddress = null;
    });

    if (success) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      if (widget.hidService.isConnected) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    widget.hidService.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Icon(Icons.bluetooth_searching_rounded, color: _primaryColor, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Qurilmalar',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF263238)),
                ),
                const Spacer(),
                if (_loading)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  IconButton.filledTonal(
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    onPressed: _loadDevices,
                  ),
              ],
            ),
          ),

          // Ulangan qurilma statusi
          if (widget.hidService.isConnected)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green.shade50, Colors.white]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ULANGAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.green)),
                        Text(widget.hidService.connectedDeviceName ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.hidService.disconnect(),
                    child: const Text('UZISH', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
            child: _loading
                ? const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())
                : _devices.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                        itemCount: _devices.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _buildDeviceTile(_devices[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(PairedDevice device) {
    final isThisConnecting = _connectingAddress == device.address;
    final isConnected = widget.hidService.connectedDeviceName == device.name && widget.hidService.isConnected;

    return Container(
      decoration: BoxDecoration(
        color: isConnected ? _primaryColor.withValues(alpha: 0.05) : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isConnected ? _primaryColor.withValues(alpha: 0.2) : Colors.transparent),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isConnected ? _primaryColor : Colors.white,
          child: Icon(Icons.computer_rounded, color: isConnected ? Colors.white : _primaryColor, size: 20),
        ),
        title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(device.address, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: isThisConnecting 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : isConnected 
            ? const Icon(Icons.done_all_rounded, color: _primaryColor)
            : ElevatedButton(
                onPressed: _connecting ? null : () => _connectDevice(device),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('ULASH'),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.bluetooth_disabled_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Juftlangan qurilmalar yo\'q', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('PC/TV ni Bluetooth sozlamalaridan juftlang', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
