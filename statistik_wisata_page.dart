import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatistikWisataPage extends StatefulWidget {
  const StatistikWisataPage({super.key});

  @override
  State<StatistikWisataPage> createState() => _StatistikWisataPageState();
}

class _StatistikWisataPageState extends State<StatistikWisataPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003F87), // Tema Biru Utama
        foregroundColor: Colors.white,
        title: const Text('Statistik Kunjungan Wisatawan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================================
            // 1. HEADER HALAMAN
            // =================================================================
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Beranda  >  Pariwisata  >  Statistik Kunjungan', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dashboard Kunjungan Wisata', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF2563EB)),
                            SizedBox(width: 8),
                            Text('Tahun 2026', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                          ],
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
                  // =================================================================
                  // 2. KARTU KPI (KEY PERFORMANCE INDICATORS)
                  // =================================================================
                  Row(
                    children: [
                      Expanded(child: _buildKpiCard('125.430', 'Total Wisatawan', Icons.groups_rounded, const Color(0xFF2563EB), '+12% dari tahun lalu')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('118.200', 'Wisatawan Nusantara', Icons.flight_land_rounded, const Color(0xFF10B981), '94.2% dari total')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('7.230', 'Wisatawan Mancanegara', Icons.public_rounded, const Color(0xFFF59E0B), 'Naik 5% bulan ini')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('Rp 8.5 M', 'Estimasi PAD Pariwisata', Icons.account_balance_wallet_rounded, const Color(0xFF8B5CF6), 'Target Tahunan: 65%')),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // =================================================================
                  // 3. GRAFIK KUNJUNGAN (BAR CHART) & DISTRIBUSI (DONUT CHART)
                  // =================================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BAGIAN KIRI: GRAFIK BATANG (TREN BULANAN)
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tren Kunjungan Bulanan (2026)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              const SizedBox(height: 8),
                              const Text('Perbandingan wisatawan domestik dan mancanegara', style: TextStyle(fontSize: 13, color: Colors.grey)),
                              const SizedBox(height: 40),
                              SizedBox(height: 300, child: _buildBarChart()),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegendItem('Wisatawan Nusantara', const Color(0xFF2563EB)),
                                  const SizedBox(width: 24),
                                  _buildLegendItem('Wisatawan Mancanegara', const Color(0xFF60A5FA)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      
                      // BAGIAN KANAN: GRAFIK DONAT (DESTINASI FAVORIT)
                      Expanded(
                        flex: 4,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Distribusi Destinasi Populer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              const SizedBox(height: 8),
                              const Text('Berdasarkan penjualan tiket terbanyak', style: TextStyle(fontSize: 13, color: Colors.grey)),
                              const SizedBox(height: 40),
                              SizedBox(height: 220, child: _buildDonutChart()),
                              const SizedBox(height: 32),
                              _buildDonutLegend('Ngalau Indah', const Color(0xFF2563EB), '40%'),
                              _buildDonutLegend('Batang Tabik Waterpark', const Color(0xFF10B981), '30%'),
                              _buildDonutLegend('Taman Wisata Batang Agam', const Color(0xFFF59E0B), '20%'),
                              _buildDonutLegend('Lainnya (Kampung Rendang, dll)', const Color(0xFF94A3B8), '10%'),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 40),

                  // =================================================================
                  // 4. TABEL TOP DESTINASI
                  // =================================================================
                  const Text('Top 5 Destinasi Bulan Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FF)),
                        dividerThickness: 1,
                        dataRowMaxHeight: 70,
                        dataRowMinHeight: 60,
                        columns: const [
                          DataColumn(label: Text('PERINGKAT', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF565F69), fontSize: 12))),
                          DataColumn(label: Text('NAMA DESTINASI', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF565F69), fontSize: 12))),
                          DataColumn(label: Text('KATEGORI', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF565F69), fontSize: 12))),
                          DataColumn(label: Text('JUMLAH PENGUNJUNG', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF565F69), fontSize: 12))),
                          DataColumn(label: Text('TREN', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF565F69), fontSize: 12))),
                        ],
                        rows: [
                          _buildTopDestinasiRow('1', 'Ngalau Indah', 'Wisata Alam', '12.450 Orang', true, 'Naik 15%'),
                          _buildTopDestinasiRow('2', 'Batang Tabik Waterpark', 'Taman & Hiburan', '9.820 Orang', true, 'Naik 8%'),
                          _buildTopDestinasiRow('3', 'Taman Wisata Batang Agam', 'Taman & Hiburan', '7.100 Orang', false, 'Turun 2%'),
                          _buildTopDestinasiRow('4', 'Kampung Rendang', 'Kuliner', '4.350 Orang', true, 'Naik 5%'),
                          _buildTopDestinasiRow('5', 'Rumah Gadang Sungai Baringin', 'Budaya', '2.100 Orang', true, 'Naik 1%'),
                        ],
                      ),
                    ),
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
  // WIDGET BANTUAN
  // ===========================================================================
  
  Widget _buildKpiCard(String value, String label, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 25000,
        barTouchData: const BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                Widget text;
                switch (value.toInt()) {
                  case 0: text = const Text('Jan', style: style); break;
                  case 1: text = const Text('Feb', style: style); break;
                  case 2: text = const Text('Mar', style: style); break;
                  case 3: text = const Text('Apr', style: style); break;
                  case 4: text = const Text('Mei', style: style); break;
                  case 5: text = const Text('Jun', style: style); break;
                  default: text = const Text('', style: style); break;
                }
                return SideTitleWidget(meta: meta, child: text);
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text('${(value / 1000).toInt()}k', style: const TextStyle(color: Colors.grey, fontSize: 12));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true, 
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1, dashArray: [5, 5])
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          _makeGroupData(0, 18000, 2000),
          _makeGroupData(1, 15000, 1500),
          _makeGroupData(2, 20000, 2500),
          _makeGroupData(3, 14000, 1000),
          _makeGroupData(4, 22000, 3000),
          _makeGroupData(5, 24000, 3500),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1 + y2, // Stacked bar
          color: const Color(0xFF2563EB), // Biru untuk Domestik
          width: 32,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
          rodStackItems: [
            BarChartRodStackItem(0, y1, const Color(0xFF2563EB)), // Domestik
            BarChartRodStackItem(y1, y1 + y2, const Color(0xFF60A5FA)), // Mancanegara (Biru Lebih Muda)
          ]
        ),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDonutChart() {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(enabled: true),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2, centerSpaceRadius: 60,
        sections: [
          PieChartSectionData(color: const Color(0xFF2563EB), value: 40, title: '40%', radius: 45, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: const Color(0xFF10B981), value: 30, title: '30%', radius: 45, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: const Color(0xFFF59E0B), value: 20, title: '20%', radius: 45, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: const Color(0xFF94A3B8), value: 10, title: '', radius: 35),
        ],
      ),
    );
  }

  Widget _buildDonutLegend(String label, Color color, String percent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF475569)))),
          Text(percent, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  DataRow _buildTopDestinasiRow(String rank, String nama, String kategori, String pengunjung, bool isUp, String trendTxt) {
    return DataRow(
      cells: [
        DataCell(
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: rank == '1' || rank == '2' || rank == '3' ? const Color(0xFFDBEAFE) : Colors.grey.shade100, shape: BoxShape.circle),
            child: Text(rank, style: TextStyle(fontWeight: FontWeight.bold, color: rank == '1' || rank == '2' || rank == '3' ? const Color(0xFF2563EB) : Colors.grey.shade600)),
          )
        ),
        DataCell(Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B1C30)))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
            child: Text(kategori, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
          )
        ),
        DataCell(Text(pengunjung, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(
          Row(
            children: [
              Icon(isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444), size: 18),
              const SizedBox(width: 6),
              Text(trendTxt, style: TextStyle(color: isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          )
        ),
      ]
    );
  }
}