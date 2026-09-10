import 'package:flutter/material.dart';

class KpiEksekutifWidget extends StatelessWidget {
  const KpiEksekutifWidget({super.key});

  // 1. DATA DUMMY (Sesuai Konsep JSON Eksekutif)
  final Map<String, dynamic> kpiData = const {
    "apbd": {"realisasi": "Rp 542,2 M", "persen": "63.5%", "teks_bawah": "Dari target Rp 854 M"},
    "inflasi": {"nilai": "2.45%", "status": "Terkendali ↓", "teks_bawah": "Inflasi YoY Daerah"},
    "kepuasan": {"skor": "88.5", "status": "Sangat Baik", "teks_bawah": "Skala Maksimal 100"},
    "laporan": {"total": "34 Laporan", "status": "92% Selesai", "teks_bawah": "11 Selesai • 18 Proses"}
  };

  @override
  Widget build(BuildContext context) {
    // 2. PEMBAGIAN LAYOUT (Mendeteksi ukuran layar)
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;
        
        // Jika layar laptop/web, tampilkan 4 sejajar. Jika HP, tampilkan 2 atas 2 bawah.
        if (isDesktop) {
          return Row(
            children: [
              Expanded(child: _buildKpiCard(Icons.account_balance_wallet_rounded, Colors.blue, "Realisasi APBD", kpiData["apbd"]["realisasi"], kpiData["apbd"]["teks_bawah"], kpiData["apbd"]["persen"], Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildKpiCard(Icons.trending_down_rounded, Colors.green, "Inflasi Daerah", kpiData["inflasi"]["nilai"], kpiData["inflasi"]["teks_bawah"], kpiData["inflasi"]["status"], Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildKpiCard(Icons.star_rounded, Colors.orange, "Indeks Kepuasan", kpiData["kepuasan"]["skor"], kpiData["kepuasan"]["teks_bawah"], kpiData["kepuasan"]["status"], Colors.orange)),
              const SizedBox(width: 16),
              Expanded(child: _buildKpiCard(Icons.forum_rounded, Colors.purple, "Status Laporan", kpiData["laporan"]["total"], kpiData["laporan"]["teks_bawah"], kpiData["laporan"]["status"], Colors.purple)),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildKpiCard(Icons.account_balance_wallet_rounded, Colors.blue, "Realisasi APBD", kpiData["apbd"]["realisasi"], kpiData["apbd"]["teks_bawah"], kpiData["apbd"]["persen"], Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildKpiCard(Icons.trending_down_rounded, Colors.green, "Inflasi Daerah", kpiData["inflasi"]["nilai"], kpiData["inflasi"]["teks_bawah"], kpiData["inflasi"]["status"], Colors.green)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildKpiCard(Icons.star_rounded, Colors.orange, "Indeks Kepuasan", kpiData["kepuasan"]["skor"], kpiData["kepuasan"]["teks_bawah"], kpiData["kepuasan"]["status"], Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildKpiCard(Icons.forum_rounded, Colors.purple, "Status Laporan", kpiData["laporan"]["total"], kpiData["laporan"]["teks_bawah"], kpiData["laporan"]["status"], Colors.purple)),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  // 3. ANATOMI KARTU METRIK (Desain Minimalis)
  Widget _buildKpiCard(IconData icon, Color iconColor, String title, String mainValue, String subtitle, String badgeText, Color badgeColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Atas: Ikon Latar Transparan & Pil Badge Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Bagian Tengah: Angka Utama (Paling Menonjol)
          Text(mainValue, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0B1C30), letterSpacing: -0.5)),
          const SizedBox(height: 6),
          
          // Bagian Bawah: Teks Konteks Tambahan
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}