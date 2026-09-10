import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PetaLayananPublikPage extends StatefulWidget {
  const PetaLayananPublikPage({super.key});

  @override
  State<PetaLayananPublikPage> createState() => _PetaLayananPublikPageState();
}

class _PetaLayananPublikPageState extends State<PetaLayananPublikPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  final LatLng _centerPayakumbuh = const LatLng(-0.2285, 100.6321); // Koordinat sekitar Balai Kota

  String _searchQuery = '';
  String _filterKategori = 'Semua Layanan';

  final List<String> _opsiKategori = ['Semua Layanan', 'Layanan Terpadu (MPP)', 'Kependudukan', 'Kesehatan', 'Keamanan & Hukum', 'Keuangan & Pajak'];

  // ===========================================================================
  // DUMMY DATA: LOKASI LAYANAN PUBLIK PAYAKUMBUH
  // ===========================================================================
  final List<Map<String, dynamic>> _dataLayanan = [
    {
      'id': '1',
      'nama': 'Mal Pelayanan Publik (MPP) Balai Kota',
      'kategori': 'Layanan Terpadu (MPP)',
      'instansi': 'Pemerintah Kota Payakumbuh',
      'alamat': 'Lantai 1 Balai Kota, Eks Lapangan Poliko, Payakumbuh',
      'jam': 'Senin - Jumat (08:00 - 15:00)',
      'layanan': 'BPJS Kesehatan, BPJS Ketenagakerjaan, KTP/KK, Imigrasi, Perizinan (DPMPTSP), PDAM, PLN, dll.',
      'lat': -0.2285,
      'lng': 100.6321,
      'ikon': Icons.account_balance_rounded,
    },
    {
      'id': '2',
      'nama': 'Kantor SAMSAT Payakumbuh',
      'kategori': 'Keuangan & Pajak',
      'instansi': 'Bapenda Prov. Sumbar',
      'alamat': 'Jl. Pahlawan, Payakumbuh Barat, Kota Payakumbuh',
      'jam': 'Senin - Sabtu (08:00 - 14:00)',
      'layanan': 'Pajak Kendaraan Bermotor (PKB), Balik Nama, Cetak STNK.',
      'lat': -0.2305,
      'lng': 100.6270,
      'ikon': Icons.directions_car_rounded,
    },
    {
      'id': '3',
      'nama': 'Polres Payakumbuh',
      'kategori': 'Keamanan & Hukum',
      'instansi': 'Kepolisian Republik Indonesia',
      'alamat': 'Jl. Pahlawan No. 33, Payakumbuh Barat',
      'jam': 'Senin - Jumat (08:00 - 15:00)',
      'layanan': 'Pembuatan SIM, SKCK, Laporan Kepolisian (SPKT), Perizinan Keramaian.',
      'lat': -0.2312,
      'lng': 100.6255,
      'ikon': Icons.local_police_rounded,
    },
    {
      'id': '4',
      'nama': 'RSUD Dr. Adnaan WD',
      'kategori': 'Kesehatan',
      'instansi': 'Dinas Kesehatan Kota Payakumbuh',
      'alamat': 'Jl. Sudirman, Payakumbuh Utara, Kota Payakumbuh',
      'jam': 'IGD 24 Jam / Poliklinik (08:00 - 12:00)',
      'layanan': 'Gawat Darurat, Rawat Inap, Poliklinik Spesialis, Medical Check Up.',
      'lat': -0.2215,
      'lng': 100.6300,
      'ikon': Icons.local_hospital_rounded,
    },
    {
      'id': '5',
      'nama': 'Kantor Disdukcapil',
      'kategori': 'Kependudukan',
      'instansi': 'Dinas Kependudukan & Pencatatan Sipil',
      'alamat': 'Jl. Sudirman No. 12, Payakumbuh (Sebagian besar layanan dipindah ke MPP)',
      'jam': 'Senin - Jumat (08:00 - 15:00)',
      'layanan': 'Pengambilan e-KTP, Akta Kelahiran, Akta Kematian, Konsolidasi Data NIK.',
      'lat': -0.2240,
      'lng': 100.6315,
      'ikon': Icons.contact_page_rounded,
    },
  ];

  void _showFilterModal(String title, List<String> options, String currentValue, Function(String) onApply) {
    String tempValue = currentValue;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
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
                        InkWell(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close, size: 20)),
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
                                  decoration: BoxDecoration(color: isSelected ? const Color(0xFF334155) : Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: isSelected ? const Color(0xFF334155) : Colors.grey.shade400)),
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
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
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
    // Logika Filter Data & Pencarian Cerdas
    List<Map<String, dynamic>> filteredDocs = _dataLayanan.where((data) {
      final String nama = data['nama'].toLowerCase();
      final String layanan = data['layanan'].toLowerCase(); // Mencari ke dalam daftar layanan (misal: "bpjs")
      final String kategori = data['kategori'];
      
      bool matchCari = _searchQuery.isEmpty || nama.contains(_searchQuery.toLowerCase()) || layanan.contains(_searchQuery.toLowerCase());
      bool matchKategori = _filterKategori == 'Semua Layanan' || kategori == _filterKategori;

      return matchCari && matchKategori;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B), // Tema Slate/Navy Pemerintahan
        foregroundColor: Colors.white,
        title: const Text('Peta Integrasi Layanan Publik', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BARIS FILTER
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
                            decoration: const InputDecoration(
                              hintText: 'Cari layanan... (Ketik "bpjs", "ktp", atau "sim")', 
                              hintStyle: TextStyle(fontSize: 14, color: Colors.grey), 
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14), 
                              border: InputBorder.none
                            ),
                            onSubmitted: (val) => setState(() => _searchQuery = val),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(icon: const Icon(Icons.close, size: 18, color: Colors.grey), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }),
                        InkWell(
                          onTap: () => setState(() => _searchQuery = _searchController.text),
                          child: Container(height: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 24), decoration: const BoxDecoration(color: Color(0xFF334155), borderRadius: BorderRadius.only(topRight: Radius.circular(7), bottomRight: Radius.circular(7))), alignment: Alignment.center, child: const Text('Cari', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildFilterButton('Kategori Layanan', _filterKategori, () => _showFilterModal('Kategori Layanan', _opsiKategori, _filterKategori, (val) => setState(() => _filterKategori = val)))),
              ],
            ),
          ),
          
          // 2. KONTEN BELAH DUA (Kiri Daftar, Kanan Peta)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SISI KIRI: DAFTAR LAYANAN
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${filteredDocs.length} lokasi layanan ditemukan', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 16),
                        Expanded(
                          child: filteredDocs.isEmpty 
                          ? const Center(child: Text('Layanan tidak ditemukan.'))
                          : ListView.builder(
                              itemCount: filteredDocs.length,
                              itemBuilder: (context, index) {
                                return _buildLayananCard(filteredDocs[index]);
                              },
                            ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  
                  // SISI KANAN: PETA INTERAKTIF GOOGLE MAPS
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
                                initialZoom: 14.5, // Zoom lebih dekat agar letak gedung lebih detail
                                interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                                  userAgentPackageName: 'com.dashboard_kota_payakumbuh.app',
                                ),
                                MarkerLayer(
                                  markers: filteredDocs.map((data) {
                                    LatLng posisi = LatLng(data['lat'], data['lng']);
                                    return Marker(
                                      point: posisi,
                                      width: 260, 
                                      height: 200, 
                                      alignment: Alignment.center,
                                      child: ClickableMarkerLayanan(dataLayanan: data),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            // Peringatan Highlight MPP Balai Kota
                            Positioned(
                              top: 16, left: 16, right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                                child: const Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.amber, size: 18),
                                    SizedBox(width: 8),
                                    Expanded(child: Text('Sebagian besar layanan umum saat ini telah dipusatkan di Mal Pelayanan Publik (MPP) Balai Kota Payakumbuh.', style: TextStyle(color: Colors.white, fontSize: 12))),
                                  ],
                                ),
                              ),
                            ),
                            // Kontrol Zoom
                            Positioned(
                              right: 16, bottom: 16,
                              child: Column(
                                children: [
                                  FloatingActionButton(heroTag: 'zoomInLayanan', mini: true, backgroundColor: Colors.white, onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1), child: const Icon(Icons.add, color: Colors.black87)),
                                  const SizedBox(height: 8),
                                  FloatingActionButton(heroTag: 'zoomOutLayanan', mini: true, backgroundColor: Colors.white, onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1), child: const Icon(Icons.remove, color: Colors.black87)),
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
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String value, VoidCallback onTap) {
    bool isDefault = value == 'Semua Layanan';
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

  Widget _buildLayananCard(Map<String, dynamic> data) {
    LatLng coord = LatLng(data['lat'], data['lng']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                child: Icon(data['ikon'], size: 32, color: const Color(0xFF334155)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['nama'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
                    const SizedBox(height: 4),
                    Text(data['instansi'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(6)),
                      child: Text(data['kategori'], style: const TextStyle(fontSize: 11, color: Color(0xFF334155), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          const Text('Jenis Layanan Tersedia:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(data['layanan'], style: const TextStyle(fontSize: 13, color: Color(0xFF0B1C30), height: 1.4)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(child: Text(data['alamat'], style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(data['jam'], style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _mapController.move(coord, 17.5), // Geser & Zoom dalam ke gedung
              icon: const Icon(Icons.my_location_rounded, size: 16),
              label: const Text('Fokuskan di Peta', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1E293B), side: const BorderSide(color: Color(0xFF1E293B)), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            ),
          )
        ],
      ),
    );
  }
}

// ===========================================================================
// CLASS MANDIRI: Clickable Marker Layanan
// ===========================================================================
class ClickableMarkerLayanan extends StatefulWidget {
  final Map<String, dynamic> dataLayanan;

  const ClickableMarkerLayanan({super.key, required this.dataLayanan});

  @override
  State<ClickableMarkerLayanan> createState() => _ClickableMarkerLayananState();
}

class _ClickableMarkerLayananState extends State<ClickableMarkerLayanan> {
  bool isPopupVisible = false;

  void _togglePopup() {
    setState(() {
      isPopupVisible = !isPopupVisible; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // 1. PIN SLATE/NAVY
        GestureDetector(
          onTap: _togglePopup, 
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isPopupVisible ? const Color(0xFF0F172A) : const Color(0xFF334155), 
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
            ),
            alignment: Alignment.center,
            child: Icon(widget.dataLayanan['ikon'], color: Colors.white, size: 20),
          ),
        ),

        // 2. POP-UP KOTAK PUTIH
        if (isPopupVisible)
          Positioned(
            bottom: 56, 
            child: Material(
              color: Colors.transparent, 
              child: Container(
                width: 240,
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
                        Icon(widget.dataLayanan['ikon'], size: 20, color: const Color(0xFF334155)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.dataLayanan['nama'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B1C30), height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Layanan Tersedia:', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      widget.dataLayanan['layanan'], 
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}