import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/city_dashboard_models.dart';

class InteractiveMapSection extends StatefulWidget {
  final bool isWideScreen;
  final String selectedDistrict;
  final ValueChanged<String> onDistrictTap;

  const InteractiveMapSection({
    super.key,
    required this.isWideScreen,
    required this.selectedDistrict,
    required this.onDistrictTap,
  });

  static const List<DistrictData> districts = [
    DistrictData(
      id: 'barat',
      name: 'Payakumbuh Barat',
      tag: 'Kecamatan Terpadat',
      population: 52450,
      xPercent: 0.35,
      yPercent: 0.40,
      colorHex: '#003F87',
    ),
    DistrictData(
      id: 'utara',
      name: 'Payakumbuh Utara',
      tag: 'Sentra Pertanian',
      population: 32120,
      xPercent: 0.52,
      yPercent: 0.25,
      colorHex: '#BA1A1A',
    ),
    DistrictData(
      id: 'timur',
      name: 'Payakumbuh Timur',
      tag: 'Kawasan Pendidikan',
      population: 28900,
      xPercent: 0.62,
      yPercent: 0.45,
      colorHex: '#565F69',
    ),
    DistrictData(
      id: 'selatan',
      name: 'Payakumbuh Selatan',
      tag: 'Destinasi Wisata',
      population: 11250,
      xPercent: 0.45,
      yPercent: 0.62,
      colorHex: '#204171',
    ),
    DistrictData(
      id: 'latina',
      name: 'Latina',
      tag: 'Pengembangan Industri',
      population: 15280,
      xPercent: 0.58,
      yPercent: 0.68,
      colorHex: '#0056B3',
    ),
  ];

  @override
  State<InteractiveMapSection> createState() => _InteractiveMapSectionState();
}

class _InteractiveMapSectionState extends State<InteractiveMapSection> {
  final MapController _mapController = MapController();
  String _selectedTopic = 'Semua Sektor';
  String _selectedOrg = 'Semua OPD';

  final List<String> _topics = [
    'Semua Sektor',
    'Pendidikan & Sekolah',
    'Kesehatan & Fasilitas',
    'Pariwisata & Budaya',
    'Industri & UMKM Rendang',
    'Infrastruktur & Transportasi',
  ];

  final List<String> _organizations = [
    'Semua OPD',
    'Dinas Pendidikan',
    'Dinas Kesehatan',
    'Dinas Pariwisata, Pemuda & Olahraga',
    'Diskoperindag Payakumbuh',
    'Diskominfo Payakumbuh',
  ];

  // ====================================================================
  // DATA LOKASI SPASIAL (TITIK PIN)
  // ====================================================================
  final List<Map<String, dynamic>> _lokasiSektor = [
    {
      "nama": "RSUD dr. Adnaan WD",
      "kategori": "Kesehatan & Fasilitas",
      "koordinat": const LatLng(-0.2315, 100.6280),
      "ikon": Icons.local_hospital_rounded,
      "warna": Colors.red,
    },
    {
      "nama": "Puskesmas Ibuh",
      "kategori": "Kesehatan & Fasilitas",
      "koordinat": const LatLng(-0.2200, 100.6350),
      "ikon": Icons.local_hospital_rounded,
      "warna": Colors.red,
    },
    {
      "nama": "Objek Wisata Ngalau Indah",
      "kategori": "Pariwisata & Budaya",
      "koordinat": const LatLng(-0.2450, 100.6400),
      "ikon": Icons.park_rounded,
      "warna": Colors.green,
    },
    {
      "nama": "Kampung Randang Payakumbuh",
      "kategori": "Industri & UMKM Rendang",
      "koordinat": const LatLng(-0.2100, 100.6200),
      "ikon": Icons.storefront_rounded,
      "warna": Colors.orange,
    },
    {
      "nama": "Pasar Tradisional Ibuh",
      "kategori": "Industri & UMKM Rendang",
      "koordinat": const LatLng(-0.2250, 100.6250),
      "ikon": Icons.storefront_rounded,
      "warna": Colors.orange,
    },
    {
      "nama": "SMA Negeri 1 Payakumbuh",
      "kategori": "Pendidikan & Sekolah",
      "koordinat": const LatLng(-0.2280, 100.6350),
      "ikon": Icons.school_rounded,
      "warna": Colors.blue,
    },
  ];

  // Fungsi memunculkan pop-up detail lokasi saat pin diklik
  void _tampilkanInfoLokasi(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: data['warna'].withValues(alpha: 0.1),
              child: Icon(data['ikon'], color: data['warna'], size: 30),
            ),
            const SizedBox(height: 16),
            Text(data['nama'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: data['warna'].withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(data['kategori'], textAlign: TextAlign.center, style: TextStyle(color: data['warna'], fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 16),
            const Text('Koordinat GPS:', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('${data['koordinat'].latitude}, ${data['koordinat'].longitude}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003F87), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup Panel'),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(
          child: Column(
            children: [
              Text(
                'Peta Wilayah & Sebaran Sektor',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Eksplorasi data spasial Kota Payakumbuh berdasarkan kecamatan dan sektor.',
                style: TextStyle(fontSize: 15, color: Color(0xFFEFF4FF)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (widget.isWideScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _buildMapCanvas(context)),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: _buildFilterAndListPanel(context)),
            ],
          )
        else
          Column(
            children: [
              _buildMapCanvas(context),
              const SizedBox(height: 20),
              _buildFilterAndListPanel(context),
            ],
          ),
      ],
    );
  }

  // WIDGET PETA ASLI MENGGUNAKAN FLUTTER_MAP & LATLONG2
  Widget _buildMapCanvas(BuildContext context) {
    // Memfilter pin lokasi berdasarkan topik yang dipilih di dropdown
    List<Marker> titikLokasi = _lokasiSektor.where((data) {
      if (_selectedTopic == 'Semua Sektor') return true;
      return data['kategori'] == _selectedTopic;
    }).map((data) {
      return Marker(
        point: data['koordinat'],
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _tampilkanInfoLokasi(data),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: data['warna'], shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]),
                child: Icon(data['ikon'], color: Colors.white, size: 14),
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Container(
      height: 520,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(-0.2201, 100.6306),
                  initialZoom: 12.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.dashboard_kota_payakumbuh.app',
                  ),
                  
                  // Layer 1: Titik Spesifik Lokasi Sektor (Hasil Filter)
                  MarkerLayer(markers: titikLokasi),

                  // Layer 2: Penanda Kecamatan Besar Asli Milik Anda
                  MarkerLayer(
                    markers: InteractiveMapSection.districts.map((d) {
                      final isSelected = d.id == widget.selectedDistrict;

                      LatLng coordinates = const LatLng(-0.2201, 100.6306);
                      if (d.id == 'barat') coordinates = const LatLng(-0.2260, 100.6200);
                      if (d.id == 'utara') coordinates = const LatLng(-0.2050, 100.6350);
                      if (d.id == 'timur') coordinates = const LatLng(-0.2280, 100.6550);
                      if (d.id == 'selatan') coordinates = const LatLng(-0.2450, 100.6300);
                      if (d.id == 'latina') coordinates = const LatLng(-0.2000, 100.6150);

                      return Marker(
                        point: coordinates,
                        width: 130,
                        height: 80,
                        child: GestureDetector(
                          onTap: () => widget.onDistrictTap(d.id),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: isSelected ? 40 : 32,
                                color: isSelected ? const Color(0xFF003F87) : const Color(0xFFBA1A1A).withValues(alpha: 0.5), // Dibuat pudar agar tidak menabrak titik sektor
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B1C30),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    d.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: Column(
                children: [
                  _buildMapBtn(Icons.refresh_rounded, () {
                    _mapController.move(const LatLng(-0.2201, 100.6306), 12.5);
                  }),
                  const SizedBox(height: 8),
                  _buildMapBtn(Icons.zoom_in_rounded, () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom + 1);
                  }),
                  const SizedBox(height: 8),
                  _buildMapBtn(Icons.zoom_out_rounded, () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom - 1);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF0B1C30)),
      ),
    );
  }

  // WIDGET PANEL FILTER DI SISI KANAN
  Widget _buildFilterAndListPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Sektor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B1C30),
            ),
          ),
          const SizedBox(height: 16),

          // 1. Kotak Pencarian "Cari"
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: const Icon(Icons.tune, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFEFF4FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Dropdown Filter Topik / Sektor (Akan Mengubah Tampilan Peta)
          const Text(
            'Topik:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30)),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTopic,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF003F87)),
                items: _topics.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13, color: Color(0xFF0B1C30))))).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedTopic = val ?? _topics[0];
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3. Dropdown Filter Organisasi (OPD)
          const Text(
            'Organisasi:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30)),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedOrg,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF003F87)),
                items: _organizations.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13, color: Color(0xFF0B1C30))))).toList(),
                onChanged: (val) => setState(() => _selectedOrg = val ?? _organizations[0]),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Data per Kecamatan
          const Text(
            'Data per Kecamatan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B1C30),
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: InteractiveMapSection.districts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final d = InteractiveMapSection.districts[index];
              final isSelected = d.id == widget.selectedDistrict;

              return InkWell(
                onTap: () {
                  widget.onDistrictTap(d.id);
                  // Otomatis menggeser kamera peta ke kecamatan yang dipilih
                  LatLng targetCoordinates = const LatLng(-0.2201, 100.6306);
                  if (d.id == 'barat') targetCoordinates = const LatLng(-0.2260, 100.6200);
                  if (d.id == 'utara') targetCoordinates = const LatLng(-0.2050, 100.6350);
                  if (d.id == 'timur') targetCoordinates = const LatLng(-0.2280, 100.6550);
                  if (d.id == 'selatan') targetCoordinates = const LatLng(-0.2450, 100.6300);
                  if (d.id == 'latina') targetCoordinates = const LatLng(-0.2000, 100.6150);
                  
                  _mapController.move(targetCoordinates, 14.0); // Zoom in sedikit ke kecamatan
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE5EEFF) : const Color(0xFFF8F9FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF003F87) : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF0B1C30),
                            ),
                          ),
                          Text(
                            d.tag,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF565F69),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            d.population.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xFF003F87),
                            ),
                          ),
                          const Text(
                            'Jiwa',
                            style: TextStyle(fontSize: 11, color: Color(0xFF565F69)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Unduh Laporan Spasial'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF003F87),
                side: const BorderSide(color: Color(0xFF003F87)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}