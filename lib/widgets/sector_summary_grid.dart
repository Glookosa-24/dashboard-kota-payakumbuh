import 'package:flutter/material.dart';

class SectorSummaryGrid extends StatelessWidget {
  final bool isWideScreen;

  const SectorSummaryGrid({super.key, required this.isWideScreen});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(
          child: Column(
            children: [
              Text(
                'Ringkasan Data Sektor',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Tinjauan cepat metrik utama per sektor vital kota.',
                style: TextStyle(fontSize: 15, color: Color(0xFFEFF4FF)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (isWideScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildPendidikanCard(),
                    const SizedBox(height: 24),
                    _buildKesehatanCard(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildUmkmCard(),
                    const SizedBox(height: 24),
                    _buildPariwisataCard(),
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildPendidikanCard(),
              const SizedBox(height: 20),
              _buildUmkmCard(),
              const SizedBox(height: 20),
              _buildKesehatanCard(),
              const SizedBox(height: 20),
              _buildPariwisataCard(),
            ],
          ),
      ],
    );
  }

  // 1. Pendidikan & Sekolah
  Widget _buildPendidikanCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD7E1ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school_rounded, color: Color(0xFF565F69)),
              ),
              const SizedBox(width: 14),
              const Text(
                'Pendidikan & Sekolah',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30)),
              ),
            ],
          ),
          const Divider(height: 28),
          _buildSchoolItem('SDN 01 Payakumbuh', '450 Siswa'),
          const SizedBox(height: 10),
          _buildSchoolItem('SMPN 1 Payakumbuh', '620 Siswa'),
          const SizedBox(height: 10),
          _buildSchoolItem('SMAN 2 Payakumbuh', '810 Siswa'),
        ],
      ),
    );
  }

  Widget _buildSchoolItem(String name, String students) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC2C6D4).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0B1C30))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF565F69).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(students, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF565F69))),
          ),
        ],
      ),
    );
  }

  // 2. UMKM & Ekonomi Kreatif
  Widget _buildUmkmCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD7E2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.storefront_rounded, color: Color(0xFF003F87)),
              ),
              const SizedBox(width: 14),
              const Text(
                'UMKM & Ekonomi Kreatif',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30)),
              ),
            ],
          ),
          const Divider(height: 28),
          Row(
            children: [
              Expanded(child: _buildUmkmStatBox('1.420', 'Total UMKM Unit')),
              const SizedBox(width: 8),
              Expanded(child: _buildUmkmStatBox('15', 'Sentra Ind. Rendang')),
              const SizedBox(width: 8),
              Expanded(child: _buildUmkmStatBox('4', 'Pasar Tradisional')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUmkmStatBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF003F87).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF003F87).withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF003F87))),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Color(0xFF565F69))),
        ],
      ),
    );
  }

  // 3. Kesehatan & Layanan
  Widget _buildKesehatanCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDAD6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_hospital_rounded, color: Color(0xFFBA1A1A)),
              ),
              const SizedBox(width: 14),
              const Text(
                'Kesehatan & Layanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30)),
              ),
            ],
          ),
          const Divider(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('RSUD dr. Adnaan WD', style: TextStyle(fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Colors.green.shade700),
                      const SizedBox(width: 4),
                      Text('Aktif', style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Puskesmas Aktif', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('10 Unit tersebar', style: TextStyle(fontSize: 12, color: Color(0xFF565F69))),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cakupan Layanan BPJS', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('85%', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003F87))),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: const LinearProgressIndicator(
                    value: 0.85,
                    backgroundColor: Color(0xFFE5EEFF),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF003F87)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Pariwisata & Lingkungan
  Widget _buildPariwisataCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tour_rounded, color: Color(0xFF204171)),
              ),
              const SizedBox(width: 14),
              const Text(
                'Pariwisata & Lingkungan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30)),
              ),
            ],
          ),
          const Divider(height: 28),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DESTINASI POPULER', style: TextStyle(fontSize: 10, color: Color(0xFF565F69))),
                          SizedBox(height: 2),
                          Text('Ngalau Indah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('KUNJUNGAN BULAN INI', style: TextStyle(fontSize: 10, color: Color(0xFF565F69))),
                          SizedBox(height: 2),
                          Text('+5.000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF204171))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC2C6D4).withValues(alpha: 0.3)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.wb_sunny_rounded, size: 40, color: Color(0xFFF59E0B)),
                      SizedBox(height: 6),
                      Text('28°C', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      Text('Cerah, Payakumbuh', style: TextStyle(fontSize: 11, color: Color(0xFF565F69))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
