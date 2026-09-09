import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EksplorasiWisataPage extends StatefulWidget {
  const EksplorasiWisataPage({super.key});

  @override
  State<EksplorasiWisataPage> createState() => _EksplorasiWisataPageState();
}

class _EksplorasiWisataPageState extends State<EksplorasiWisataPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  
  String _searchQuery = '';
  String _selectedKategori = 'Kategori Wisata';
  String? _selectedWisataId;

  // Kunci koneksi Firebase agar peta tidak berkedip
  late Stream<QuerySnapshot> _wisataStream;

  final List<String> _kategoriList = ['Kategori Wisata', 'Wisata Alam', 'Taman & Hiburan', 'Sejarah & Budaya', 'Kuliner'];

  @override
  void initState() {
    super.initState();
    _wisataStream = FirebaseFirestore.instance.collection('sektor_pariwisata').snapshots();
  }

  // --- FUNGSI KHUSUS TOMBOL "LIHAT DI PETA" (PETA BERGERAK & MUNCUL POP-UP) ---
  void _fokusKeLokasi(String id, double lat, double lng) {
    _mapController.move(LatLng(lat, lng), 16.0); // Kamera nge-zoom & geser
    setState(() {
      _selectedWisataId = id; // Memunculkan kotak putih
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003F87), // Tema Biru Utama
        foregroundColor: Colors.white,
        title: const Text('Eksplorasi Destinasi Wisata', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // =================================================================
          // 1. HEADER PENCARIAN (SEARCH BAR & FILTER)
          // =================================================================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => setState(() {
                      _searchQuery = val.toLowerCase();
                      _selectedWisataId = null; 
                    }),
                    decoration: InputDecoration(
                      hintText: 'Cari Ngalau Indah, Taman Agam...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB), // Tombol Biru Terang
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Cari', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedKategori,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                        items: _kategoriList.map((String val) {
                          return DropdownMenuItem<String>(value: val, child: Text(val, style: const TextStyle(fontSize: 14)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedKategori = val;
                              _selectedWisataId = null; 
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // =================================================================
          // 2. KONTEN BAWAH (LIST DATA KIRI & PETA KANAN)
          // =================================================================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _wisataStream, 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Belum ada data destinasi wisata.', style: TextStyle(color: Colors.grey)));
                }

                var docs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String nama = (data['nama_destinasi'] ?? '').toString().toLowerCase();
                  String kategori = data['kategori'] ?? '';
                  
                  bool matchesSearch = nama.contains(_searchQuery);
                  bool matchesKategori = _selectedKategori == 'Kategori Wisata' || kategori == _selectedKategori;
                  
                  return matchesSearch && matchesKategori;
                }).toList();

                return Row(
                  children: [
                    // --- BAGIAN KIRI: DAFTAR KARTU ---
                    Expanded(
                      flex: 4,
                      child: Container(
                        color: const Color(0xFFF8F9FA),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${docs.length} destinasi wisata ditemukan', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  var doc = docs[index];
                                  return _buildWisataCard(doc.id, doc.data() as Map<String, dynamic>);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    // --- BAGIAN KANAN: FLUTTER MAP ---
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: const LatLng(-0.2280, 100.6350), 
                                  initialZoom: 13.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.payakumbuh.dashboard',
                                  ),
                                  MarkerLayer(
                                    markers: docs.map((doc) {
                                      var data = doc.data() as Map<String, dynamic>;
                                      double lat = (data['latitude'] ?? 0).toDouble();
                                      double lng = (data['longitude'] ?? 0).toDouble();
                                      bool isSelected = _selectedWisataId == doc.id; 

                                      return Marker(
                                        point: LatLng(lat, lng),
                                        width: 240, 
                                        height: 180, 
                                        alignment: Alignment.center,
                                        child: ClickableMarkerWisata(
                                          dataWisata: data,
                                          isSelected: isSelected,
                                          onTap: () {
                                            setState(() {
                                              if (_selectedWisataId == doc.id) {
                                                _selectedWisataId = null; 
                                              } else {
                                                // HANYA MUNCULKAN POPUP KETIKA KLIK PIN DI PETA (PETA TIDAK BERGERAK)
                                                _selectedWisataId = doc.id; 
                                              }
                                            });
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                              Positioned(
                                right: 16, bottom: 16,
                                child: Column(
                                  children: [
                                    FloatingActionButton(heroTag: 'zIn', mini: true, backgroundColor: Colors.white, onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1), child: const Icon(Icons.add, color: Colors.black87)),
                                    const SizedBox(height: 8),
                                    FloatingActionButton(heroTag: 'zOut', mini: true, backgroundColor: Colors.white, onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1), child: const Icon(Icons.remove, color: Colors.black87)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWisataCard(String docId, Map<String, dynamic> data) {
    String nama = data['nama_destinasi'] ?? 'Tanpa Nama';
    String kategori = data['kategori'] ?? 'Wisata Umum';
    String deskripsi = data['deskripsi'] ?? 'Belum ada deskripsi untuk tempat wisata ini.';
    String lokasi = data['lokasi'] ?? 'Payakumbuh';
    String harga = data['harga_tiket']?.toString() ?? 'Gratis';
    if (harga == '0' || harga.toLowerCase() == 'gratis') harga = 'Gratis'; else harga = 'Rp $harga';

    double lat = (data['latitude'] ?? 0).toDouble();
    double lng = (data['longitude'] ?? 0).toDouble();

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(8)), // Bg Biru Muda
                  child: const Icon(Icons.landscape_rounded, color: Color(0xFF2563EB)), // Icon Biru Terang
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          const Row(children: [Icon(Icons.star_rounded, color: Colors.orange, size: 16), SizedBox(width: 4), Text('4.5', style: TextStyle(fontWeight: FontWeight.bold))])
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2563EB))),
                        child: Text(kategori, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Text(deskripsi, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Row(children: [const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey), const SizedBox(width: 4), Expanded(child: Text(lokasi, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis))])),
                Row(children: [const Icon(Icons.receipt_long_outlined, size: 16, color: Colors.grey), const SizedBox(width: 4), Text(harga, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))]),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    // PANGGIL FUNGSI INI AGAR PETA BERGERAK/NGEZOOM & MUNCUL POPUP
                    onPressed: () => _fokusKeLokasi(docId, lat, lng), 
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('Lihat di Peta'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF003F87), side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12)
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Lihat Detail', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12)
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ClickableMarkerWisata extends StatelessWidget {
  final Map<String, dynamic> dataWisata;
  final bool isSelected;
  final VoidCallback onTap;

  const ClickableMarkerWisata({
    super.key, 
    required this.dataWisata,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String nama = dataWisata['nama_destinasi'] ?? 'Tanpa Nama';
    String kategori = dataWisata['kategori'] ?? 'Wisata';
    String harga = dataWisata['harga_tiket']?.toString() ?? 'Gratis';
    if (harga == '0' || harga.toLowerCase() == 'gratis') harga = 'Gratis'; else harga = 'Rp $harga';

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: onTap, 
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF003F87) : const Color(0xFF2563EB), // Pin Aktif Biru Gelap, Pin Biasa Biru Terang
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.landscape_rounded, color: Colors.white, size: 20),
          ),
        ),

        if (isSelected)
          Positioned(
            bottom: 56, 
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
                        const Icon(Icons.landscape_rounded, size: 20, color: Color(0xFF2563EB)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            nama,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B1C30), height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Kategori', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(kategori, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Harga Tiket', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.receipt_long_rounded, color: Color(0xFF2563EB), size: 14),
                                const SizedBox(width: 4),
                                Text(harga, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}