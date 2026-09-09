import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StatistikSdPage extends StatelessWidget {
  const StatistikSdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC), 
      appBar: AppBar(
        backgroundColor: const Color(0xFF007BFF), 
        foregroundColor: Colors.white,
        title: const Text('Dashboard Pendidikan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================================
            // 1. HEADER & BREADCRUMBS
            // =================================================================
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Beranda  >  Eksplorasi Dashboard  >  Jumlah Sekolah, Guru, Siswa (SD) Payakumbuh',
                    style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jumlah Sekolah, Guru, Siswa (SD) Payakumbuh',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30)),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Bagikan'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF007BFF),
                          side: const BorderSide(color: Color(0xFF007BFF)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===========================================================
                  // 2. KARTU KPI UTAMA (Data disesuaikan untuk SD)
                  // ===========================================================
                  Row(
                    children: [
                      Expanded(child: _buildKpiCard('82', 'Jumlah Sekolah')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('1.150', 'Jumlah Guru')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('14.500', 'Jumlah Siswa')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildKpiCard('14', 'Rasio Jumlah Guru Untuk 1 Sekolah')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('12', 'Rasio Jumlah Siswa Untuk 1 Guru')),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // ===========================================================
                  // 3. GRAFIK BATANG INTERAKTIF
                  // ===========================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Perbandingan Jumlah Sekolah, Guru, Siswa Berdasarkan Kecamatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0B1C30))),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _buildLegendItem('Jumlah Sekolah', const Color(0xFFEF4444)),
                            const SizedBox(width: 24),
                            _buildLegendItem('Jumlah Guru', const Color(0xFF3B82F6)),
                            const SizedBox(width: 24),
                            _buildLegendItem('Jumlah Siswa', const Color(0xFF84CC16)),
                          ],
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          height: 450, 
                          child: _buildGroupedBarChart(),
                        ),
                        const SizedBox(height: 24),
                        const Center(child: Text('Nama Wilayah Kecamatan', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ===========================================================
                  // 4. PETA SEBARAN (3 PETA BERDAMPINGAN DENGAN GOOGLE MAPS)
                  // ===========================================================
                  Row(
                    children: [
                      Expanded(child: _buildInteractiveMapCard('Sebaran Jumlah Sekolah', const Color(0xFFEF4444), 'Jumlah Sekolah', [30, 20, 15, 10, 7], [75, 60, 50, 35, 25])),
                      const SizedBox(width: 16),
                      Expanded(child: _buildInteractiveMapCard('Sebaran Jumlah Guru', const Color(0xFF3B82F6), 'Jumlah Guru', [450, 280, 200, 130, 90], [80, 65, 55, 40, 30])),
                      const SizedBox(width: 16),
                      Expanded(child: _buildInteractiveMapCard('Sebaran Jumlah Siswa', const Color(0xFF84CC16), 'Jumlah Siswa', ['5.500', '3.800', '2.500', '1.700', '1.000'], [85, 70, 60, 45, 35])),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // ===========================================================
                  // 5. SUMBER DATA & TAHUN
                  // ===========================================================
                  const Text('Sumber Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dinas Pendidikan Provinsi Sumatera Barat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF565F69))),
                        const SizedBox(height: 16),
                        _buildDataLink('https://opendata.payakumbuhkota.go.id/dataset/jumlah-sekolah-sd'),
                        const SizedBox(height: 8),
                        _buildDataLink('https://opendata.payakumbuhkota.go.id/dataset/jumlah-guru-sd'),
                        const SizedBox(height: 8),
                        _buildDataLink('https://opendata.payakumbuhkota.go.id/dataset/jumlah-siswa-sd'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  const Text('Keterangan Tahun Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildYearCard('2025/2026', 'Tahun Data Sekolah'),
                      const SizedBox(width: 16),
                      _buildYearCard('2025/2026', 'Tahun Data Ajaran Guru'),
                      const SizedBox(width: 16),
                      _buildYearCard('2025/2026', 'Tahun Data Siswa'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Row(
                    children: [
                      Icon(Icons.dashboard_customize, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('Powered by ', style: TextStyle(color: Colors.grey)),
                      Text('Payakumbuh DataHub', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BANTUAN DASAR
  // ===========================================================================
  
  Widget _buildKpiCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)]),
      child: Column(
        children: [
          Text(number, style: const TextStyle(fontSize: 64, color: Color(0xFF475569), fontWeight: FontWeight.w500, letterSpacing: -2)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF0B1C30), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF565F69))),
      ],
    );
  }

  Widget _buildDataLink(String url) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(top: 6, right: 8), child: Icon(Icons.circle, size: 6, color: Color(0xFF565F69))),
        Expanded(child: Text(url, style: const TextStyle(color: Color(0xFF007BFF), fontSize: 14, decoration: TextDecoration.underline))),
      ],
    );
  }

  Widget _buildYearCard(String year, String label) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Text(year, style: const TextStyle(fontSize: 32, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF0B1C30), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ===========================================================================
  // GRAFIK BATANG fl_chart
  // ===========================================================================
  Widget _buildGroupedBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100, 
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => const Color(0xFF0B1C30).withValues(alpha: 0.9), 
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String label = rodIndex == 0 ? 'Sekolah' : (rodIndex == 1 ? 'Guru' : 'Siswa');
              // Logika kalkulasi untuk mendapatkan angka asli SD berdasarkan Y axis
              double realValue = rodIndex == 0 ? rod.toY : (rodIndex == 1 ? rod.toY * 10 : rod.toY * 100);
              return BarTooltipItem(
                '$label\n', const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                children: [TextSpan(text: realValue.toInt().toString(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                const titles = ['Payakumbuh Barat', 'Payakumbuh Timur', 'Payakumbuh Utara', 'Payakumbuh Selatan', 'Latina'];
                return Padding(padding: const EdgeInsets.only(top: 12.0), child: Text(titles[value.toInt()], style: const TextStyle(fontSize: 12, color: Color(0xFF0B1C30), fontWeight: FontWeight.bold)));
              }, reservedSize: 40),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50, getTitlesWidget: (val, _) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)))),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1.5, dashArray: [6, 6])),
        borderData: FlBorderData(show: false),
        barGroups: [
          _makeGroupData(0, 30, 45, 55), // Barat (SD)
          _makeGroupData(1, 20, 28, 38), // Timur (SD)
          _makeGroupData(2, 15, 20, 25), // Utara (SD)
          _makeGroupData(3, 10, 13, 17), // Selatan (SD)
          _makeGroupData(4, 7, 9, 10),   // Latina (SD)
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2, double y3) {
    return BarChartGroupData(
      x: x,
      barsSpace: 8, 
      barRods: [
        BarChartRodData(toY: y1, width: 20, gradient: const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFFCA5A5)], begin: Alignment.bottomCenter, end: Alignment.topCenter), borderRadius: const BorderRadius.vertical(top: Radius.circular(6)), backDrawRodData: BackgroundBarChartRodData(show: true, toY: 100, color: const Color(0xFFF1F5F9))),
        BarChartRodData(toY: y2, width: 20, gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF93C5FD)], begin: Alignment.bottomCenter, end: Alignment.topCenter), borderRadius: const BorderRadius.vertical(top: Radius.circular(6)), backDrawRodData: BackgroundBarChartRodData(show: true, toY: 100, color: const Color(0xFFF1F5F9))),
        BarChartRodData(toY: y3, width: 20, gradient: const LinearGradient(colors: [Color(0xFF65A30D), Color(0xFFBEF264)], begin: Alignment.bottomCenter, end: Alignment.topCenter), borderRadius: const BorderRadius.vertical(top: Radius.circular(6)), backDrawRodData: BackgroundBarChartRodData(show: true, toY: 100, color: const Color(0xFFF1F5F9))),
      ],
    );
  }

  // ===========================================================================
  // PETA SEBARAN (GOOGLE MAPS DENGAN TOOLTIP)
  // ===========================================================================
  Widget _buildInteractiveMapCard(String title, Color themeColor, String tooltipLabel, List<dynamic> jumlahData, List<double> bubbleSizes) {
    final List<Map<String, dynamic>> kecamatanData = [
      {'nama': 'PAYAKUMBUH BARAT', 'kode': '137604', 'titik': const LatLng(-0.2260, 100.6200), 'jumlah': jumlahData[0].toString(), 'ukuran': bubbleSizes[0]},
      {'nama': 'PAYAKUMBUH TIMUR', 'kode': '137603', 'titik': const LatLng(-0.2280, 100.6550), 'jumlah': jumlahData[1].toString(), 'ukuran': bubbleSizes[1]},
      {'nama': 'PAYAKUMBUH UTARA', 'kode': '137602', 'titik': const LatLng(-0.2050, 100.6350), 'jumlah': jumlahData[2].toString(), 'ukuran': bubbleSizes[2]},
      {'nama': 'PAYAKUMBUH SELATAN', 'kode': '137601', 'titik': const LatLng(-0.2450, 100.6300), 'jumlah': jumlahData[3].toString(), 'ukuran': bubbleSizes[3]},
      {'nama': 'LATINA', 'kode': '137605', 'titik': const LatLng(-0.2000, 100.6150), 'jumlah': jumlahData[4].toString(), 'ukuran': bubbleSizes[4]},
    ];

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF565F69))),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 280,
            child: Row(
              children: [
                Container(
                  width: 100,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildScaleLegend(themeColor.withValues(alpha: 0.2), '0 - 10'),
                      const SizedBox(height: 8),
                      _buildScaleLegend(themeColor.withValues(alpha: 0.4), '11 - 25'),
                      const SizedBox(height: 8),
                      _buildScaleLegend(themeColor.withValues(alpha: 0.6), '26 - 50'),
                      const SizedBox(height: 8),
                      _buildScaleLegend(themeColor.withValues(alpha: 0.8), '51 - 100'),
                      const SizedBox(height: 8),
                      _buildScaleLegend(themeColor.withValues(alpha: 1.0), '100+'),
                    ],
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16)),
                    child: FlutterMap(
                      options: const MapOptions(
                        initialCenter: LatLng(-0.2201, 100.6306),
                        initialZoom: 11.5,
                        interactionOptions: InteractionOptions(flags: InteractiveFlag.all), 
                      ),
                      children: [
                        // PETA GOOGLE MAPS YANG CERAH & BERSIH
                        TileLayer(
                          urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                          userAgentPackageName: 'com.dashboard_kota_payakumbuh.app',
                        ),
                        MarkerLayer(
                          markers: kecamatanData.map((kec) {
                            return Marker(
                              point: kec['titik'],
                              width: 250, 
                              height: 200,
                              alignment: Alignment.center,
                              child: _InteractiveBubbleMarker(
                                color: themeColor,
                                bubbleSize: kec['ukuran'],
                                namaKecamatan: kec['nama'],
                                kodeWilayah: kec['kode'],
                                labelJumlah: tooltipLabel,
                                jumlah: kec['jumlah'],
                              ),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildScaleLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF565F69))),
      ],
    );
  }
}

// ===========================================================================
// KELAS MANDIRI: BUBBLE INTERAKTIF 
// ===========================================================================
class _InteractiveBubbleMarker extends StatefulWidget {
  final Color color;
  final double bubbleSize;
  final String namaKecamatan;
  final String kodeWilayah;
  final String labelJumlah;
  final String jumlah;

  const _InteractiveBubbleMarker({
    required this.color,
    required this.bubbleSize,
    required this.namaKecamatan,
    required this.kodeWilayah,
    required this.labelJumlah,
    required this.jumlah,
  });

  @override
  State<_InteractiveBubbleMarker> createState() => _InteractiveBubbleMarkerState();
}

class _InteractiveBubbleMarkerState extends State<_InteractiveBubbleMarker> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: () => setState(() => _isHovered = !_isHovered), 
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.bubbleSize,
              height: widget.bubbleSize,
              decoration: BoxDecoration(
                color: _isHovered ? widget.color : widget.color.withValues(alpha: 0.8), // Warna opacity diubah agar lebih pekat di atas Google Maps
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: _isHovered ? 2 : 1),
                boxShadow: _isHovered ? [BoxShadow(color: widget.color.withValues(alpha: 0.5), blurRadius: 10)] : [],
              ),
            ),
          ),
        ),

        if (_isHovered)
          Positioned(
            bottom: (widget.bubbleSize / 2) + 12, 
            child: IgnorePointer( 
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTooltipRow('Kode Wilayah:', widget.kodeWilayah),
                    const SizedBox(height: 4),
                    _buildTooltipRow('Nama Wilayah:', widget.namaKecamatan),
                    const SizedBox(height: 4),
                    _buildTooltipRow('${widget.labelJumlah}:', widget.jumlah),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTooltipRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}