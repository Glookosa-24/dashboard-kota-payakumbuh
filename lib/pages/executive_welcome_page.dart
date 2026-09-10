import 'package:flutter/material.dart';
import 'executive_dashboard_page.dart'; 
import 'admin_executive_dashboard_page.dart'; // Memanggil halaman khusus admin eksekutif

class ExecutiveWelcomePage extends StatelessWidget {
  const ExecutiveWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. TOP NAVBAR (Menu Atas)
          _buildTopNavbar(context),
          
          // 2. HERO SECTION (Konten Utama)
          Expanded(
            child: _buildHeroSection(context),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // NAVBAR ATAS (Menu Beranda, Kinerja, dll & Tombol Masuk)
  // =========================================================================
  Widget _buildTopNavbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          // Logo Kiri
          Row(
            children: [
              Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Lambang_Kota_Payakumbuh.png/432px-Lambang_Kota_Payakumbuh.png', height: 40, errorBuilder: (c, e, s) => const Icon(Icons.shield, color: Color(0xFF003F87), size: 40)),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EXECUTIVE DASHBOARD', style: TextStyle(color: Color(0xFF003F87), fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  Text('Kota Payakumbuh', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          
          const Spacer(),

          // Menu Tengah
          Row(
            children: [
              _navMenu('Beranda', true),
            ],
          ),
          
          const SizedBox(width: 32),

          // --- TOMBOL LOGIN ADMIN (Desain Sekunder) ---
          // PERBAIKAN: Mengganti 'child:' menjadi 'label:' karena menggunakan .icon
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              // Menampilkan Pop-Up Form Login
              _showAdminLoginDialog(context);
            },
            icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
            label: const Text('Login Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), // <--- SUDAH DIPERBAIKI DI SINI
          ),
          
          const SizedBox(width: 16),

          // --- TOMBOL MASUK PIMPINAN (Desain Utama) ---
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4338CA), 
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExecutiveDashboardPage()),
              );
            },
            child: const Text('Masuk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _navMenu(String title, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            title, 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 14, 
              color: isActive ? Colors.black : Colors.black87
            )
          ),
          if (!isActive) const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.black54)
        ],
      ),
    );
  }

  // =========================================================================
  // POP-UP FORM LOGIN ADMIN EKSEKUTIF
  // =========================================================================
  void _showAdminLoginDialog(BuildContext context) {
    final TextEditingController usernameCtrl = TextEditingController();
    final TextEditingController passwordCtrl = TextEditingController();
    bool isObscure = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo & Judul
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.admin_panel_settings_rounded, size: 48, color: Colors.amber),
                    ),
                    const SizedBox(height: 24),
                    const Text('Login Admin Eksekutif', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 8),
                    const Text('Masukkan kredensial Anda untuk mengelola data.', style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
                    const SizedBox(height: 32),

                    // Field Username
                    TextField(
                      controller: usernameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFFF4F7FC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF003F87), width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Field Password
                    TextField(
                      controller: passwordCtrl,
                      obscureText: isObscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey, size: 20),
                          onPressed: () => setDialogState(() => isObscure = !isObscure),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF4F7FC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF003F87), width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tombol Aksi
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A), // Warna gelap khas Admin Eksekutif
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          // LOGIKA LOGIN SEDERHANA
                          if (usernameCtrl.text == 'admin' && passwordCtrl.text == 'admin123') {
                            Navigator.pop(ctx); // Tutup dialog login
                            Navigator.push( // Buka halaman Admin Eksekutif
                              context,
                              MaterialPageRoute(builder: (context) => const AdminExecutiveDashboardPage()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Username atau Password salah!'), backgroundColor: Colors.red),
                            );
                          }
                        },
                        child: const Text('Masuk Sistem', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                    )
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  // =========================================================================
  // HERO SECTION (Desain Teks Kiri & Foto Pimpinan Kanan dengan Background Biru)
  // =========================================================================
  Widget _buildHeroSection(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // --- BACKGROUND SHAPES (Efek Ombak Biru di Kanan) ---
        Positioned(
          right: -150,
          top: -200,
          bottom: -200,
          child: Transform.rotate(
            angle: -0.25, 
            child: Container(
              width: size.width * 0.55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0056B3), Color(0xFF003F87), Color(0xFF00224D)],
                ),
                borderRadius: BorderRadius.circular(150),
                boxShadow: [BoxShadow(color: const Color(0xFF003F87).withValues(alpha: 0.3), blurRadius: 40, offset: const Offset(-20, 0))],
              ),
            ),
          ),
        ),

        // --- ORNAMEN GARIS GRAFIK DI LATAR BELAKANG BIRU ---
        Positioned(
          right: 50,
          top: 100,
          child: Icon(Icons.show_chart_rounded, size: 300, color: Colors.white.withValues(alpha: 0.05)),
        ),

        // --- KONTEN UTAMA (Kiri Teks, Kanan Foto) ---
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Row(
            children: [
              // BAGIAN KIRI: Teks Deskripsi
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(left: 80),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    
                      const Text('EXECUTIVE DASHBOARD', style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: Color(0xFF004494), letterSpacing: 2)),
                      const SizedBox(height: 8),
                      // Subjudul
                      const Text(
                        'SISTEM INFORMASI EKSEKUTIF\nKOTA PAYAKUMBUH',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF333333), height: 1.3),
                      ),
                      const SizedBox(height: 24),
                      // Garis Strip (Biru dan Hitam)
                      Row(
                        children: [
                          Container(width: 40, height: 6, decoration: BoxDecoration(color: const Color(0xFF0056B3), borderRadius: BorderRadius.circular(4))),
                          const SizedBox(width: 8),
                          Container(width: 16, height: 6, decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(4))),
                        ],
                      ),
                      const SizedBox(height: 48),
                      // Logo Pemda Bawah
                      Row(
                        children: [
                          Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Lambang_Kota_Payakumbuh.png/432px-Lambang_Kota_Payakumbuh.png', height: 50, errorBuilder: (c, e, s) => const Icon(Icons.shield, color: Color(0xFF003F87), size: 50)),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PEMERINTAH KOTA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF004494))),
                              Text('PAYAKUMBUH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF004494))),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              // BAGIAN KANAN: Foto Pimpinan Daerah
              Expanded(
                flex: 6,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // FOTO WAKIL WALIKOTA (Di Belakang Kanan)
                    Positioned(
                      right: 40,
                      bottom: 0,
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/Wakil_Wali_Kota_Payakumbuh_Elzadaswarman.jpg', 
                            height: 380,
                            errorBuilder: (c, e, s) => Container(height: 380, width: 250, color: Colors.white24, child: const Icon(Icons.person, size: 100, color: Colors.white)),
                          ),
                          _buildNamePlate('Elzadaswarman, SKM., MPPM', 'Pj. Wakil Walikota'),
                        ],
                      ),
                    ),

                    // FOTO WALIKOTA (Di Depan Kiri)
                    Positioned(
                      right: 280, 
                      bottom: 0,
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/Wali_Kota_Payakumbuh_Zulmaeta.jpg', 
                            height: 480,
                            errorBuilder: (c, e, s) => Container(height: 480, width: 300, color: Colors.white38, child: const Icon(Icons.person, size: 150, color: Colors.white)),
                          ),
                          _buildNamePlate('Dr. dr. Zulmaeta, Sp.OG-KFM', 'Pj. Walikota Payakumbuh'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Label Nama di Bawah Foto Pimpinan
  Widget _buildNamePlate(String name, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))],
        border: const Border(bottom: BorderSide(color: Color(0xFFD4AF37), width: 4)), // Garis emas di bawah nama
      ),
      child: Column(
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B1C30))),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}