import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class IotSimulationDrawer extends StatefulWidget {
  final bool isStreamActive;
  final VoidCallback onToggleStream;

  const IotSimulationDrawer({
    super.key,
    required this.isStreamActive,
    required this.onToggleStream,
  });

  @override
  State<IotSimulationDrawer> createState() => _IotSimulationDrawerState();
}

class _IotSimulationDrawerState extends State<IotSimulationDrawer> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Random _random = Random();

  int _blockedCount = 42;
  int _totalPackets = 1482;
  int _streamIntervalMs = 1500;
  String? _lastTappedSensorId;

  final List<Map<String, dynamic>> _sensors = [
    {'id': '1', 'code': 'RFID-PKB-B01', 'location': 'Pasar Ibuh (Halte Utama)', 'route': 'Rute 1 (Pasar - Balai Nan Duo)', 'taps': 342, 'status': 'ONLINE'},
    {'id': '2', 'code': 'RFID-PKB-T02', 'location': 'Ngalau Indah', 'route': 'Rute 2 (Pusat Kota - Ngalau)', 'taps': 215, 'status': 'ONLINE'},
    {'id': '3', 'code': 'RFID-PKB-U03', 'location': 'Payakumbuh Barat', 'route': 'Rute 3 (Koto Nan IV - RSUD)', 'taps': 189, 'status': 'ONLINE'},
    {'id': '4', 'code': 'RFID-PKB-S04', 'location': 'Balai Nan Duo', 'route': 'Rute 4 (Terminal - Balai)', 'taps': 120, 'status': 'ONLINE'},
  ];

  final List<Map<String, String>> _eventLogs = [
    {'time': '10:45:12', 'text': 'Gateway IoT Payakumbuh online. 4 node sensor terhubung via MQTT.', 'type': 'system'},
    {'time': '10:45:18', 'text': 'Node RFID-PKB-B01 mendeteksi tap kartu angkot #2401', 'type': 'rfid'},
    {'time': '10:45:25', 'text': 'Firewall memblokir SYN-Flood dari IP 185.220.101.5', 'type': 'cyber'},
    {'time': '10:45:30', 'text': 'Throughput fiber backbone stabil pada 4.28 Gbps', 'type': 'network'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _tapSensor(Map<String, dynamic> sensor) {
    setState(() {
      _lastTappedSensorId = sensor['id'];
      sensor['taps'] = (sensor['taps'] as int) + 1;
      _totalPackets += 1;
      
      final now = TimeOfDay.now().format(context);
      _eventLogs.insert(0, {
        'time': now,
        'text': '[TAP SUKSES] Penumpang menempelkan kartu di ${sensor['code']} (${sensor['location']}) - Total: ${sensor['taps']}',
        'type': 'rfid',
      });
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _lastTappedSensorId = null);
    });
  }

  void _injectThreat(String threatName, String desc, String colorType) {
    setState(() {
      _blockedCount += 1;
      final now = TimeOfDay.now().format(context);
      final fakeIp = '185.220.${_random.nextInt(255)}.${_random.nextInt(255)}';

      _eventLogs.insert(0, {
        'time': now,
        'text': '[$threatName] Percobaan serangan dari IP $fakeIp ditolak oleh Firewall Pemkot.',
        'type': 'cyber',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0B1C30),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tune_rounded, color: Colors.blueAccent),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Panel Uji Sensor & Simulator IoT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Uji interaktif telemetri RFID, injeksi SOC, dan log real-time', style: TextStyle(color: Color(0xFFACC7FF), fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(icon: Icon(Icons.directions_bus_rounded, size: 18), text: '1. Uji Sensor RFID'),
              Tab(icon: Icon(Icons.shield_rounded, size: 18), text: '2. Injeksi Ancaman'),
              Tab(icon: Icon(Icons.stream_rounded, size: 18), text: '3. Stream Auto'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRfidTab(),
                _buildCyberTab(),
                _buildStreamTab(),
              ],
            ),
          ),
          _buildLogsFooter(),
        ],
      ),
    );
  }

  Widget _buildRfidTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ..._sensors.map((s) {
          final isTapped = _lastTappedSensorId == s['id'];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isTapped ? Colors.blue.withValues(alpha:0.3) : Colors.white.withValues(alpha:0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isTapped ? Colors.blueAccent : Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['code'], style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(s['location'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(s['route'], style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text('Total Tap: ${s['taps']}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _tapSensor(s),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Tap Kartu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056B3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCyberTab() {
    final threats = [
      {'name': 'SYN-Flood Anomali', 'desc': 'Uji proteksi kebanjiran paket SYN gateway'},
      {'name': 'SQL Injection Test', 'desc': 'Uji filter WAF endpoint portal kependudukan'},
      {'name': 'Brute Force Attack', 'desc': 'Uji rate limiter auth dan blacklist IP'},
      {'name': 'DDoS Scrubber Test', 'desc': 'Uji peredaman lonjakan bandwidth 150 Mbps'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: threats.length,
      itemBuilder: (ctx, i) {
        final t = threats[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t['name']!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(t['desc']!, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => _injectThreat(t['name']!, t['desc']!, 'danger'),
                icon: const Icon(Icons.security, size: 14, color: Colors.redAccent),
                label: const Text('Injeksi', style: TextStyle(color: Colors.redAccent)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreamTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withValues(alpha:0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auto Stream Telemetri', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Mengirimkan emisi data otomatis berkala', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),
                ElevatedButton(
                  onPressed: widget.onToggleStream,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isStreamActive ? Colors.amber.shade700 : Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(widget.isStreamActive ? 'Jeda Stream' : 'Mulai Stream'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Pilih Interval Tick:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            children: [500, 1000, 1500, 2500].map((ms) {
              final isSel = _streamIntervalMs == ms;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => setState(() => _streamIntervalMs = ms),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSel ? Colors.blueAccent : Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text('${ms}ms', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsFooter() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha:0.4),
        border: const Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Live Logs Stream:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
              InkWell(
                onTap: () => setState(() => _eventLogs.clear()),
                child: const Text('Bersihkan', style: TextStyle(color: Colors.blueAccent, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _eventLogs.length,
              itemBuilder: (ctx, i) {
                final l = _eventLogs[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '[${l['time']}] ${l['text']}',
                    style: TextStyle(
                      color: l['type'] == 'cyber' ? Colors.redAccent : l['type'] == 'rfid' ? Colors.blueAccent : Colors.white70,
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}