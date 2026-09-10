import 'package:flutter/material.dart';
import '../pages/sector_detail_page.dart'; // <-- Import halaman baru

class DashboardCategoryGrid extends StatelessWidget {
  final bool isWideScreen;
  final ValueChanged<String>? onCategoryTap;

  const DashboardCategoryGrid({
    super.key,
    required this.isWideScreen,
    this.onCategoryTap,
  });

  static const List<Map<String, dynamic>> _categories = [
    {'id': 'Pemerintahan', 'title': 'Pemerintahan', 'desc': 'Tata kelola birokrasi & MPP', 'icon': Icons.account_balance_rounded, 'color': Color(0xFF003F87), 'bg': Color(0xFFD7E2FF)},
    {'id': 'Pariwisata', 'title': 'Pariwisata', 'desc': 'Ngalau & Batang Agam', 'icon': Icons.tour_rounded, 'color': Color(0xFF204171), 'bg': Color(0xFFD6E3FF)},
    {'id': 'Pendidikan', 'title': 'Pendidikan', 'desc': '184 Sekolah & Beasiswa', 'icon': Icons.school_rounded, 'color': Color(0xFF0056B3), 'bg': Color(0xFFDAE4EF)},
    {'id': 'Kesehatan', 'title': 'Kesehatan', 'desc': 'RSUD & UHC BPJS 98%', 'icon': Icons.favorite_rounded, 'color': Color(0xFFBA1A1A), 'bg': Color(0xFFFFDAD6)},
    {'id': 'Infrastruktur', 'title': 'Infrastruktur', 'desc': 'Jalan 412 km & Smart PJU', 'icon': Icons.construction_rounded, 'color': Color(0xFF003F87), 'bg': Color(0xFFD7E2FF)},
    {'id': 'Penduduk', 'title': 'Penduduk', 'desc': '141k Jiwa & e-KTP Digital', 'icon': Icons.groups_rounded, 'color': Color(0xFF204171), 'bg': Color(0xFFD6E3FF)},
    {'id': 'Industri & UMKM', 'title': 'Industri & UMKM', 'desc': 'Sentra Rendang & 2.850 Unit', 'icon': Icons.storefront_rounded, 'color': Color(0xFFD97706), 'bg': Color(0xFFFEF3C7)},
    {'id': 'Keuangan', 'title': 'Keuangan', 'desc': 'APBD Rp 824 M & Opini WTP', 'icon': Icons.credit_card_rounded, 'color': Color(0xFF059669), 'bg': Color(0xFFD1FAE5)},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(
          child: Column(
            children: [
              Text(
                'Dashboard Pilihan',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 4),
              Text(
                'Akses cepat ke kategori data utama Kota Payakumbuh.',
                style: TextStyle(fontSize: 14, color: Color(0xFFEFF4FF)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWideScreen ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isWideScreen ? 1.25 : 1.1,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final cat = _categories[index];
            return InkWell(
              onTap: () {
                if (onCategoryTap != null) {
                  onCategoryTap!(cat['id']);
                }
                // NAVIGASI LANGSUNG KE HALAMAN DETAIL SEKTOR:
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SectorDetailPage(sectorId: cat['id']),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black..withValues(alpha:0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: cat['bg'],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(cat['icon'], color: cat['color'], size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      cat['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0B1C30)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat['desc'],
                      style: const TextStyle(fontSize: 11, color: Color(0xFF565F69)),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}