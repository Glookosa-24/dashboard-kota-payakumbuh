import 'package:flutter/material.dart';
import 'widgets/feedback_widget.dart'; 
import 'widgets/kpi_eksekutif_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/login_admin_page.dart';
import 'pages/sector_detail_page.dart'; 
import 'widgets/custom_end_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/navbar_header.dart';
import 'widgets/hero_banner.dart';
import 'widgets/kpi_metric_cards.dart';
import 'widgets/dashboard_category_grid.dart';
import 'widgets/interactive_map_section.dart';
import 'widgets/iot_cybersecurity_panel.dart';
import 'widgets/umkm_trend_chart.dart';
import 'widgets/sector_summary_grid.dart';
import 'widgets/footer_section.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PayakumbuhDashboardApp());
}

class PayakumbuhDashboardApp extends StatelessWidget {
  const PayakumbuhDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Dashboard Kota Payakumbuh',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode, // Membaca sakelar
          
          // ==========================================================
          // MODE SIANG (KEMBALI KE DESAIN BIRU ELEGAN ASLI MILIK ANDA)
          // ==========================================================
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF1C4B9B), 
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.light,
              seedColor: const Color(0xFF003F87),
              primary: const Color(0xFF003F87),
              secondary: const Color(0xFF565F69),
              tertiary: const Color(0xFF204171),
              surface: const Color(0xFFF8F9FF),
            ),
            textTheme: GoogleFonts.interTextTheme(
              ThemeData.light().textTheme,
            ),
          ),
          
          // ==========================================================
          // MODE MALAM (DARK MODE)
          // ==========================================================
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF08101A), // Hitam kebiruan pekat untuk kesan malam
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF38BDF8),
              primary: const Color(0xFF38BDF8),
              secondary: const Color(0xFF94A3B8),
              surface: const Color(0xFF131E2E), // Warna kotak/panel gelap
            ),
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
              bodyColor: Colors.white, 
              displayColor: Colors.white,
            ),
          ),
          
          home: const DashboardHomeScreen(),
        );
      },
    );
  }
}
class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String _activeNav = 'Dashboard';
  String _selectedDistrict = 'barat';
  
  // 1. GlobalKey untuk masing-masing bagian / section
  final GlobalKey _dashboardKey = GlobalKey();
  final GlobalKey _statistikKey = GlobalKey();
  final GlobalKey _publikasiKey = GlobalKey();
  final GlobalKey _petaKey = GlobalKey();

  // 2. Fungsi navigasi scroll otomatis ke section yang dituju
  void _navigateToSection(String sectionName) {
    setState(() {
      _activeNav = sectionName;
    });

    GlobalKey? targetKey;
    switch (sectionName) {
      case 'Dashboard':
        targetKey = _dashboardKey;
        break;
      case 'Statistik':
        targetKey = _statistikKey;
        break;
      case 'Publikasi':
        targetKey = _publikasiKey;
        break;
      case 'Peta':
        targetKey = _petaKey;
        break;
    }

    if (targetKey?.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey!.currentContext!,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
        alignment: 0.05,
      );
    }
  }

  void _onDistrictSelected(String districtId) {
    setState(() {
      _selectedDistrict = districtId;
    });
  }

  void _onCategorySelected(String category) {
    // Memperbaiki parameter dari 'category:' menjadi 'sectorId:' sesuai permintaan SectorDetailPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SectorDetailPage(sectorId: category),
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membuka kategori: $category'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavbarHeader(
        activeTab: _activeNav,
        onNavTap: _navigateToSection, // Hubungkan fungsi navigasi ke navbar
      ),
      endDrawer: CustomEndDrawer(
        onMenuItemSelected: (menu) {
          if (menu == 'Ekplorasi Dashboard') {
            _navigateToSection('Dashboard');
          } else if (menu == 'Login Admin') {  
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginAdminPage()),
            );
          } else if (menu == 'Pendidikan'|| menu ==
           'Kesehatan' || menu == 'Pemerintahan' || menu == 
           'Industri & UMKM' || menu == 'Pariwisata' || menu == 'Infrastruktur' || menu == 'Penduduk' || menu == 'Keuangan') {
            _onCategorySelected(menu);
          } else {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Membuka menu: $menu'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF204171),
              ),
            );
          }
        },
      ),
      
      // =======================================================================
      // STACK DITAMBAHKAN DI SINI AGAR TOMBOL FEEDBACK MELAYANG DI ATAS KONTEN
      // =======================================================================
      body: Stack(
        children: [
          // LAPISAN 1: Konten Utama (Scrollable Dashboard)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth >= 1024;
              final horizontalPadding = isWideScreen ? 40.0 : 16.0;

              return SingleChildScrollView(
                controller: _scrollController,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          
                          // Section 1: Dashboard (Hero Banner)
                          Container(
                            key: _dashboardKey,
                            child: HeroBanner(
                              isWideScreen: isWideScreen,
                              onSearch: (query) {
                                if (query.trim().isEmpty) return;
                                final daftarSektor = [
                                  'Pemerintahan', 'Pariwisata', 'Pendidikan', 'Kesehatan', 
                                  'Infrastruktur', 'Penduduk', 'Industri & UMKM', 'Keuangan'
                                ];
                                final hasilCari = daftarSektor.firstWhere(
                                  (sektor) => sektor.toLowerCase().contains(query.toLowerCase()),
                                  orElse: () => '',
                                );
                                if (hasilCari.isNotEmpty) {
                                  _onCategorySelected(hasilCari);
                                } else {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Data "$query" tidak ditemukan. Coba ketik: Kesehatan, Pendidikan, dll.'),
                                      backgroundColor: const Color(0xFFBA1A1A), // Warna merah
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }  
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Section 1.5: Panel Metrik Eksekutif
                          const KpiEksekutifWidget(),

                          const SizedBox(height: 24),

                          // Section 2: Statistik (KPI Metrik & Grafik UMKM)
                          Container(
                            key: _statistikKey,
                            child: Column(
                              children: [
                                KpiMetricCards(isWideScreen: isWideScreen),
                                const SizedBox(height: 48),
                                UmkmTrendChartCard(isWideScreen: isWideScreen),
                              ],
                            ),
                          ),
                          const SizedBox(height: 56),

                          // Section 3: Publikasi (Grid Kategori & Ringkasan Sektor)
                          Container(
                            key: _publikasiKey,
                            child: Column(
                              children: [
                                DashboardCategoryGrid(
                                  isWideScreen: isWideScreen,
                                  onCategoryTap: _onCategorySelected,
                                ),
                                const SizedBox(height: 48),
                                SectorSummaryGrid(isWideScreen: isWideScreen),
                              ],
                            ),
                          ),
                          const SizedBox(height: 56),

                          // Section 4: Peta (Peta Wilayah & Sebaran Sektor)
                          Container(
                            key: _petaKey,
                            child: InteractiveMapSection(
                              isWideScreen: isWideScreen,
                              selectedDistrict: _selectedDistrict,
                              onDistrictTap: _onDistrictSelected,
                            ),
                          ),
                          const SizedBox(height: 56),

                          // Panel IoT & Keamanan Siber
                          IotCybersecurityPanel(isWideScreen: isWideScreen),
                          const SizedBox(height: 64),

                          // Footer
                          FooterSection(isWideScreen: isWideScreen),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // ===================================================================
          // LAPISAN 2: Tombol Feedback Melayang (Posisinya selalu tetap di kanan)
          // ===================================================================
          const FeedbackSideButton(),

        ],
      ),
    );
  } 
}