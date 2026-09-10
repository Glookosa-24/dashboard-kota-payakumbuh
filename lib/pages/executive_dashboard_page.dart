import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExecutiveDashboardPage extends StatefulWidget {
  const ExecutiveDashboardPage({super.key});

  @override
  State<ExecutiveDashboardPage> createState() => _ExecutiveDashboardPageState();
}

class _ExecutiveDashboardPageState extends State<ExecutiveDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _bottomNavIndex = 0;
  
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _selectedStatus = 'Semua';

  // STATE: FILTER LAYAR DASHBOARD
  String _dashTahun = 'Tahun 2024';
  String _dashTriwulan = 'Triwulan II';
  String _dashKategori = 'Semua OPD';

  late Stream<QuerySnapshot> _apbdStream;

  @override
  void initState() {
    super.initState();
    _apbdStream = FirebaseFirestore.instance.collection('realisasi_apbd').orderBy('waktu', descending: true).snapshots();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.index != _tabController.previousIndex) {
        setState(() {}); 
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String formatRupiahSingkat(double angka) {
    if (angka >= 1000000000000) return '${(angka / 1000000000000).toStringAsFixed(1)} T';
    if (angka >= 1000000000) return '${(angka / 1000000000).toStringAsFixed(1)} M';
    if (angka >= 1000000) return '${(angka / 1000000).toStringAsFixed(1)} Jt';
    return angka.toStringAsFixed(0);
  }

  Map<String, dynamic> getStatus(double persen) {
    if (persen >= 75) {
      return {'label': 'AMAN', 'color': const Color(0xFF10B981), 'bgColor': const Color(0xFFD1FAE5)};
    }
    if (persen >= 50) {
      return {'label': 'WARNING', 'color': const Color(0xFFF59E0B), 'bgColor': const Color(0xFFFEF3C7)};
    }
    return {'label': 'CRITICAL', 'color': const Color(0xFFEF4444), 'bgColor': const Color(0xFFFEE2E2)};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      bottomNavigationBar: _tabController.index == 1 
        ? Container(
            decoration: BoxDecoration(
              color: Colors.white, 
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05), 
                  blurRadius: 10, 
                  offset: const Offset(0, -5)
                )
              ]
            ),
            child: BottomNavigationBar(
              currentIndex: _bottomNavIndex,
              onTap: (index) => setState(() => _bottomNavIndex = index),
              selectedItemColor: const Color(0xFF1D4ED8), 
              unselectedItemColor: Colors.grey.shade400,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'DASHBOARD'),
                BottomNavigationBarItem(icon: Icon(Icons.business_rounded), label: 'OPD'),
              ],
            ),
          )
        : null, 

      appBar: AppBar(
        backgroundColor: const Color(0xFF00224D),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EXECUTIVE DASHBOARD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
            Text('Pemerintah Kota Payakumbuh', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, 
          labelColor: Colors.white, 
          unselectedLabelColor: Colors.white54, 
          indicatorColor: const Color(0xFF38BDF8), 
          indicatorWeight: 4,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.insights_rounded), text: 'Ringkasan'),
            Tab(icon: Icon(Icons.analytics_rounded), text: 'Realisasi APBD'),
            Tab(icon: Icon(Icons.storefront_rounded), text: 'Ekonomi & UMKM'),
            Tab(icon: Icon(Icons.support_agent_rounded), text: 'Layanan Publik'),
            Tab(icon: Icon(Icons.health_and_safety_rounded), text: 'Kesehatan & Penduduk'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRingkasanTab(), 
          _buildApbdTab(), 
          _buildEkonomiTab(), 
          _buildLayananTab(), 
          _buildKesehatanTab()
        ],
      ),
    );
  }

  Widget _buildApbdTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _apbdStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Data Realisasi APBD belum diinput oleh Admin.', style: TextStyle(color: Colors.grey))
          );
        }

        final docs = snapshot.data!.docs;

        if (_bottomNavIndex == 0) {
          return _buildApbdDashboardView(docs); 
        } else {
          return _buildApbdOpdListView(docs); 
        }
      }
    );
  }

  // ===========================================================================
  // 1. TAMPILAN DASHBOARD APBD
  // ===========================================================================
  Widget _buildApbdDashboardView(List<QueryDocumentSnapshot> docs) {
    
    List<QueryDocumentSnapshot> filteredDashDocs = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final tahun = data['tahun'] ?? 'Tahun 2024';
      final triwulan = data['triwulan'] ?? 'Triwulan II';
      final kategori = data['kategori'] ?? '';

      bool matchTahun = (tahun == _dashTahun);
      bool matchTriwulan = (triwulan == _dashTriwulan);
      bool matchKategori = (_dashKategori == 'Semua OPD' || kategori == _dashKategori);

      return matchTahun && matchTriwulan && matchKategori;
    }).toList();

    double totalPagu = 0; 
    double totalKeuPct = 0; 
    double totalFisikPct = 0;
    
    for (var doc in filteredDashDocs) {
      final data = doc.data() as Map<String, dynamic>;
      totalPagu += double.tryParse(data['pagu']?.toString() ?? '0') ?? 0;
      totalKeuPct += double.tryParse(data['keuangan_pct']?.toString() ?? '0') ?? 0;
      totalFisikPct += double.tryParse(data['fisik_pct']?.toString() ?? '0') ?? 0;
    }

    double avgKeuPct = filteredDashDocs.isNotEmpty ? (totalKeuPct / filteredDashDocs.length) : 0;
    double avgFisikPct = filteredDashDocs.isNotEmpty ? (totalFisikPct / filteredDashDocs.length) : 0;

    var statusKeu = getStatus(avgKeuPct);
    var statusFisik = getStatus(avgFisikPct);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      shape: BoxShape.circle, 
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
                      ]
                    ),
                    child: const CircleAvatar(
                      radius: 24, 
                      backgroundColor: Color(0xFFFDE68A), 
                      child: Icon(Icons.person, color: Color(0xFFD97706))
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selamat Pagi, Pak Gub', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600)),
                      const Text('Realisasi APBD', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    ],
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(12), 
                  border: Border.all(color: Colors.grey.shade200)
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF0F172A)), 
                  onPressed: (){}
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: _buildDashboardSummaryCard(
                  'Total Pagu', 
                  'Rp ${formatRupiahSingkat(totalPagu)}', 
                  'Tahun Anggaran ${_dashTahun.replaceAll("Tahun ", "")}', 
                  Icons.account_balance_wallet_outlined, 
                  const Color(0xFF1D4ED8)
                )
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildDashboardProgressCard(
                  'Realisasi Keuangan', 
                  avgKeuPct, 
                  statusKeu, 
                  const Color(0xFFEF4444), 
                  Icons.trending_down_rounded
                )
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildDashboardProgressCard(
                  'Realisasi Fisik', 
                  avgFisikPct, 
                  statusFisik, 
                  const Color(0xFFF59E0B), 
                  Icons.assignment_turned_in_outlined
                )
              ),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              _buildNativeDropdownChip(
                label: _dashTahun, 
                items: const ['Tahun 2023', 'Tahun 2024', 'Tahun 2025', 'Tahun 2026'], 
                isActive: true,
                onSelected: (val) => setState(() => _dashTahun = val)
              ),
              const SizedBox(width: 16),
              _buildNativeDropdownChip(
                label: _dashTriwulan, 
                items: const ['Triwulan I', 'Triwulan II', 'Triwulan III', 'Triwulan IV'], 
                onSelected: (val) => setState(() => _dashTriwulan = val)
              ),
              const SizedBox(width: 16),
              _buildNativeDropdownChip(
                label: _dashKategori, 
                items: const ['Semua OPD', 'Dinas', 'Badan', 'Kecamatan', 'Sekretariat'], 
                isFilterIcon: true,
                onSelected: (val) => setState(() => _dashKategori = val)
              ),
            ],
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(16), 
              border: Border.all(color: Colors.grey.shade200)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Top 5 Perbandingan OPD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 4),
                        Text('Keuangan vs Fisik (Persentase)', style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Row(
                      children: [
                        _buildLegendItem('KEU', const Color(0xFF1D4ED8)),
                        const SizedBox(width: 16),
                        _buildLegendItem('FISIK', const Color(0xFF10B981)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 32),
                
                if (filteredDashDocs.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20), 
                      child: Text('Tidak ada $_dashKategori pada periode $_dashTriwulan $_dashTahun.', style: TextStyle(color: Colors.grey.shade500))
                    )
                  ),

                ...filteredDashDocs.take(5).map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  double kPct = double.tryParse(data['keuangan_pct']?.toString() ?? '0') ?? 0;
                  double fPct = double.tryParse(data['fisik_pct']?.toString() ?? '0') ?? 0;
                  return _buildOpdCompareBar(data['nama_opd'] ?? '-', kPct, fPct);
                }),
              ],
            )
          ),
          const SizedBox(height: 40),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daftar Kinerja OPD', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              TextButton(
                onPressed: () => setState(() => _bottomNavIndex = 1), 
                child: const Text('Lihat Semua', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8), fontSize: 14))
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...filteredDashDocs.take(3).map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            double kPct = double.tryParse(data['keuangan_pct']?.toString() ?? '0') ?? 0;
            double fPct = double.tryParse(data['fisik_pct']?.toString() ?? '0') ?? 0;
            return _buildDashboardOpdListCard(data['nama_opd'] ?? '-', kPct, fPct);
          }),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildNativeDropdownChip({required String label, required List<String> items, required Function(String) onSelected, bool isActive = false, bool isFilterIcon = false}) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1014B3) : Colors.white, 
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: isActive ? const Color(0xFF1014B3) : Colors.grey.shade300)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: label,
          isDense: true,
          icon: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              isFilterIcon ? Icons.filter_alt_outlined : Icons.keyboard_arrow_down_rounded, 
              size: 18, 
              color: isActive ? Colors.white : Colors.grey.shade600
            ),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 4,
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((String item) {
              return Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  item, 
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF0F172A), 
                    fontWeight: FontWeight.bold, 
                    fontSize: 13
                  )
                ),
              );
            }).toList();
          },
          items: items.map((String choice) {
            return DropdownMenuItem<String>(
              value: choice, 
              child: Text(choice, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600, fontSize: 13))
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onSelected(val);
          },
        ),
      ),
    );
  }

  Widget _buildDashboardSummaryCard(String title, String value, String subtitle, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.grey.shade200), 
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10)
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(6), 
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), 
                child: Icon(icon, color: iconColor, size: 20)
              )
            ],
          ),
          const SizedBox(height: 20),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDashboardProgressCard(String title, double persen, Map<String, dynamic> status, Color barColor, IconData topIcon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.grey.shade200), 
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10)
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
              Icon(topIcon, color: barColor, size: 24),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('${persen.toStringAsFixed(1)}%', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: barColor)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 
                decoration: BoxDecoration(color: status['bgColor'], borderRadius: BorderRadius.circular(20)), 
                child: Text(status['label'], style: TextStyle(color: status['color'], fontSize: 10, fontWeight: FontWeight.w900))
              )
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6), 
            child: LinearProgressIndicator(
              value: persen / 100, 
              minHeight: 8, 
              backgroundColor: Colors.grey.shade200, 
              valueColor: AlwaysStoppedAnimation<Color>(barColor)
            )
          )
        ],
      ),
    );
  }

  Widget _buildDashboardOpdListCard(String namaOpd, double keuPct, double fisikPct) {
    bool isNormal = keuPct >= 75;
    String statusLabel = isNormal ? 'NORMAL' : 'TELAT';
    Color statusColor = isNormal ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    Color statusBgColor = isNormal ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);
    Color barKeuColor = keuPct >= 75 ? const Color(0xFF1D4ED8) : const Color(0xFFEF4444);
    Color barFisikColor = fisikPct >= 75 ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6, 
            height: 65, 
            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(6))
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(namaOpd, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 
                      decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(6)), 
                      child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900))
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('KEUANGAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4), 
                                  child: LinearProgressIndicator(
                                    value: keuPct / 100, 
                                    minHeight: 6, 
                                    backgroundColor: Colors.grey.shade200, 
                                    valueColor: AlwaysStoppedAnimation<Color>(barKeuColor)
                                  )
                                )
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 35, 
                                child: Text('${keuPct.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)), textAlign: TextAlign.right)
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FISIK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4), 
                                  child: LinearProgressIndicator(
                                    value: fisikPct / 100, 
                                    minHeight: 6, 
                                    backgroundColor: Colors.grey.shade200, 
                                    valueColor: AlwaysStoppedAnimation<Color>(barFisikColor)
                                  )
                                )
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 35, 
                                child: Text('${fisikPct.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)), textAlign: TextAlign.right)
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. TAMPILAN DAFTAR OPD TERBARU
  // ===========================================================================
  Widget _buildApbdOpdListView(List<QueryDocumentSnapshot> docs) {
    final filteredDocs = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final namaOpd = (data['nama_opd'] ?? '').toString().toLowerCase();
      final kategori = data['kategori'] ?? '';
      final tahun = data['tahun'] ?? 'Tahun 2024';
      final triwulan = data['triwulan'] ?? 'Triwulan II';
      double kPct = double.tryParse(data['keuangan_pct']?.toString() ?? '0') ?? 0;
      final statusOpd = getStatus(kPct)['label']; 

      final matchSearch = namaOpd.contains(_searchQuery.toLowerCase());
      final matchKategori = _selectedCategory == 'Semua' || kategori == _selectedCategory;
      final matchStatus = _selectedStatus == 'Semua' || statusOpd == _selectedStatus;
      
      final matchTahun = tahun == _dashTahun;
      final matchTriwulan = triwulan == _dashTriwulan;

      return matchSearch && matchKategori && matchStatus && matchTahun && matchTriwulan;
    }).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
          color: const Color(0xFFF4F7FC),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A), size: 28), 
                onPressed: () => setState(() => _bottomNavIndex = 0)
              ),
              const SizedBox(width: 8),
              Text(
                'Daftar OPD ($_dashTahun - $_dashTriwulan)', 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF0F172A), size: 28), 
                onPressed: () {}
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Cari Organisasi Perangkat Daerah...',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                    filled: true, 
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), 
                      borderSide: BorderSide(color: Colors.grey.shade300)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), 
                      borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 1.5)
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildCategoryChip('Semua'), 
                      _buildCategoryChip('Dinas'), 
                      _buildCategoryChip('Badan'), 
                      _buildCategoryChip('Kecamatan'), 
                      _buildCategoryChip('Sekretariat'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildStatusFilterChip('AMAN', const Color(0xFF10B981), const Color(0xFFD1FAE5)),
                      _buildStatusFilterChip('PERINGATAN', const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
                      _buildStatusFilterChip('KRITIS', const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (filteredDocs.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('Tidak ada OPD yang sesuai dengan filter.', style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  ),

                ...filteredDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  double kPct = double.tryParse(data['keuangan_pct']?.toString() ?? '0') ?? 0;
                  double fPct = double.tryParse(data['fisik_pct']?.toString() ?? '0') ?? 0;
                  return _buildNewFigmaOpdCard(data['nama_opd'] ?? '-', data['kategori'] ?? '-', kPct, fPct);
                }),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewFigmaOpdCard(String namaOpd, String kategori, double keuPct, double fisikPct) {
    var statKeu = getStatus(keuPct);
    var statFisik = getStatus(fisikPct);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.grey.shade200), 
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(namaOpd, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Text(
                      'KATEGORI: ${kategori.toUpperCase()}', 
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 0.5)
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 28),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Realisasi Keuangan', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${keuPct.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                decoration: BoxDecoration(color: statKeu['bgColor'], borderRadius: BorderRadius.circular(6)), 
                child: Text(statKeu['label'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statKeu['color']))
              )
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6), 
            child: LinearProgressIndicator(
              value: keuPct / 100, 
              minHeight: 8, 
              backgroundColor: Colors.grey.shade100, 
              valueColor: AlwaysStoppedAnimation<Color>(statKeu['color'])
            )
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Realisasi Fisik', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${fisikPct.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                decoration: BoxDecoration(color: statFisik['bgColor'], borderRadius: BorderRadius.circular(6)), 
                child: Text(statFisik['label'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statFisik['color']))
              )
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6), 
            child: LinearProgressIndicator(
              value: fisikPct / 100, 
              minHeight: 8, 
              backgroundColor: Colors.grey.shade100, 
              valueColor: AlwaysStoppedAnimation<Color>(statFisik['color'])
            )
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    bool isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = label),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1D4ED8) : Colors.white, 
            borderRadius: BorderRadius.circular(20), 
            border: Border.all(color: isSelected ? const Color(0xFF1D4ED8) : Colors.grey.shade300)
          ),
          child: Text(
            label, 
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87, 
              fontWeight: FontWeight.bold, 
              fontSize: 13
            )
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilterChip(String label, Color color, Color bgColor) {
    bool isSelected = _selectedStatus == label;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () => setState(() => _selectedStatus = isSelected ? 'Semua' : label), 
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor, 
            borderRadius: BorderRadius.circular(8), 
            border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5)
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 4, backgroundColor: color),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // KOMPONEN WIDGET UMUM
  // ===========================================================================

  Widget _buildOpdCompareBar(String title, double keuPct, double fisikPct) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4), 
                  child: LinearProgressIndicator(
                    value: keuPct / 100, 
                    minHeight: 12, 
                    backgroundColor: Colors.grey.shade200, 
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1D4ED8))
                  )
                )
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 35, 
                child: Text('${keuPct.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8), fontSize: 12), textAlign: TextAlign.right)
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4), 
                  child: LinearProgressIndicator(
                    value: fisikPct / 100, 
                    minHeight: 12, 
                    backgroundColor: Colors.grey.shade200, 
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981))
                  )
                )
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 35, 
                child: Text('${fisikPct.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981), fontSize: 12), textAlign: TextAlign.right)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12, 
          height: 12, 
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
      ],
    );
  }

  // ===========================================================================
  // TAB LAINNYA (Ringkasan, Ekonomi, Layanan, Kesehatan)
  // ===========================================================================
  Widget _buildRingkasanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPimpinanBanner(),
          const SizedBox(height: 32),
          const Text('Kinerja Makro Daerah', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16, 
            runSpacing: 16,
            children: [
              _buildMetricCard('Serapan APBD', '68.4%', 'Target Q3: 70%', Icons.account_balance_wallet, Colors.blue),
              _buildMetricCard('Inflasi Daerah (YoY)', '2.14%', 'Terkendali', Icons.trending_down, Colors.green),
              _buildMetricCard('Indeks Kepuasan', '88.5', 'Skor Sangat Baik', Icons.sentiment_very_satisfied, Colors.orange),
              _buildMetricCard('Aduan Warga (Mg ini)', '142', '120 Selesai', Icons.mark_chat_read, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEkonomiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Potensi Ekonomi & Sentra Industri', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildSectionCard(
                  title: 'Realisasi Pendapatan Asli Daerah (PAD)', 
                  child: Column(
                    children: [
                      _buildProgressBar('Pajak Restoran & Kuliner', 0.85, 'Rp 12.4 M', Colors.orange), 
                      _buildProgressBar('Pajak Hotel & Penginapan', 0.65, 'Rp 4.2 M', Colors.blue), 
                      _buildProgressBar('Retribusi Pasar Ibuh', 0.90, 'Rp 8.1 M', Colors.green)
                    ]
                  )
                )
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSectionCard(
                  title: 'Pemantauan Harga Bapok (Pasar Ibuh)', 
                  child: Column(
                    children: [
                      _buildTrendRow('Beras Solok (Premium)', 'Rp 16.500/kg', true), 
                      _buildTrendRow('Cabai Merah Keriting', 'Rp 45.000/kg', false), 
                      _buildTrendRow('Daging Sapi Lokal', 'Rp 140.000/kg', true)
                    ]
                  )
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLayananTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Command Center & Respon Warga', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildSectionCard(
                  title: 'Topik Aduan Terbanyak', 
                  child: Column(
                    children: [
                      _buildBarChart('Infrastruktur (Jalan Berlubang)', 0.9, '124 Laporan', Colors.redAccent), 
                      _buildBarChart('Lingkungan (Sampah)', 0.6, '82 Laporan', Colors.orange), 
                      _buildBarChart('Fasum (Lampu PJU Mati)', 0.4, '45 Laporan', Colors.amber)
                    ]
                  )
                )
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSectionCard(
                  title: 'SLA Respon Dinas Terkait', 
                  child: Column(
                    children: [
                      _buildProgressBar('Dinas PUPR', 0.75, 'Rata-rata 2 Hari', Colors.blue), 
                      _buildProgressBar('Dinas Lingkungan Hidup', 0.92, 'Rata-rata 12 Jam', Colors.green), 
                      _buildProgressBar('Disdukcapil (Adminduk)', 0.98, 'Rata-rata 2 Jam', Colors.teal)
                    ]
                  )
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKesehatanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kesehatan & Pemetaan Demografi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Fokus Penurunan Angka Stunting (Data per Kecamatan)', 
            child: Column(
              children: [
                _buildBarChart('Payakumbuh Barat', 0.4, '8.2%', Colors.teal), 
                _buildBarChart('Payakumbuh Timur', 0.35, '7.5%', Colors.teal), 
                _buildBarChart('Payakumbuh Utara', 0.5, '9.1%', Colors.orange), 
                _buildBarChart('Payakumbuh Selatan', 0.2, '5.4%', Colors.teal), 
                _buildBarChart('Latina (Lampasi Tigo Nagari)', 0.25, '6.1%', Colors.teal)
              ]
            )
          ),
        ],
      ),
    );
  }

  Widget _buildPimpinanBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, 
          end: Alignment.bottomRight, 
          colors: [Color(0xFF00224D), Color(0xFF003F87)]
        ), 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00224D).withValues(alpha: 0.3), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15), 
                    borderRadius: BorderRadius.circular(8)
                  ), 
                  child: const Text('VISI KOTA PAYAKUMBUH', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5))
                ),
                const SizedBox(height: 16),
                const Text(
                  '"Mewujudkan Payakumbuh yang Maju,\nSejahtera, dan Bermartabat"', 
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, height: 1.4)
                ),
                const SizedBox(height: 12),
                const Text(
                  'Fokus pada transformasi digital, pelayanan publik responsif, dan penguatan ekonomi lokal UMKM.', 
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Row(
            children: [
              _buildProfileCircle(
                name: 'Dr. dr. Zulmaeta, Sp.OG-KFM', 
                title: 'Pj. Walikota Payakumbuh', 
                imagePath: 'assets/images/Wali_Kota_Payakumbuh_Zulmaeta.jpg'
              ),
              const SizedBox(width: 24),
              _buildProfileCircle(
                name: 'Elzadaswarman, SKM., MPPM', 
                title: 'Pj. Wakil Walikota', 
                imagePath: 'assets/images/Wakil_Wali_Kota_Payakumbuh_Elzadaswarman.jpg'
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProfileCircle({required String name, required String title, required String imagePath}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4), 
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2), 
            shape: BoxShape.circle
          ), 
          child: CircleAvatar(
            radius: 40, 
            backgroundImage: AssetImage(imagePath), 
            backgroundColor: Colors.white
          )
        ),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, MaterialColor color) {
    return Container(
      width: 250, 
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              Container(
                padding: const EdgeInsets.all(10), 
                decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(12)), 
                child: Icon(icon, color: color.shade500)
              ), 
              Icon(Icons.more_horiz, color: Colors.grey.shade400)
            ]
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)), 
            child: Text(subtitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500))
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))), 
          const Divider(height: 32, color: Color(0xFFF1F5F9)), 
          child
        ],
      ),
    );
  }

  Widget _buildBarChart(String label, double percent, String trailingText, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))), 
              Text(trailingText, style: TextStyle(fontWeight: FontWeight.bold, color: color))
            ]
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 12, 
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6))
              ), 
              FractionallySizedBox(
                widthFactor: percent, 
                child: Container(
                  height: 12, 
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6))
                )
              )
            ]
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress, String trailing, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569))), 
              Text(trailing, style: TextStyle(fontWeight: FontWeight.bold, color: color.shade600))
            ]
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8), 
            child: LinearProgressIndicator(
              value: progress, 
              backgroundColor: color.shade50, 
              valueColor: AlwaysStoppedAnimation<Color>(color.shade500), 
              minHeight: 8
            )
          ),
        ],
      ),
    );
  }

  Widget _buildTrendRow(String label, String price, bool isUp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, 
                color: isUp ? Colors.red : Colors.green, 
                size: 18
              ), 
              const SizedBox(width: 8), 
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569)))
            ]
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}