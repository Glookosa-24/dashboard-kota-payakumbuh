import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import halaman profil sekolah
import 'profil_sekolah_page.dart';

class RekomendasiSekolahPage extends StatefulWidget {
  const RekomendasiSekolahPage({super.key});

  @override
  State<RekomendasiSekolahPage> createState() => _RekomendasiSekolahPageState();
}

class _RekomendasiSekolahPageState extends State<RekomendasiSekolahPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Titik Tengah Bawaan (Kota Payakumbuh)
  final LatLng _centerPayakumbuh = const LatLng(-0.2201, 100.6306);

  // Variabel State
  String _searchQuery = '';
  String _filterJenjang = 'Tampilkan Semua';
  String _filterStatus = 'Tampilkan Semua';
  String _filterAkreditasi = 'Tampilkan Semua';

  // Opsi Filter
  final List<String> _opsiJenjang = ['Tampilkan Semua', 'SD', 'SMP', 'SMA', 'SMK', 'SLB'];
  final List<String> _opsiStatus = ['Tampilkan Semua', 'Negeri', 'Swasta'];
  final List<String> _opsiAkreditasi = ['Tampilkan Semua', 'A', 'B', 'C', 'Belum Terakreditasi'];

  // ===========================================================================
  // FUNGSI POP-UP FILTER 
  // ===========================================================================
  void _showFilterModal(String title, List<String> options, String currentValue, Function(String) onApply) {
    String tempValue = currentValue;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(0),
          child: StatefulBuilder(
            builder: (context, setStateModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 16, color: Color(0xFF565F69))),
                        InkWell(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close, size: 20, color: Colors.black87))
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: options.map((option) {
                        bool isSelected = tempValue == option;
                        return InkWell(
                          onTap: () => setStateModal(() => tempValue = option),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 20, height: 20,
                                  decoration: BoxDecoration(color: isSelected ? const Color(0xFF16A34A) : Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: isSelected ? const Color(0xFF16A34A) : Colors.grey.shade400, width: 1.5)),
                                  child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                                ),
                                const SizedBox(width: 12),
                                Text(option, style: TextStyle(fontSize: 14, color: isSelected ? Colors.black : Colors.black87)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () { onApply(tempValue); Navigator.pop(ctx); },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5C9DFF), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                        child: const Text('Terapkan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003F87),
        foregroundColor: Colors.white,
        title: const Text('Rekomendasi Sekolah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          TextButton.icon(
            onPressed: () {}, 
            icon: const Icon(Icons.compare_arrows_rounded, color: Colors.white),
            label: const Text('Bandingkan Sekolah', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BARIS FILTER PENCARIAN
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(hintText: 'Cari sekolah...', hintStyle: TextStyle(fontSize: 14, color: Colors.grey), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14), border: InputBorder.none),
                            onSubmitted: (val) => setState(() => _searchQuery = val),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(icon: const Icon(Icons.close, size: 18, color: Colors.grey), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }),
                        InkWell(
                          onTap: () => setState(() => _searchQuery = _searchController.text),
                          child: Container(height: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 24), decoration: const BoxDecoration(color: Color(0xFF0056B3), borderRadius: BorderRadius.only(topRight: Radius.circular(7), bottomRight: Radius.circular(7))), alignment: Alignment.center, child: const Text('Cari', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildFilterButton('Lokasi', 'Semua Kota', () {})),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _buildFilterButton('Jenjang Pendidikan', _filterJenjang, () => _showFilterModal('Jenjang Pendidikan', _opsiJenjang, _filterJenjang, (val) => setState(() => _filterJenjang = val)))),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _buildFilterButton('Status', _filterStatus, () => _showFilterModal('Status', _opsiStatus, _filterStatus, (val) => setState(() => _filterStatus = val)))),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _buildFilterButton('Akreditasi', _filterAkreditasi, () => _showFilterModal('Akreditasi', _opsiAkreditasi, _filterAkreditasi, (val) => setState(() => _filterAkreditasi = val)))),
              ],
            ),
          ),
          
          // 2. KONTEN BELAH DUA (Kiri Daftar, Kanan Peta)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('sektor_pendidikan').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('Data sekolah belum tersedia di Server.'));

                List<DocumentSnapshot> filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final String nama = (data['nama_sekolah'] ?? '').toString().toLowerCase();
                  final String jenjang = (data['jenjang'] ?? '').toString().toUpperCase();
                  final String status = (data['status'] ?? 'Negeri').toString();
                  final String akred = (data['akreditasi'] ?? 'A').toString();
                  
                  bool matchCari = _searchQuery.isEmpty || nama.contains(_searchQuery.toLowerCase());
                  bool matchJenjang = _filterJenjang == 'Tampilkan Semua' || jenjang.contains(_filterJenjang);
                  bool matchStatus = _filterStatus == 'Tampilkan Semua' || status == _filterStatus;
                  bool matchAkred = _filterAkreditasi == 'Tampilkan Semua' || akred == _filterAkreditasi;

                  return matchCari && matchJenjang && matchStatus && matchAkred;
                }).toList();

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SISI KIRI: DAFTAR SEKOLAH
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_searchQuery.isNotEmpty) ...[
                              Text('Menampilkan pencarian \'$_searchQuery\'', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
                              const SizedBox(height: 4),
                            ],
                            Text('${filteredDocs.length} hasil ditemukan', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 16),
                            
                            Expanded(
                              child: filteredDocs.isEmpty 
                              ? _buildEmptyState()
                              : ListView.builder(
                                  itemCount: filteredDocs.length,
                                  itemBuilder: (context, index) {
                                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                                    return _buildSchoolCard(data);
                                  },
                                ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      
                      // SISI KANAN: PETA INTERAKTIF FLUTTER_MAP
                      Expanded(
                        flex: 7,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: _centerPayakumbuh,
                                    initialZoom: 13.0,
                                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'com.dashboard_kota_payakumbuh.app',
                                    ),
                                    MarkerLayer(
                                      markers: filteredDocs.map((doc) {
                                        final data = doc.data() as Map<String, dynamic>;
                                        final String nama = data['nama_sekolah'] ?? 'Sekolah';
                                        final String akred = data['akreditasi'] ?? 'A';
                                        
                                        // Auto-Fallback Titik Koordinat Pintar
                                        LatLng titikLokasi = _centerPayakumbuh; 
                                        if (data['latitude'] != null && data['longitude'] != null && 
                                            data['latitude'].toString().isNotEmpty && data['longitude'].toString().isNotEmpty) {
                                          String cleanLat = data['latitude'].toString().replaceAll(',', '').trim();
                                          String cleanLng = data['longitude'].toString().replaceAll(',', '').trim();
                                          double? lat = double.tryParse(cleanLat);
                                          double? lng = double.tryParse(cleanLng);
                                          if (lat != null && lng != null) titikLokasi = LatLng(lat, lng);
                                        }

                                        // WIDGET MARKER DIPERBESAR AGAR KOTAK PUTIH BISA DIKLIK (260x220)
                                        return Marker(
                                          point: titikLokasi,
                                          width: 260, 
                                          height: 220, 
                                          alignment: Alignment.center,
                                          child: ClickableMarker(
                                            dataSekolah: data,
                                            namaSekolah: nama,
                                            akreditasi: akred,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                                
                                // Peringatan & Kontrol Peta
                                Positioned(
                                  top: 16, left: 16, right: 16,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Expanded(child: Text('Aktifkan lokasi untuk menampilkan sekolah terdekat di lokasi anda.', style: TextStyle(color: Colors.white, fontSize: 13))),
                                              InkWell(onTap: () {}, child: const Icon(Icons.close, color: Colors.white, size: 18)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                                        child: Row(
                                          children: [
                                            _buildMapToggle('Lokasi anda', Icons.radio_button_unchecked, false),
                                            _buildMapToggle('Lokasi sekolah', Icons.location_on_outlined, true),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                // Kontrol Zoom
                                Positioned(
                                  right: 16, bottom: 16,
                                  child: Column(
                                    children: [
                                      FloatingActionButton(mini: true, backgroundColor: Colors.white, onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1), child: const Icon(Icons.add, color: Colors.black87)),
                                      const SizedBox(height: 8),
                                      FloatingActionButton(mini: true, backgroundColor: Colors.white, onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1), child: const Icon(Icons.remove, color: Colors.black87)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
            ),
          )
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET PENDUKUNG LAINNYA
  // ===========================================================================
  Widget _buildFilterButton(String label, String value, VoidCallback onTap) {
    bool isDefault = value == 'Tampilkan Semua' || value == 'Semua Kota';
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(isDefault ? label : value, style: TextStyle(fontSize: 13, color: isDefault ? const Color(0xFF565F69) : Colors.black, fontWeight: isDefault ? FontWeight.normal : FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMapToggle(String text, IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: isActive ? const Color(0xFFEFF4FF) : Colors.transparent, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isActive ? const Color(0xFF0056B3) : Colors.grey),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? const Color(0xFF0056B3) : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Tidak ada sekolah yang cocok dengan filter.', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSchoolCard(Map<String, dynamic> data) {
    final String nama = data['nama_sekolah'] ?? 'Sekolah Tidak Diketahui';
    final String status = data['status'] ?? 'Negeri';
    final String akred = data['akreditasi'] ?? 'A';
    final String alamat = data['alamat'] ?? 'Kota Payakumbuh, Sumatera Barat';
    final String npsn = data['npsn'] ?? '108XXXXX';
    
    // Titik koordinat untuk fungsi "Lihat di Peta"
    LatLng coord = _centerPayakumbuh;
    if (data['latitude'] != null && data['longitude'] != null && 
        data['latitude'].toString().isNotEmpty && data['longitude'].toString().isNotEmpty) {
      String cleanLat = data['latitude'].toString().replaceAll(',', '').trim();
      String cleanLng = data['longitude'].toString().replaceAll(',', '').trim();
      double? lat = double.tryParse(cleanLat);
      double? lng = double.tryParse(cleanLng);
      if (lat != null && lng != null) coord = LatLng(lat, lng);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        // KETIKA KOTAK DIKLIK -> Buka Halaman Profil Sekolah
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilSekolahPage(dataSekolah: data),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30)))),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFED7AA))),
                        child: Text(status, style: const TextStyle(fontSize: 11, color: Color(0xFFC2410C), fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle),
                        child: Text(akred, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF0056B3)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(alamat, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Cabdisdik', style: TextStyle(fontSize: 11, color: Colors.grey)), Text('Wilayah IV', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade800))])),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('NPSN', style: TextStyle(fontSize: 11, color: Colors.grey)), Text(npsn, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade800))])),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Row(children: [Text('Siswa ', style: TextStyle(fontSize: 11, color: Colors.grey)), Icon(Icons.people_outline, size: 12, color: Colors.grey)]), Text('${data['jumlah_siswa'] ?? '-'}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade800))])),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // TOMBOL "Lihat di Peta" -> Fokuskan Peta ke Titik Sekolah
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _mapController.move(coord, 16.0); // Geser & Zoom In Peta
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF003F87), side: const BorderSide(color: Color(0xFF003F87)), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Lihat di Peta', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // TOMBOL "Bandingkan" (Tetap Ada)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.compare_arrows_rounded, size: 18),
                      label: const Text('Bandingkan'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEFF4FF), foregroundColor: const Color(0xFF003F87), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// CLASS MANDIRI: Clickable Marker (Tampil Saat Diklik & Ramah HP)
// ===========================================================================
class ClickableMarker extends StatefulWidget {
  final Map<String, dynamic> dataSekolah;
  final String namaSekolah;
  final String akreditasi;

  const ClickableMarker({super.key, required this.dataSekolah, required this.namaSekolah, required this.akreditasi});

  @override
  State<ClickableMarker> createState() => _ClickableMarkerState();
}

class _ClickableMarkerState extends State<ClickableMarker> {
  bool isPopupVisible = false;

  void _togglePopup() {
    setState(() {
      isPopupVisible = !isPopupVisible; // Memunculkan/Menyembunyikan kotak putih saat pin diklik
    });
  }

  void _bukaProfilSekolah() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilSekolahPage(dataSekolah: widget.dataSekolah),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // 1. KOTAK PIN BIRU 
        GestureDetector(
          onTap: _togglePopup, // KETIKA PIN DIKLIK -> MUNCUL POP-UP
          child: Container(
            width: 60,
            height: 36,
            decoration: BoxDecoration(
              color: isPopupVisible ? const Color(0xFF0056B3) : const Color(0xFF003F87), 
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            alignment: Alignment.center,
            child: Text(
              widget.namaSekolah.length > 4 ? widget.namaSekolah.substring(0, 4) : widget.namaSekolah,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ),

        // 2. POP-UP KOTAK PUTIH (MUNCUL TEPAT DI ATAS PIN JIKA AKTIF)
        if (isPopupVisible)
          Positioned(
            bottom: 120, // Posisi presisi agar tidak menutupi pin
            child: GestureDetector(
              onTap: _bukaProfilSekolah, // KETIKA KOTAK PUTIH DIKLIK -> BUKA HALAMAN PROFIL
              child: Material(
                color: Colors.transparent, 
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 8))
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.account_balance_rounded, size: 20, color: Color(0xFF0056B3)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.namaSekolah,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B1C30), height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Cabdisdik', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Text('Wilayah IV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Akreditasi', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle),
                                child: Text(widget.akreditasi, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}