import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatistikKepegawaianPage extends StatefulWidget {
  const StatistikKepegawaianPage({super.key});

  @override
  State<StatistikKepegawaianPage> createState() => _StatistikKepegawaianPageState();
}

class _StatistikKepegawaianPageState extends State<StatistikKepegawaianPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003F87), // Tema Biru Utama
        foregroundColor: Colors.white,
        title: const Text('Statistik Kepegawaian (ASN & PPPK)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                  const Text('Beranda  >  Pemerintahan  >  Statistik Kepegawaian', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dashboard Demografi Aparatur Sipil Negara', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF2563EB)),
                            SizedBox(width: 8),
                            Text('Kuartal III - 2026', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
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
                      Expanded(child: _buildKpiCard('3.420', 'Total Aparatur Negara', Icons.groups_rounded, const Color(0xFF2563EB), 'Seluruh OPD Kota')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('2.150', 'Jumlah Pegawai Negeri (PNS)', Icons.badge_rounded, const Color(0xFF10B981), '62.8% dari Total')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('1.270', 'Pegawai Kontrak (PPPK)', Icons.assignment_ind_rounded, const Color(0xFFF59E0B), '37.2% dari Total')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('58%', 'Rasio Pegawai Perempuan', Icons.pie_chart_rounded, const Color(0xFF8B5CF6), 'Inklusi Terjaga')),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // =================================================================
                  // 3. GRAFIK KUNJUNGAN (BAR CHART) & DISTRIBUSI (DONUT CHART)
                  // =================================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BAGIAN KIRI: GRAFIK BATANG (SEBARAN GOLONGAN)
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Sebaran Pegawai Berdasarkan Golongan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              const SizedBox(height: 8),
                              const Text('Perbandingan jumlah PNS dan PPPK di setiap golongan', style: TextStyle(fontSize: 13, color: Colors.grey)),
                              const SizedBox(height: 40),
                              SizedBox(height: 300, child: _buildBarChart()),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegendItem('Pegawai Negeri Sipil (PNS)', const Color(0xFF2563EB)),
                                  const SizedBox(width: 24),
                                  _buildLegendItem('Pegawai PPPK', const Color(0xFF10B981)), // Hijau
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      
                      // BAGIAN KANAN: GRAFIK DONAT (TINGKAT PENDIDIKAN)
                      Expanded(
                        flex: 4,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Demografi Tingkat Pendidikan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              const SizedBox(height: 8),
                              const Text('Kualifikasi akademik SDM Aparatur', style: TextStyle(fontSize: 13, color: Colors.grey)),
                              const SizedBox(height: 40),
                              SizedBox(height: 220, child: _buildDonutChart()),
                              const SizedBox(height: 32),
                              _buildDonutLegend('Sarjana (S1) / D4', const Color(0xFF2563EB), '65%'),
                              _buildDonutLegend('Pascasarjana (S2 / S3)', const Color(0xFF10B981), '15%'),
                              _buildDonutLegend('Diploma (D3)', const Color(0xFFF59E0B), '10%'),
                              _buildDonutLegend('SMA / Sederajat', const Color(0xFF94A3B8), '10%'),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 40),

                  // =================================================================
                  // 4. TABEL TOP 5 OPD
                  // =================================================================
                  const Text('Top 5 OPD dengan Pegawai Terbanyak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
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
                          DataColumn(label: Text('TOTAL PEGAWAI', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF565F69), fontSize: 12))),
                          DataColumn(label: Text('DOMINASI PROFESI', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF565F69), fontSize: 12))),
                          DataColumn(label: Text('PERTUMBUHAN', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF565F69), fontSize: 12))),
                        ],
                        rows: [
                          _buildTopOpdRow('1', 'Dinas Pendidikan Kota', '1.450 Orang', 'Guru Tersertifikasi', true, '+5% (PPPK Baru)'),
                          _buildTopOpdRow('2', 'Dinas Kesehatan & RSUD', '680 Orang', 'Tenaga Kesehatan', true, '+3% (Rekrutmen)'),
                          _buildTopOpdRow('3', 'Sekretariat Daerah', '210 Orang', 'Staf Administrasi', false, 'Tetap'),
                          _buildTopOpdRow('4', 'Satpol PP & Damkar', '150 Orang', 'Tenaga Pengamanan', false, '-2% (Pensiun)'),
                          _buildTopOpdRow('5', 'Dinas PUPR', '120 Orang', 'Tenaga Teknis', true, '+1%'),
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
        maxY: 2200,
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
                  case 0: text = const Text('Golongan I', style: style); break;
                  case 1: text = const Text('Golongan II', style: style); break;
                  case 2: text = const Text('Golongan III', style: style); break;
                  case 3: text = const Text('Golongan IV', style: style); break;
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
                return Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 12));
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
          // Gol I
          _makeGroupData(0, 150, 50),
          // Gol II
          _makeGroupData(1, 400, 200),
          // Gol III (Paling banyak)
          _makeGroupData(2, 1100, 900),
          // Gol IV
          _makeGroupData(3, 500, 120),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double yPns, double yPppk) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: yPns + yPppk, // Stacked bar (Tumpuk)
          color: const Color(0xFF2563EB), 
          width: 32,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
          rodStackItems: [
            BarChartRodStackItem(0, yPns, const Color(0xFF2563EB)), // PNS (Biru)
            BarChartRodStackItem(yPns, yPns + yPppk, const Color(0xFF10B981)), // PPPK (Hijau Emerald)
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
          PieChartSectionData(color: const Color(0xFF2563EB), value: 65, title: '65%', radius: 45, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: const Color(0xFF10B981), value: 15, title: '15%', radius: 45, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: const Color(0xFFF59E0B), value: 10, title: '10%', radius: 45, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: const Color(0xFF94A3B8), value: 10, title: '10%', radius: 35, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
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

  DataRow _buildTopOpdRow(String rank, String namaOpd, String totalPegawai, String dominasi, bool isUp, String trendTxt) {
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
        DataCell(Text(totalPegawai, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
            child: Text(dominasi, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
          )
        ),
        DataCell(
          Row(
            children: [
              Icon(isUp ? Icons.trending_up_rounded : (trendTxt == 'Tetap' ? Icons.horizontal_rule_rounded : Icons.trending_down_rounded), color: isUp ? const Color(0xFF10B981) : (trendTxt == 'Tetap' ? Colors.grey : const Color(0xFFEF4444)), size: 18),
              const SizedBox(width: 6),
              Text(trendTxt, style: TextStyle(color: isUp ? const Color(0xFF10B981) : (trendTxt == 'Tetap' ? Colors.grey : const Color(0xFFEF4444)), fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          )
        ),
      ]
    );
  }
}