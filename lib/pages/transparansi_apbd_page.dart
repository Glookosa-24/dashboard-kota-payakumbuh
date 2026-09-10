import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TransparansiApbdPage extends StatefulWidget {
  const TransparansiApbdPage({super.key});

  @override
  State<TransparansiApbdPage> createState() => _TransparansiApbdPageState();
}

class _TransparansiApbdPageState extends State<TransparansiApbdPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003F87), // Tema Biru Utama
        foregroundColor: Colors.white,
        title: const Text('Transparansi Anggaran (APBD)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                  const Text('Beranda  >  Pemerintahan  >  Transparansi APBD', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dashboard Pelaksanaan APBD', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.account_balance_wallet_rounded, size: 16, color: Color(0xFF2563EB)),
                            SizedBox(width: 8),
                            Text('Tahun Anggaran 2026', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
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
                      Expanded(child: _buildKpiCard('Rp 824.5 M', 'Total Pagu APBD', Icons.account_balance_rounded, const Color(0xFF2563EB), 'Ditetapkan Tahun 2026')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('Rp 120.3 M', 'Pendapatan Asli Daerah (PAD)', Icons.savings_rounded, const Color(0xFF10B981), 'Tercapai 78% dari Target')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('65.4%', 'Realisasi Belanja Daerah', Icons.shopping_cart_checkout_rounded, const Color(0xFFF59E0B), 'Rp 539.2 Miliar Terserap')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('Rp 285.3 M', 'Sisa Anggaran Belum Terserap', Icons.pie_chart_outline_rounded, const Color(0xFF8B5CF6), 'Batas Akhir: 31 Desember')),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // =================================================================
                  // 3. GRAFIK KEUANGAN (BAR CHART) & ALOKASI (DONUT CHART)
                  // =================================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BAGIAN KIRI: GRAFIK BATANG (PENDAPATAN VS REALISASI)
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Grafik Target vs Realisasi Pendapatan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              const SizedBox(height: 8),
                              const Text('Perbandingan data per Kuartal (dalam Miliar Rupiah)', style: TextStyle(fontSize: 13, color: Colors.grey)),
                              const SizedBox(height: 40),
                              SizedBox(height: 300, child: _buildBarChart()),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegendItem('Target Anggaran', const Color(0xFF94A3B8)),
                                  const SizedBox(width: 24),
                                  _buildLegendItem('Realisasi Pendapatan', const Color(0xFF2563EB)), 
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      
                      // BAGIAN KANAN: GRAFIK DONAT (ALOKASI BELANJA)
                      Expanded(
                        flex: 4,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Postur Alokasi Belanja Daerah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              const SizedBox(height: 8),
                              const Text('Berdasarkan kategori pembelanjaan APBD', style: TextStyle(fontSize: 13, color: Colors.grey)),
                              const SizedBox(height: 40),
                              SizedBox(height: 220, child: _buildDonutChart()),
                              const SizedBox(height: 32),
                              _buildDonutLegend('Belanja Operasi (Gaji & Jasa)', const Color(0xFF2563EB), '60%'),
                              _buildDonutLegend('Belanja Modal (Infrastruktur)', const Color(0xFF10B981), '25%'),
                              _buildDonutLegend('Belanja Transfer (Bansos, dll)', const Color(0xFFF59E0B), '10%'),
                              _buildDonutLegend('Belanja Tak Terduga', const Color(0xFFEF4444), '5%'),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 40),

                  // =================================================================
                  // 4. TABEL SERAPAN ANGGARAN OPD
                  // =================================================================
                  const Text('Daftar Serapan Anggaran Tertinggi per OPD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
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
                          DataColumn(label: Text('NAMA INSTANSI (OPD)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF565F69), fontSize: 12))),
                          DataColumn(label: Text('PAGU ANGGARAN', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF565F69), fontSize: 12))),
                          DataColumn(label: Text('REALISASI BELANJA', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF565F69), fontSize: 12))),
                          DataColumn(label: Text('PERSENTASE', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF565F69), fontSize: 12))),
                        ],
                        rows: [
                          _buildTopOpdRow('1', 'Dinas Pendidikan Kota', 'Rp 210.5 M', 'Rp 185.2 M', 88.0),
                          _buildTopOpdRow('2', 'Dinas Kesehatan & RSUD', 'Rp 180.2 M', 'Rp 145.9 M', 81.0),
                          _buildTopOpdRow('3', 'Dinas PUPR', 'Rp 150.0 M', 'Rp 115.5 M', 77.0),
                          _buildTopOpdRow('4', 'Dinas Sosial', 'Rp 45.3 M', 'Rp 32.1 M', 70.8),
                          _buildTopOpdRow('5', 'Satpol PP & Damkar', 'Rp 22.1 M', 'Rp 12.5 M', 56.5),
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
  // WIDGET BANTUAN GRAFIK & TABEL
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
              Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
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
        maxY: 250, // Skala Miliar
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                Widget text;
                switch (value.toInt()) {
                  case 0: text = const Text('Kuartal I', style: style); break;
                  case 1: text = const Text('Kuartal II', style: style); break;
                  case 2: text = const Text('Kuartal III', style: style); break;
                  case 3: text = const Text('Kuartal IV', style: style); break;
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
                return Text('${value.toInt()} M', style: const TextStyle(color: Colors.grey, fontSize: 12));
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
          _makeGroupData(0, 200, 180), // Q1: Target 200M, Realisasi 180M
          _makeGroupData(1, 210, 205), // Q2
          _makeGroupData(2, 210, 190), // Q3
          _makeGroupData(3, 204.5, 120), // Q4 (Belum selesai)
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double target, double realisasi) {
    return BarChartGroupData(
      x: x,
      barRods: [
        // Batang Target (Abu-abu)
        BarChartRodData(
          toY: target, 
          color: const Color(0xFFCBD5E1), 
          width: 20,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
        ),
        // Batang Realisasi (Biru)
        BarChartRodData(
          toY: realisasi, 
          color: const Color(0xFF2563EB), 
          width: 20,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
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
          PieChartSectionData(color: const Color(0xFF2563EB), value: 60, title: '60%', radius: 45, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: const Color(0xFF10B981), value: 25, title: '25%', radius: 45, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: const Color(0xFFF59E0B), value: 10, title: '10%', radius: 45, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: const Color(0xFFEF4444), value: 5, title: '5%', radius: 35, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
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

  DataRow _buildTopOpdRow(String rank, String namaOpd, String pagu, String realisasi, double persentase) {
    Color progressColor = persentase >= 80 ? const Color(0xFF10B981) : (persentase >= 60 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));

    return DataRow(
      cells: [
        DataCell(
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: rank == '1' || rank == '2' || rank == '3' ? const Color(0xFFDBEAFE) : Colors.grey.shade100, shape: BoxShape.circle),
            child: Text(rank, style: TextStyle(fontWeight: FontWeight.bold, color: rank == '1' || rank == '2' || rank == '3' ? const Color(0xFF2563EB) : Colors.grey.shade600)),
          )
        ),
        DataCell(Text(namaOpd, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B1C30)))),
        DataCell(Text(pagu, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600))),
        DataCell(Text(realisasi, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(
          Row(
            children: [
              SizedBox(
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: persentase / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('$persentase%', style: TextStyle(color: progressColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          )
        ),
      ]
    );
  }
}