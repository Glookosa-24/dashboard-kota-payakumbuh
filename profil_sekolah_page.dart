import 'package:flutter/material.dart';

class ProfilSekolahPage extends StatelessWidget {
  final Map<String, dynamic> dataSekolah;

  const ProfilSekolahPage({super.key, required this.dataSekolah});

  @override
  Widget build(BuildContext context) {
    // Mengekstrak data yang dikirim dari halaman sebelumnya
    final String nama = dataSekolah['nama_sekolah'] ?? 'Nama Sekolah Tidak Diketahui';
    final String status = dataSekolah['status'] ?? 'Negeri';
    final String akred = dataSekolah['akreditasi'] ?? 'A';
    final String alamat = dataSekolah['alamat'] ?? 'Kota Payakumbuh, Sumatera Barat';
    final String npsn = dataSekolah['npsn'] ?? '108XXXXX';
    final String jarak = '2,4 km'; // Dummy jarak

    return Scaffold(
      backgroundColor: Colors.white, 
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===================================================================
            // 1. HEADER & INFO PROFIL (STACK UNTUK EFEK OVERLAP LOGO)
            // ===================================================================
            Stack(
              clipBehavior: Clip.none,
              children: [
                // --- A. Latar Biru Atas ---
                Container(
                  width: double.infinity,
                  height: 280, // Tinggi area biru
                  color: const Color(0xFF007BFF), // Biru khas Tepas Jabar
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Breadcrumbs & Tombol Kembali
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Text('Beranda  >  Eksplorasi Dashboard  >  Dashboard Rekomendasi Sekolah  >  ', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                          const Text('Profil Sekolah', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Judul & Tombol Bagikan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Profil Sekolah', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text('Bagikan profil Sekolah'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                // --- B. Logo/Foto Sekolah & Konten Teks (Menumpuk di batas area biru) ---
                Container(
                  // 220 didapat dari: (Tinggi Biru 280) - (Setengah Tinggi Logo 60)
                  // Ini membuat logo terbelah persis di tengah garis biru
                  margin: const EdgeInsets.only(top: 220, left: 40, right: 40), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FOTO PROFIL SEKOLAH (Melayang/Overlap)
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5EEFF), 
                          shape: BoxShape.circle, 
                          border: Border.all(color: Colors.white, width: 6), // Border putih tebal
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        // ClipOval digunakan agar gambarnya terpotong bulat sempurna
                        child: ClipOval(
                          child: _buildProfileImage(nama),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFED7AA))),
                        child: Text(status, style: const TextStyle(fontSize: 12, color: Color(0xFFC2410C), fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      
                      // Nama Sekolah
                      Text(nama, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
                      const SizedBox(height: 12),
                      
                      // Alamat
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF0056B3)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(alamat, style: TextStyle(fontSize: 15, color: Colors.grey.shade700))),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 24),
                      
                      // Info Bawah (Cabdisdik, NPSN, dll)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _buildInfoColumn('Cadisdik', 'Wilayah IV'),
                              const SizedBox(width: 48),
                              _buildInfoColumn('NPSN', npsn),
                              const SizedBox(width: 48),
                              _buildInfoColumn('Jarak', jarak),
                              const SizedBox(width: 48),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Akreditasi', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle),
                                    child: Text(akred, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.compare_arrows_rounded, size: 18),
                            label: const Text('Bandingkan'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007BFF), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),

            // ===================================================================
            // 2. BAGIAN TABEL TAB VERTIKAL (FASILITAS, GURU, SISWA)
            // ===================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Column(
                children: [
                  // --- SEKTOR FASILITAS ---
                  _VerticalTabSection(
                    title: 'Fasilitas',
                    icon: Icons.meeting_room_outlined,
                    tabsData: {
                      'Laboratorium': _buildDataTable(
                        ['Laboratorium', 'Jumlah', 'Persentase Sarana Kondisi Baik'],
                        [['Komputer', '0', '0,00%'], ['IPA', '0', '0,00%'], ['Bahasa', '0', '0,00%']],
                      ),
                      'Ruang Kelas': _buildDataTable(
                        ['Ruang Kelas', 'Jumlah', 'Persentase Sarana Kondisi Baik'],
                        [['Kelas X', '8', '100%'], ['Kelas XI', '8', '100%'], ['Kelas XII', '8', '100%']],
                      ),
                      'Perpustakaan': const Center(child: Text('Data Perpustakaan belum tersedia.')),
                      'Sanitasi': const Center(child: Text('Data Sanitasi belum tersedia.')),
                    },
                  ),
                  const SizedBox(height: 48),

                  // --- SEKTOR GURU ---
                  _VerticalTabSection(
                    title: 'Guru',
                    icon: Icons.person_outline,
                    tabsData: {
                      'Umur': _buildDataTable(
                        ['Umur', 'Jumlah'],
                        [['Dibawah Umur 31 Tahun', '4'], ['Umur 31 Sampai Dengan 35 Tahun', '0'], ['Umur 36 Sampai Dengan 40 Tahun', '1'], ['Umur 41 Sampai Dengan 45 Tahun', '2'], ['Umur 46 Sampai Dengan 50 Tahun', '3'], ['Umur 51 Sampai Dengan 55 Tahun', '1'], ['Diatas Umur 55 Tahun', '0']],
                      ),
                      'Jenis Kelamin': _buildDataTable(
                        ['Jenis Kelamin', 'Jumlah'],
                        [['Laki-laki', '5'], ['Perempuan', '6']],
                      ),
                    },
                  ),
                  const SizedBox(height: 48),

                  // --- SEKTOR SISWA ---
                  _VerticalTabSection(
                    title: 'Siswa',
                    icon: Icons.school_outlined,
                    tabsData: {
                      'Tingkat': _buildDataTable(
                        ['Tingkat', 'Jumlah'],
                        [['Kelas 10', '44'], ['Kelas 11', '46'], ['Kelas 12', '66'], ['Kelas 13', '0']],
                      ),
                      'Agama': _buildDataTable(
                        ['Agama', 'Jumlah'],
                        [['Islam', '156'], ['Kristen', '0'], ['Katolik', '0']],
                      ),
                      'Jenis Kelamin': _buildDataTable(
                        ['Jenis Kelamin', 'Jumlah'],
                        [['Laki-laki', '80'], ['Perempuan', '76']],
                      ),
                    },
                  ),
                  const SizedBox(height: 100), // Spasi bawah
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BANTUAN
  // ===========================================================================

  // LOGIKA PINTAR: Menentukan Gambar Profil Sekolah (Mendukung Web, Internet & Lokal)
  Widget _buildProfileImage(String namaSekolah) {
    // 1. PRIORITAS UTAMA: Ambil dari Firebase
    final String? fotoFirebase = dataSekolah['foto_profil'];
    
    if (fotoFirebase != null && fotoFirebase.isNotEmpty) {
      // Cek apakah data dari Firebase berupa LINK INTERNET (http)
      if (fotoFirebase.startsWith('http')) {
        return Image.network(
          fotoFirebase,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.account_balance, size: 60, color: Color(0xFF0056B3))),
        );
      } 
      // Jika BUKAN link internet, berarti itu FILE LOKAL dari folder assets
      else {
        return Image.asset(
          fotoFirebase, // Membaca teks "assets/images/namafoto.jpg" dari Firebase
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.account_balance, size: 60, color: Color(0xFF0056B3))),
        );
      }
    }

    // 2. DATA CADANGAN MANUAL (Khusus SMAN 1 Payakumbuh)
    if (namaSekolah.toUpperCase().contains('SMA NEGERI 1 KOTA PAYAKUMBUH')) {
      // Panggil foto lokal dari folder komputer Anda
      return Image.asset(
        'assets/images/smansa.png', 
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.account_balance, size: 60, color: Color(0xFF0056B3))),
      );
    }

    // 3. FALLBACK TERAKHIR: Jika tidak ada di Firebase & tidak ada di manual
    return const Center(child: Icon(Icons.account_balance, size: 60, color: Color(0xFF0056B3)));
  }

  // Desain mini info kolom (Cadisdik, NPSN)
  Widget _buildInfoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            if (title == 'Jarak') const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.info_outline, size: 14, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
      ],
    );
  }

  // WIDGET TEMPLATE: Tabel Biru Khas Jabar
  Widget _buildDataTable(List<String> headers, List<List<String>> rows) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFF006BCC)),
          dataRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            return null;
          }),
          headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          dataTextStyle: const TextStyle(color: Color(0xFF333333), fontSize: 13),
          columns: headers.map((h) => DataColumn(label: Text(h))).toList(),
          rows: rows.map((row) {
            return DataRow(cells: row.map((cell) => DataCell(Text(cell))).toList());
          }).toList(),
        ),
      ),
    );
  }
}

// ===========================================================================
// WIDGET KHUSUS: LOGIKA TAB VERTIKAL (KIRI-KANAN)
// ===========================================================================
class _VerticalTabSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Map<String, Widget> tabsData; // Key: Nama Tab, Value: Widget Tabel

  const _VerticalTabSection({required this.title, required this.icon, required this.tabsData});

  @override
  State<_VerticalTabSection> createState() => _VerticalTabSectionState();
}

class _VerticalTabSectionState extends State<_VerticalTabSection> {
  late String _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.tabsData.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(widget.icon, color: const Color(0xFF007BFF), size: 28),
            const SizedBox(width: 12),
            Text(widget.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.normal, color: Color(0xFF0B1C30))),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.tabsData.keys.map((tabName) {
                  bool isActive = _activeTab == tabName;
                  return InkWell(
                    onTap: () => setState(() => _activeTab = tabName),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: isActive ? const Color(0xFF007BFF) : Colors.transparent, width: 4)),
                        color: isActive ? Colors.white : Colors.transparent,
                      ),
                      child: Text(
                        tabName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? const Color(0xFF007BFF) : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 32),
                child: widget.tabsData[_activeTab]!,
              ),
            ),
          ],
        )
      ],
    );
  }
}