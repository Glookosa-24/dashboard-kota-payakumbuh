import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// --- IMPORT HALAMAN BARU ---
import 'rekomendasi_sekolah_page.dart'; 
import 'statistik_sma_page.dart';
import 'statistik_sd_page.dart';
import 'statistik_smk_page.dart';
import 'eksplorasi_wisata_page.dart';
import 'statistik_wisata_page.dart'; 
import 'peta_layanan_publik_page.dart';
import 'statistik_aduan_page.dart';
import 'statistik_kepegawaian_page.dart';
import 'transparansi_apbd_page.dart';

// Model Data untuk Informasi Detail Sektor
class SectorInfo {
  final String title;
  final String opd;
  final String description;
  final String address;
  final String phone;
  final String email;
  final List<Map<String, String>> kpis;
  final List<Map<String, dynamic>> programs;
  final List<Map<String, String>> facilities;

  const SectorInfo({
    required this.title,
    required this.opd,
    required this.description,
    required this.address,
    required this.phone,
    required this.email,
    required this.kpis,
    required this.programs,
    required this.facilities,
  });
}

class SectorDetailPage extends StatefulWidget {
  final String sectorId; 

  const SectorDetailPage({super.key, required this.sectorId});

  @override
  State<SectorDetailPage> createState() => _SectorDetailPageState();
}

class _SectorDetailPageState extends State<SectorDetailPage> {
  late String _activeSector;

  // Daftar icon untuk filter sektor horizontal (Gunakan nama Standar)
  final List<Map<String, dynamic>> _sectors = [
    {'id': 'Pemerintahan', 'icon': Icons.account_balance},
    {'id': 'Pariwisata', 'icon': Icons.tour},
    {'id': 'Pendidikan', 'icon': Icons.school},
    {'id': 'Kesehatan', 'icon': Icons.favorite},
    {'id': 'Infrastruktur', 'icon': Icons.construction},
    {'id': 'Penduduk', 'icon': Icons.groups},
    {'id': 'Industri & UMKM', 'icon': Icons.storefront},
    {'id': 'Keuangan', 'icon': Icons.monetization_on},
  ];

  @override
  void initState() {
    super.initState();
    // 1. PEMETAAN ALIAS (Mencegah Error dari Drawer)
    String mappedId = widget.sectorId;
    if (mappedId == 'Kependudukan') mappedId = 'Penduduk';
    if (mappedId == 'Industri') mappedId = 'Industri & UMKM';
    if (mappedId == 'Ekonomi dan Keuangan') mappedId = 'Keuangan';

    // 2. Cek apakah ada di daftar
    bool exists = _sectors.any((s) => s['id'] == mappedId);
    _activeSector = exists ? mappedId : 'Pemerintahan';
  }

  // ===========================================================================
  // DATA MASTER KPI & PROGRAM (Fasilitas dikosongkan untuk yang Live Firebase)
  // ===========================================================================
  SectorInfo _getSectorData(String id) {
    switch (id) {
      case 'Pemerintahan':
        return const SectorInfo(
          title: 'Pemerintahan & Tata Kelola Publik',
          opd: 'Sekretariat Daerah & Diskominfo',
          description: 'Mewujudkan tata kelola birokrasi yang lincah, berintegritas, dan berbasis digital melayani masyarakat Kota Payakumbuh.',
          address: 'Balai Kota Payakumbuh, Jl. Veteran No. 1', phone: '(0752) 92001', email: 'pemkot@payakumbuhkota.go.id',
          kpis: [{'label': 'Indeks SPBE (E-Gov)', 'value': '3.68', 'sub': 'Sangat Baik'}, {'label': 'Reformasi Birokrasi', 'value': '82.4', 'sub': 'Predikat A'}, {'label': 'Total ASN & PPPK', 'value': '3.420', 'sub': '5 Kecamatan'}, {'label': 'Penyelesaian Aduan', 'value': '98.4%', 'sub': 'Kanal LAPOR!'}],
          programs: [{'title': 'Payakumbuh Satu Data', 'desc': 'Integrasi basis data sektoral antar 34 OPD.', 'progress': 0.94}, {'title': 'Mall Pelayanan Publik (MPP)', 'desc': 'Layanan terpadu perizinan publik.', 'progress': 0.96}],
          facilities: [{'name': 'Mall Pelayanan Publik (MPP)', 'loc': 'Balai Kota Lt. 1', 'tag': '148 Layanan'}, {'name': 'Diskominfo Command Center', 'loc': 'Kantor Walikota', 'tag': 'CCTV 24/7'}],
        );
      
      case 'Penduduk': // LIVE FIREBASE
        return const SectorInfo(
          title: 'Demografi & Kependudukan',
          opd: 'Dinas Kependudukan dan Catatan Sipil (Disdukcapil)',
          description: 'Pelayanan administrasi kependudukan terpadu dan pemetaan demografi warga Kota Payakumbuh yang cepat dan akurat.',
          address: 'Jl. Sudirman No. 12, Payakumbuh', phone: '(0752) 92112', email: 'disdukcapil@payakumbuhkota.go.id',
          kpis: [{'label': 'Total Penduduk', 'value': '141k', 'sub': 'Jiwa'}, {'label': 'Cakupan E-KTP', 'value': '98.5%', 'sub': 'Terekam'}, {'label': 'Pertumbuhan', 'value': '1.2%', 'sub': 'Per Tahun'}, {'label': 'KIA Diterbitkan', 'value': '45.000', 'sub': 'Anak'}],
          programs: [{'title': 'Jemput Bola Adminduk', 'desc': 'Layanan keliling perekaman KTP ke sekolah & kelurahan.', 'progress': 0.88}],
          facilities: [], 
        );

      case 'Industri & UMKM': // LIVE FIREBASE
        return const SectorInfo(
          title: 'Industri Pengolahan & UMKM',
          opd: 'Dinas Tenaga Kerja dan Perindustrian (Disnakerin)',
          description: 'Membangun ekosistem "The City of Rendang" berstandar ekspor ISO 22000 dan sertifikasi Halal.',
          address: 'Sentra Rendang, Padang Kaduduak', phone: '(0752) 93108', email: 'disnakerin@payakumbuhkota.go.id',
          kpis: [{'label': 'Total UMKM Terdaftar', 'value': '2.850 Unit', 'sub': 'Kuliner & Kriya'}, {'label': 'Omzet UMKM Tahunan', 'value': 'Rp 412 M', 'sub': 'Lokal & Ekspor'}],
          programs: [{'title': 'Rendang Go International', 'desc': 'Ekspor rendang kemasan retort tahan 1 tahun.', 'progress': 0.88}],
          facilities: [], 
        );

      case 'Keuangan': // DATA STATIS
        return const SectorInfo(
          title: 'Ekonomi & Keuangan Daerah',
          opd: 'Badan Keuangan Daerah (BKD)',
          description: 'Transparansi pengelolaan APBD dan peningkatan Pendapatan Asli Daerah (PAD) untuk kemajuan pembangunan Kota.',
          address: 'Kawasan Balai Kota Baru, Eks Poliko', phone: '(0752) 99312', email: 'bkd@payakumbuhkota.go.id',
          kpis: [{'label': 'Total APBD', 'value': 'Rp 824 M', 'sub': 'Tahun Berjalan'}, {'label': 'Opini BPK RI', 'value': 'WTP 10x', 'sub': 'Berturut-turut'}, {'label': 'Realisasi PAD', 'value': '92.4%', 'sub': 'Sangat Baik'}],
          programs: [{'title': 'Digitalisasi Pembayaran Pajak', 'desc': 'Integrasi QRIS dan Virtual Account untuk semua retribusi daerah.', 'progress': 0.95}],
          facilities: [{'name': 'Kantor BKD Payakumbuh', 'loc': 'Eks Lapangan Poliko', 'tag': 'Pusat Keuangan'}, {'name': 'Samsat Payakumbuh', 'loc': 'Jl. Pahlawan', 'tag': 'Pajak Kendaraan'}],
        );

      case 'Kesehatan': // LIVE FIREBASE
        return const SectorInfo(
          title: 'Kesehatan & Layanan Medis',
          opd: 'Dinas Kesehatan & RSUD Dr. Adnaan WD',
          description: 'Menjamin akses kesehatan gratis berkualitas melalui cakupan Universal Health Coverage (UHC) 98.8%.',
          address: 'Jl. Sukarno Hatta No. 25', phone: '(0752) 92055', email: 'dinkes@payakumbuhkota.go.id',
          kpis: [{'label': 'Cakupan UHC BPJS', 'value': '98.8%', 'sub': 'Universal Akses'}, {'label': 'Prevalensi Stunting', 'value': '8.4%', 'sub': 'Terendah'}],
          programs: [{'title': 'Gerakan Bebas Stunting', 'desc': 'Pemberian nutrisi protein hewani balita.', 'progress': 0.91}],
          facilities: [], 
        );

      case 'Pendidikan': // LIVE FIREBASE
        return const SectorInfo(
          title: 'Sektor Pendidikan',
          opd: 'Dinas Pendidikan Kota Payakumbuh',
          description: 'Mencetak generasi Payakumbuh yang berakhlak mulia, cerdas, dan unggul dalam prestasi akademik.',
          address: 'Jl. Pahlawan No. 12', phone: '(0752) 92330', email: 'disdik@payakumbuhkota.go.id',
          kpis: [{'label': 'Partisipasi Murni (APM)', 'value': '99.2%', 'sub': 'SD & SMP'}, {'label': 'Guru Tersertifikasi', 'value': '2.480 Org', 'sub': 'Tersertifikasi'}],
          programs: [{'title': 'Payakumbuh Cerdas Digital School', 'desc': 'Smart classroom dan pelatihan AI edukasi.', 'progress': 0.92}],
          facilities: [], 
        );
      
      case 'Pariwisata': // LIVE FIREBASE
        return const SectorInfo(
          title: 'Sektor Pariwisata',
          opd: 'Dinas Pariwisata, Pemuda dan Olahraga',
          description: 'Mengembangkan pesona alam Ngalau Indah, rekreasi Batang Agam, dan tradisi unik Pacu Itiak.',
          address: 'Jl. Ade Irma Suryani No. 8', phone: '(0752) 93412', email: 'disparpora@payakumbuhkota.go.id',
          kpis: [{'label': 'Kunjungan Wisata', 'value': '284k', 'sub': 'Per Tahun'}, {'label': 'Perputaran Uang', 'value': 'Rp 48 M', 'sub': 'Sektor Wisata'}],
          programs: [{'title': 'Revitalisasi Geopark Ngalau', 'desc': 'Pemasangan tata lampu dan jalur aman pengunjung.', 'progress': 0.90}],
          facilities: [], 
        );

      default:
        return SectorInfo(
          title: 'Sektor $_activeSector',
          opd: 'Pemerintah Kota Payakumbuh',
          description: 'Pusat data statistik, layanan publik, dan program strategis sektor $_activeSector di Kota Payakumbuh.',
          address: 'Balai Kota Payakumbuh, Sumatera Barat', phone: '112', email: 'kontak@payakumbuhkota.go.id',
          kpis: const [{'label': 'Total Layanan', 'value': 'Aktif', 'sub': '2024'}], programs: const [], facilities: const [{'name': 'Kantor Layanan Terpadu', 'loc': 'Balai Kota', 'tag': 'Senin - Jumat'}],
        );
    }
  }

  // Fungsi untuk memunculkan pop-up info dan tombol Google Maps
  void _tampilkanDetailLokasi(BuildContext context, String judul, String subJudul, String infoTag) {
    final String queryPeta = Uri.encodeComponent("$judul Payakumbuh");
    final Uri urlPeta = Uri.parse('https://www.google.com/maps/search/?api=1&query=$queryPeta');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                    child: const Icon(Icons.location_city_rounded, color: Color(0xFF003F87), size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(judul, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
                        const SizedBox(height: 4),
                        Text(subJudul, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Data Tercatat:', style: TextStyle(color: Colors.grey.shade700)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8)),
                    child: Text(infoTag, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF059669))),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.map_rounded),
                  label: const Text('Buka Lokasi di Google Maps', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003F87),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (await canLaunchUrl(urlPeta)) {
                      await launchUrl(urlPeta, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _getSectorData(_activeSector);

    return Scaffold(
      backgroundColor: const Color(0xFF003F87),
      body: SafeArea(
        child: Column(
          children: [
            // 1. BAGIAN BREADCRUMB & TOMBOL KEMBALI
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        const Text('Dashboard Utama  >  ', style: TextStyle(color: Colors.grey)),
                        Text(_activeSector, style: const TextStyle(color: Color(0xFF003F87), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                      label: const Text('Kembali ke Dashboard', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003F87), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
                    )
                  ],
                ),
              ),
            ),

            // 2. BAGIAN FILTER MENU HORIZONTAL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt_outlined, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('SEKTOR:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _sectors.map((s) {
                          bool isActive = s['id'] == _activeSector;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: InkWell(
                              onTap: () => setState(() => _activeSector = s['id']),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(color: isActive ? Colors.white : Colors.transparent, border: Border.all(color: isActive ? Colors.white : Colors.white54), borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  children: [
                                    Icon(s['icon'], size: 16, color: isActive ? const Color(0xFF003F87) : Colors.white),
                                    const SizedBox(width: 8),
                                    Text(s['id'], style: TextStyle(color: isActive ? const Color(0xFF003F87) : Colors.white, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. BAGIAN KARTU KONTEN UTAMA (PUTIH)
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FF),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Deskripsi
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFE5EEFF), borderRadius: BorderRadius.circular(8)),
                          child: const Text('MODUL SEKTOR RESMI KOTA PAYAKUMBUH', style: TextStyle(color: Color(0xFF003F87), fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                        const SizedBox(height: 16),
                        Text(data.title, style: const TextStyle(color: Color(0xFF0B1C30), fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(data.opd, style: const TextStyle(color: Color(0xFF565F69), fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Text(data.description, style: const TextStyle(color: Color(0xFF565F69), fontSize: 14, height: 1.6)),
                        const SizedBox(height: 32),

                        // KARTU METRIK KPI
                        if (data.kpis.isNotEmpty) ...[
                          const Text('Indikator & Metrik Kinerja Utama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 700;
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isWide ? 4 : 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: isWide ? 1.5 : 1.3,
                                ),
                                itemCount: data.kpis.length,
                                itemBuilder: (context, index) {
                                  final kpi = data.kpis[index];
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withValues(alpha: 0.06)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))]),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(kpi['label']!, style: const TextStyle(fontSize: 12, color: Color(0xFF565F69), fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 8),
                                        Text(kpi['value']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF003F87))),
                                        const SizedBox(height: 4),
                                        Text(kpi['sub']!, style: const TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                        ],

                        // PROGRAM STRATEGIS
                        if (data.programs.isNotEmpty) ...[
                          const Text('Program Strategis & Inisiatif Daerah', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
                          const SizedBox(height: 16),
                          Column(
                            children: data.programs.map((prog) {
                              final double progress = prog['progress'];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text(prog['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0B1C30)))),
                                        Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF003F87))),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(prog['desc'], style: const TextStyle(fontSize: 13, color: Color(0xFF565F69))),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(value: progress, backgroundColor: const Color(0xFFEFF4FF), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF003F87)), minHeight: 8),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 40),
                        ],

                        // =======================================================
                        // DAFTAR DATA LIVE / MENU GRID
                        // =======================================================
                        Text(
                          ['Pendidikan', 'Pariwisata', 'Pemerintahan'].contains(_activeSector) 
                            ? 'Menu Direktori & Layanan' 
                            : (['Industri & UMKM', 'Kesehatan', 'Penduduk'].contains(_activeSector) 
                                ? 'Daftar Direktori Aktif (Live Data)' 
                                : 'Daftar Fasilitas & Lokasi Pelayanan'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30)),
                        ),
                        const SizedBox(height: 16),

                        // --- MENU GRID: PEMERINTAHAN ---
                        if (_activeSector == 'Pemerintahan')
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                            children: [
                              _buildCardMenuGrid(
                                title: 'Peta Integrasi Layanan Publik', 
                                imageAsset: 'assets/images/logo.png', 
                                tag: 'Pemerintahan', 
                                count: '32 Lokasi Aktif',
                                iconData: Icons.account_balance, 
                                iconColor: const Color(0xFF334155), // Warna Slate/Navy Formal
                                tagColor: const Color(0xFF475569),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PetaLayananPublikPage())),
                              ),
                              _buildCardMenuGrid(
                                title: 'Pantauan Aduan Masyarakat (LAPOR)', 
                                imageAsset: 'assets/images/logo.png', 
                                tag: 'Pelayanan', 
                                count: 'Statistik Aduan',
                                iconData: Icons.support_agent_rounded, 
                                iconColor: const Color(0xFF334155),
                                tagColor: const Color(0xFF475569),
                                onTap: () {
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (context) => const StatistikAduanPage())
                                  );
                                },
                              ),
                              _buildCardMenuGrid(
                                title: 'Statistik Kepegawaian (ASN & PPPK)', 
                                imageAsset: 'assets/images/logo.png', 
                                tag: 'SDM Aparatur', 
                                count: 'Data Demografi',
                                iconData: Icons.badge_rounded, 
                                iconColor: const Color(0xFF334155),
                                tagColor: const Color(0xFF475569),
                                onTap: () {
                                  // --- NAVIGASI KE HALAMAN KEPEGAWAIAN YANG BARU ---
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (context) => const StatistikKepegawaianPage())
                                  );
                                },
                              ),
                              _buildCardMenuGrid(
                                title: 'Transparansi Anggaran (APBD)', 
                                imageAsset: 'assets/images/logo.png', 
                                tag: 'Keuangan', 
                                count: 'Ringkasan APBD',
                                iconData: Icons.pie_chart_rounded, 
                                iconColor: const Color(0xFF334155),
                                tagColor: const Color(0xFF475569),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const TransparansiApbdPage())
                                  );
                                },
                              ),
                            ],
                          )

                        // --- MENU GRID: PENDIDIKAN ---
                        else if (_activeSector == 'Pendidikan')
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                            children: [
                              _buildCardMenuGrid(
                                title: 'Rekomendasi Sekolah', 
                                imageAsset: 'assets/images/logo.png', 
                                tag: 'Pendidikan', 
                                count: '2.371.493',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RekomendasiSekolahPage())),
                              ),
                              _buildCardMenuGrid(
                                title: 'Jumlah Sekolah, Guru, Siswa (SMA)', 
                                imageAsset: 'assets/images/logo.png', 
                                tag: 'Pendidikan', 
                                count: '7.074',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatistikSmaPage())),
                              ),
                              _buildCardMenuGrid(
                                title: 'Jumlah Sekolah, Guru, Siswa (SD)', 
                                imageAsset: 'assets/images/logo.png', 
                                tag: 'Pendidikan', 
                                count: '3.813',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatistikSdPage())),
                              ),
                              _buildCardMenuGrid(
                                title: 'Jumlah Sekolah, Guru, Siswa (SMK)', 
                                imageAsset: 'assets/images/logo.png', 
                                tag: 'Pendidikan', 
                                count: '3.770',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatistikSmkPage())),
                              ),
                            ],
                          )
                        
                        // --- MENU GRID: PARIWISATA ---
                        else if (_activeSector == 'Pariwisata')
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                            children: [
                              _buildCardMenuGrid(
                                title: 'Eksplorasi Destinasi Wisata', 
                                imageAsset: 'assets/images/logo.png', 
                                tag: 'Pariwisata', 
                                count: '4 Destinasi',
                                iconData: Icons.tour, 
                                iconColor: const Color(0xFF003F87), 
                                tagColor: const Color(0xFF2563EB),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EksplorasiWisataPage())),
                              ),
                              _buildCardMenuGrid(
                                title: 'Statistik Kunjungan Wisatawan', 
                                imageAsset: 'assets/images/logo.png', 
                                tag: 'Pariwisata', 
                                count: 'Data Tren',
                                iconData: Icons.insights, 
                                iconColor: const Color(0xFF003F87), 
                                tagColor: const Color(0xFF2563EB),
                                onTap: () {
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (context) => const StatistikWisataPage())
                                  );
                                },
                              ),
                            ],
                          )

                        // --- LIST DATA LAINNYA ---
                        else if (_activeSector == 'Industri & UMKM') 
                          _buildFirebaseList('sektor_umkm', Icons.storefront, 'nama', 'bidang', 'omzet', prefix: 'Rp ')
                        else if (_activeSector == 'Kesehatan')
                          _buildFirebaseList('sektor_kesehatan', Icons.local_hospital, 'nama_faskes', 'jenis', 'layanan')
                        else if (_activeSector == 'Penduduk')
                          _buildFirebaseList('sektor_kependudukan', Icons.map, 'kecamatan', 'kepadatan', 'populasi', subSuffix: ' Jiwa/km²', suffix: ' Jiwa')
                        else
                          _buildStaticFacilitiesList(data.facilities),
                          
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // WIDGET KHUSUS: Mengambil data dari Firebase secara Live
  Widget _buildFirebaseList(String collectionName, IconData iconData, String titleKey, String subKey, String tagKey, {String prefix = '', String suffix = '', String subSuffix = ''}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Belum ada data di server.', style: TextStyle(color: Colors.grey))));
          
          final docs = snapshot.data!.docs;
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final doc = docs[index].data() as Map<String, dynamic>;
              final String title = doc[titleKey] ?? '-';
              final String subtitle = '${doc[subKey] ?? '-'}$subSuffix';
              final String tag = '$prefix${doc[tagKey] ?? '0'}$suffix';

              return _buildListItemCard(
                icon: iconData,
                title: title,
                subtitle: subtitle,
                tag: tag,
                onTap: () => _tampilkanDetailLokasi(context, title, subtitle, tag), 
              );
            },
          );
        },
      ),
    );
  }

  // WIDGET KHUSUS: Menampilkan data fasilitas bawaan (statis)
  Widget _buildStaticFacilitiesList(List<Map<String, String>> facilities) {
    if (facilities.isEmpty) return const SizedBox();
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: facilities.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
      itemBuilder: (context, index) {
          final item = facilities[index];
          return _buildListItemCard(
            icon: Icons.business_rounded,
            title: item['name']!,
            subtitle: item['loc']!,
            tag: item['tag']!,
            onTap: () => _tampilkanDetailLokasi(context, item['name']!, item['loc']!, item['tag']!),
          );
        },
      ),
    );
  }

  // WIDGET TEMPLATE: Desain Kartu List
  Widget _buildListItemCard({required IconData icon, required String title, required String subtitle, required String tag, VoidCallback? onTap}) { 
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFEFF4FF), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFF003F87), size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0B1C30))),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF565F69))),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8)),
        child: Text(tag, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
      ),
    );
  }

  // WIDGET KHUSUS: Desain Kartu Menu Fleksibel
  Widget _buildCardMenuGrid({
    required String title, 
    required String imageAsset, 
    required String tag, 
    required String count, 
    IconData iconData = Icons.school, 
    Color iconColor = const Color(0xFF0056B3), 
    Color tagColor = const Color(0xFF007BFF), 
    VoidCallback? onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)]),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(iconData, size: 40, color: iconColor),
            ),
            const SizedBox(height: 16),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0B1C30), height: 1.3), maxLines: 3, overflow: TextOverflow.ellipsis)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(6)),
              child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.visibility_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(count, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            )
          ],
        ),
      ),
    );
  }
}