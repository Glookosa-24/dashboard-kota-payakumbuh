import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

enum UmkmSector { all, rendang, craft, digital }

class UmkmTrendChartCard extends StatefulWidget {
  final bool isWideScreen;

  const UmkmTrendChartCard({super.key, required this.isWideScreen});

  @override
  State<UmkmTrendChartCard> createState() => _UmkmTrendChartCardState();
}

class _UmkmTrendChartCardState extends State<UmkmTrendChartCard> {
  UmkmSector _selectedSector = UmkmSector.all;
  bool _isPlaying = false;
  int _animatedMonthProgress = 12;
  Timer? _playbackTimer;

  static const List<double> _baseValues = [
    100, 220, 310, 390, 450, 700,
    980, 1320, 1680, 1750, 1820, 1940
  ];

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  double get _sectorMultiplier {
    switch (_selectedSector) {
      case UmkmSector.rendang:
        return 0.48;
      case UmkmSector.craft:
        return 0.32;
      case UmkmSector.digital:
        return 0.20;
      case UmkmSector.all:
        return 1.0;
    }
  }

  Color get _sectorColor {
    switch (_selectedSector) {
      case UmkmSector.rendang:
        return const Color(0xFFD97706);
      case UmkmSector.craft:
        return const Color(0xFF059669);
      case UmkmSector.digital:
        return const Color(0xFF7C3AED);
      case UmkmSector.all:
        return const Color(0xFF0056B3);
    }
  }

  void _startPlayback() {
    setState(() {
      _animatedMonthProgress = 1;
      _isPlaying = true;
    });

    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 450), (timer) {
      if (_animatedMonthProgress >= 12) {
        timer.cancel();
        setState(() => _isPlaying = false);
      } else {
        setState(() => _animatedMonthProgress += 1);
      }
    });
  }

  void _resetPlayback() {
    _playbackTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _animatedMonthProgress = 12;
    });
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (int i = 0; i < _animatedMonthProgress; i++) {
      spots.add(FlSpot(i.toDouble(), _baseValues[i] * _sectorMultiplier));
    }

    final double maxY = _selectedSector == UmkmSector.all ? 2000 : 1000;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Playback Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tren Pertumbuhan UMKM & Ekonomi Kreatif',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Dinas Koperasi & UKM Kota Payakumbuh (12 Bulan Terakhir)',
                    style: TextStyle(fontSize: 13, color: Color(0xFF565F69)),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isPlaying ? _resetPlayback : _startPlayback,
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 16),
                    label: Text(_isPlaying ? 'Jeda' : 'Animasikan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003F87),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _resetPlayback,
                    icon: const Icon(Icons.replay_rounded, size: 20, color: Color(0xFF565F69)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sector Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSectorChip('Semua Sektor', UmkmSector.all),
                _buildSectorChip('Kuliner & Sentra Rendang', UmkmSector.rendang),
                _buildSectorChip('Kriya & Tenun', UmkmSector.craft),
                _buildSectorChip('Jasa Kreatif & Digital', UmkmSector.digital),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Chart fl_chart
          SizedBox(
            height: widget.isWideScreen ? 350 : 250, // <-- Menggunakan isWideScreen agar tinggi grafik responsif
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFF727784).withValues(alpha: 0.12),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxY / 4,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(color: Color(0xFF565F69), fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _months[index],
                              style: TextStyle(
                                color: index < _animatedMonthProgress ? const Color(0xFF003F87) : const Color(0xFF565F69),
                                fontSize: 12,
                                fontWeight: index < _animatedMonthProgress ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                minX: 0,
                maxX: 11,
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: _sectorColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 5,
                        color: Colors.white,
                        strokeWidth: 2.5,
                        strokeColor: _sectorColor,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          _sectorColor.withValues(alpha: 0.4),
                          _sectorColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 3 Metric Cards -> dibuat responsif agar tidak menabrak saat dilipat ke layar kecil
          if (widget.isWideScreen)
            Row(
              children: [
                Expanded(
                  child: _buildMetricBadge(
                    Icons.emoji_events_rounded,
                    'Bulan Puncak',
                    'Desember — 1.940 Unit',
                    const Color(0xFFEFF4FF),
                    const Color(0xFF003F87),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricBadge(
                    Icons.trending_up_rounded,
                    'Rata-rata Pertumbuhan',
                    '+32.1% per Tahun',
                    const Color(0xFFECFDF5),
                    const Color(0xFF059669),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildMetricBadge(
                  Icons.emoji_events_rounded,
                  'Bulan Puncak',
                  'Desember — 1.940 Unit',
                  const Color(0xFFEFF4FF),
                  const Color(0xFF003F87),
                ),
                const SizedBox(height: 12),
                _buildMetricBadge(
                  Icons.trending_up_rounded,
                  'Rata-rata Pertumbuhan',
                  '+32.1% per Tahun',
                  const Color(0xFFECFDF5),
                  const Color(0xFF059669),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSectorChip(String title, UmkmSector sector) {
    final isSelected = _selectedSector == sector;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(title),
        selected: isSelected,
        onSelected: (val) {
          setState(() {
            _selectedSector = sector;
            _animatedMonthProgress = 12;
          });
        },
        selectedColor: const Color(0xFF003F87),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF565F69),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        backgroundColor: const Color(0xFFEFF4FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildMetricBadge(IconData icon, String label, String value, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: textCol, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF565F69))),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textCol)),
            ],
          ),
        ],
      ),
    );
  }
}