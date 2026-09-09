import 'package:flutter/material.dart';
import '../pages/executive_welcome_page.dart'; 

class CustomEndDrawer extends StatelessWidget {
  final Function(String)? onMenuItemSelected;

  const CustomEndDrawer({
    super.key,
    this.onMenuItemSelected,
  });

  // KITA TAMBAHKAN KUNCI 'target' AGAR LABEL MENU DAN ID SISTEM BISA BERBEDA NAMA
  static const List<Map<String, dynamic>> _menuItems = [
    {'title': 'Topik', 'target': 'Topik', 'icon': Icons.topic_outlined},
    {'title': 'Pendidikan', 'target': 'Pendidikan', 'icon': Icons.school_outlined},
    {'title': 'Kesehatan', 'target': 'Kesehatan', 'icon': Icons.favorite_border_rounded},
    {'title': 'Kependudukan', 'target': 'Penduduk', 'icon': Icons.people_outline_rounded}, // Teks 'Kependudukan' -> Kirim 'Penduduk'
    {'title': 'Industri & UMKM', 'target': 'Industri & UMKM', 'icon': Icons.storefront_outlined}, // Nama diubah menjadi Industri & UMKM
    {'title': 'Ekonomi dan Keuangan', 'target': 'Keuangan', 'icon': Icons.account_balance_wallet_outlined}, // Teks 'Ekonomi dan Keuangan' -> Kirim 'Keuangan'
    {'title': 'Eksplorasi Dashboard', 'target': 'Eksplorasi Dashboard', 'icon': Icons.explore_outlined},
    {'title': 'Tentang', 'target': 'Tentang', 'icon': Icons.info_outline_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF003F87), // Latar belakang biru utama
      surfaceTintColor: Colors.transparent,
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Bagian Header (Judul & Ikon Silang X Putih)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.dashboard_customize_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Navigasi Portal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                    tooltip: 'Tutup Menu',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(color: Colors.white24, thickness: 1),
              const SizedBox(height: 16),

              // 2. Bagian Body (Daftar Menu Rata Kiri Teks Putih)
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _menuItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    final String title = item['title'];
                    final String target = item['target']; // Variabel target baru
                    final IconData icon = item['icon'];

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();

                          if (onMenuItemSelected != null) {
                            // YANG DIKIRIM KE MAIN.DART ADALAH 'target', BUKAN 'title'
                            onMenuItemSelected!(target); 
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Membuka menu: $title'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: const Color(0xFF204171),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        hoverColor: Colors.white.withValues(alpha: 0.12),
                        splashColor: Colors.white.withValues(alpha: 0.2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Row(
                            children: [
                              Icon(icon, color: Colors.white70, size: 20),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),
              const Divider(color: Colors.white24, thickness: 1),
              const SizedBox(height: 8),

              // --- TOMBOL KHUSUS LOGIN ADMIN ---
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    if (onMenuItemSelected != null) {
                      onMenuItemSelected!('Login Admin'); // Memicu navigasi ke halaman Login
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  hoverColor: Colors.white.withValues(alpha: 0.12),
                  splashColor: Colors.white.withValues(alpha: 0.2),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child:Row(
                      children: [
                        const Icon(Icons.admin_panel_settings, color: Color(0xFFF59E0B), size: 20),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Login Admin',
                            style: TextStyle(
                              color: Color(0xFFF59E0B), // Warna kuning/emas
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              // ---------------------------------

              const SizedBox(height: 8),
              const Divider(color: Colors.white24, thickness: 1),
              const SizedBox(height: 16),

              // 3. Bagian Footer (Tombol Menonjol 'Executive Dashboard')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // 1. Tutup drawer-nya terlebih dahulu
                    Navigator.of(context).pop();

                    // 2. Buka halaman Pendaratan (Welcome Page) yang baru
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExecutiveWelcomePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.analytics_rounded, color: Color(0xFF003F87), size: 20),
                  
                  
                  label: const Text(
                    'Executive Dashboard',
                    style: TextStyle(
                      color: Color(0xFF003F87),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF003F87),
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}