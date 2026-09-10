import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'iot_simulation_drawer.dart';

class IotCybersecurityPanel extends StatefulWidget {
  final bool isWideScreen;

  const IotCybersecurityPanel({super.key, required this.isWideScreen});

  @override
  State<IotCybersecurityPanel> createState() => _IotCybersecurityPanelState();
}

class _IotCybersecurityPanelState extends State<IotCybersecurityPanel> with SingleTickerProviderStateMixin {
  Timer? _timer;
  final Random _random = Random();
  bool _isStreamActive = true;

  // Data Telemetri Real-time
  int _activeSensors = 1204;
  double _nfcUptime = 98.7;
  double _networkThroughput = 4.28;
  int _blockedAnomalies = 38;
  int _latencyMs = 14;
  int _packetsPerSec = 8420;
  List<double> _wavePoints = [24, 18, 28, 14, 22, 12, 19, 10, 20];

  @override
  void initState() {
    super.initState();
    _startStream();
  }

  void _startStream() {
    _timer = Timer.periodic(const Duration(milliseconds: 1800), (timer) {
      if (!_isStreamActive || !mounted) return;
      setState(() {
        _activeSensors = 1200 + _random.nextInt(12);
        _networkThroughput = double.parse((4.1 + _random.nextDouble() * 0.45).toStringAsFixed(2));
        _latencyMs = 12 + _random.nextInt(6);
        _packetsPerSec = 8200 + _random.nextInt(650);

        if (_random.nextDouble() > 0.7) {
          _blockedAnomalies += 1;
        }

        _wavePoints = List.generate(9, (i) => 8.0 + _random.nextDouble() * 24.0);
      });
    });
  }

  void _toggleStream() {
    setState(() {
      _isStreamActive = !_isStreamActive;
    });
  }

  void _openTestbenchDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.92,
        child: IotSimulationDrawer(
          isStreamActive: _isStreamActive,
          onToggleStream: _toggleStream,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.withValues(alpha:0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.memory_rounded, size: 14, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text(
                      'SMART CITY TELEMETRY & CYBER GRID',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Analisis Sistem, IoT & Tren Sektoral',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pemantauan telemetri sensor cerdas, fiber backbone, dan pertahanan siber real-time.',
                style: TextStyle(fontSize: 15, color: Color(0xFFEFF4FF)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Stream Controls & Button
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isStreamActive ? Colors.greenAccent : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status: ${_isStreamActive ? "LIVE 1.8s TICKS" : "PAUSED"}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: _toggleStream,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(_isStreamActive ? Icons.pause : Icons.play_arrow, size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(_isStreamActive ? 'Jeda' : 'Mulai', style: const TextStyle(color: Colors.white, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openTestbenchDrawer(context),
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    label: const Text('Buka Panel Uji Sensor & Simulasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0056B3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        if (widget.isWideScreen)
          Row(
            children: [
              Expanded(child: _buildRfidSensorCard(context)),
              const SizedBox(width: 16),
              Expanded(child: _buildThroughputCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildCyberSecurityCard()),
            ],
          )
        else
          Column(
            children: [
              _buildRfidSensorCard(context),
              const SizedBox(height: 16),
              _buildThroughputCard(),
              const SizedBox(height: 16),
              _buildCyberSecurityCard(),
            ],
          ),
      ],
    );
  }

  // 1. Status Sensor & RFID
  Widget _buildRfidSensorCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1C30), Color(0xFF10243E), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha:0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.2), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status Sensor & RFID', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('Telemetri Rute Angkutan & Pos', style: TextStyle(fontSize: 11, color: Color(0xFFACC7FF))),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.withValues(alpha:0.3)),
                ),
                child: Icon(Icons.sensors_rounded, color: Colors.blue.shade300, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTelemetryRow('Sensor Aktif:', '$_activeSensors Node'),
          const Divider(color: Colors.white12, height: 20),
          _buildTelemetryRow('NFC Gateway:', '$_nfcUptime% Uptime'),
          const Divider(color: Colors.white12, height: 20),
          _buildTelemetryRow('Rata-rata Latensi:', '$_latencyMs ms'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha:0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent, size: 16),
                    SizedBox(width: 8),
                    Text('Jaringan Sensor Stabil', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                InkWell(
                  onTap: () => _openTestbenchDrawer(context),
                  child: const Text('Uji Sensor →', style: TextStyle(color: Color(0xFFACC7FF), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Throughput Jaringan & Gelombang Animasi
  Widget _buildThroughputCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1C30), Color(0xFF10243E), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha:0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.2), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Throughput Jaringan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('Bandwidth Fiber Optic & WiFi', style: TextStyle(fontSize: 11, color: Color(0xFFACC7FF))),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.indigo.withValues(alpha:0.3)),
                ),
                child: Icon(Icons.wifi_tethering_rounded, color: Colors.indigo.shade200, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _networkThroughput.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'monospace'),
                      ),
                      const SizedBox(width: 6),
                      const Text('Gbps', style: TextStyle(fontSize: 16, color: Color(0xFFACC7FF), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Text('BEBAN RATA-RATA REAL-TIME', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Paket / dtk:', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  Text('$_packetsPerSec', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha:0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomPaint(
                painter: AnimatedWavePainter(points: _wavePoints),
                size: const Size(double.infinity, 44),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Keamanan Informasi & Pertahanan Siber
  Widget _buildCyberSecurityCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1C30), Color(0xFF10243E), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha:0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.2), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Keamanan Informasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('SOC & Firewall Pemkot Payakumbuh', style: TextStyle(fontSize: 11, color: Color(0xFFFFB4AB))),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.withValues(alpha:0.3)),
                ),
                child: Icon(Icons.shield_rounded, color: Colors.red.shade300, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTelemetryRow('Anomali Diblokir:', '$_blockedAnomalies Hari ini'),
          const Divider(color: Colors.white12, height: 20),
          _buildTelemetryRow('Protokol:', 'TLS 1.3 / AES-256'),
          const Divider(color: Colors.white12, height: 20),
          _buildTelemetryRow('Status Pertahanan:', 'Terlindungi 100%'),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child:const LinearProgressIndicator(
              value: 0.92,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Skor Integritas: 92/100', style: TextStyle(fontSize: 11, color: Colors.white54)),
              Text('Defcon 4 (Normal)', style: TextStyle(fontSize: 11, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

class AnimatedWavePainter extends CustomPainter {
  final List<double> points;

  AnimatedWavePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF818CF8).withValues(alpha:0.5), const Color(0xFF818CF8).withValues(alpha:0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF818CF8), Color(0xFFC084FC)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (points.length - 1);
    path.moveTo(0, points[0]);
    fillPath.moveTo(0, points[0]);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = Offset(i * stepX, points[i]);
      final p2 = Offset((i + 1) * stepX, points[i + 1]);
      final controlPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      path.quadraticBezierTo(p1.dx, p1.dy, controlPoint.dx, controlPoint.dy);
      fillPath.quadraticBezierTo(p1.dx, p1.dy, controlPoint.dx, controlPoint.dy);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant AnimatedWavePainter oldDelegate) => true;
}