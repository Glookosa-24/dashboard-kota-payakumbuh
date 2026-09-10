import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';

class StatistikAduanPage extends StatefulWidget {
  const StatistikAduanPage({super.key});

  @override
  State<StatistikAduanPage> createState() => _StatistikAduanPageState();
}

class _StatistikAduanPageState extends State<StatistikAduanPage> {
  // Fungsi memunculkan Pop-up Formulir Lapor (Stateful Mandiri)
  void _tampilkanFormLapor(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Mencegah tertutup tidak sengaja saat mengisi form
      builder: (context) {
        return const FormLaporDialogWidget();
      }
    );
  }

  // Fungsi Pop-up Gambar Fullscreen (Agar warga bisa melihat foto jalan lebih jelas)
  void _showImagePreviewPublic(BuildContext context, String base64Image, String title) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Image.memory(base64Decode(base64Image), fit: BoxFit.contain),
            Positioned(
              top: 8, right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 10)]),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              bottom: 16, left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: const Text('Dashboard Pemerintahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================================
            // 1. HEADER DENGAN TOMBOL LAPOR
            // =================================================================
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Beranda  >  Pemerintahan  >  Pantauan Aduan Masyarakat (LAPOR)', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 24),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Layanan Aspirasi & Pengaduan Warga', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        // HANYA ADA TOMBOL BUAT LAPORAN
                        ElevatedButton.icon(
                          onPressed: () => _tampilkanFormLapor(context),
                          icon: const Icon(Icons.edit_document, size: 18),
                          label: const Text('BUAT LAPORAN BARU', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444), // Warna Merah Lapor
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        )
                      ],
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. KARTU KPI
                  Row(
                    children: [
                      Expanded(child: _buildKpiCard('1.240', 'Total Aduan Tahun Ini', Icons.mark_email_unread_rounded, const Color(0xFF3B82F6))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('1.105', 'Aduan Selesai', Icons.check_circle_rounded, const Color(0xFF10B981))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('120', 'Sedang Diproses', Icons.autorenew_rounded, const Color(0xFFF59E0B))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildKpiCard('15', 'Menunggu Verifikasi', Icons.pending_actions_rounded, const Color(0xFFEF4444))),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // 3. GRAFIK TREN (KIRI) & DIAGRAM DONAT (KANAN)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tren Laporan Masuk (6 Bulan Terakhir)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              const SizedBox(height: 32),
                              SizedBox(height: 300, child: _buildLineChart()),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Top 5 Kategori Aduan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              const SizedBox(height: 32),
                              SizedBox(height: 200, child: _buildDonutChart()),
                              const SizedBox(height: 32),
                              _buildDonutLegend('Infrastruktur (Jalan/Jembatan)', const Color(0xFF3B82F6), '45%'),
                              _buildDonutLegend('Kebersihan & Sampah', const Color(0xFF10B981), '25%'),
                              _buildDonutLegend('Bantuan Sosial', const Color(0xFFF59E0B), '15%'),
                              _buildDonutLegend('Ketertiban Umum', const Color(0xFF8B5CF6), '10%'),
                              _buildDonutLegend('Lainnya', const Color(0xFF94A3B8), '5%'),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 40),

                  // ===========================================================
                  // 4. DAFTAR ADUAN TERBARU (DIUPGRADE DENGAN FOTO BEFORE-AFTER)
                  // ===========================================================
                  const Text('Feed Laporan Warga Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('laporan_warga').orderBy('waktu', descending: true).limit(5).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Belum ada laporan dari warga.', style: TextStyle(color: Colors.grey))));
                        }

                        final docs = snapshot.data!.docs;
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            
                            String kategori = data['kategori'] ?? 'Umum';
                            String judul = data['judul'] ?? 'Tanpa Judul';
                            String deskripsi = data['deskripsi'] ?? ''; // Menangkap deskripsi
                            String status = data['status'] ?? 'Menunggu Verifikasi';
                            
                            // Menangkap foto Sebelum (Warga) & Sesudah (Admin)
                            String? fotoSebelum = data['image_base64'];
                            String? fotoSesudah = data['foto_sesudah'];
                            
                            String waktu = data['waktu'] != null 
                              ? '${(data['waktu'] as Timestamp).toDate().toString().substring(0, 16)} WIB'
                              : 'Baru saja';

                            Color statusColor = Colors.red;
                            if (status == 'Selesai') statusColor = Colors.green;
                            if (status == 'Sedang Diproses') statusColor = Colors.orange.shade700;

                            return _buildLaporanItem(
                              context, judul, deskripsi, kategori, waktu, status, statusColor, fotoSebelum, fotoSesudah
                            );
                          },
                        );
                      }
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BANTUAN GRAFIK (TETAP SAMA)
  // ===========================================================================
  Widget _buildKpiCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
              Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (val) => FlLine(color: Colors.grey.shade200, strokeWidth: 1, dashArray: [5, 5])),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (val, _) {
            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'];
            if (val.toInt() >= 0 && val.toInt() < months.length) {
              return Padding(padding: const EdgeInsets.only(top: 10.0), child: Text(months[val.toInt()], style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)));
            }
            return const Text('');
          })),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, _) => Text(val.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 12)))),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0, maxX: 5, minY: 0, maxY: 300,
        lineBarsData: [
          LineChartBarData(
            spots: const [FlSpot(0, 120), FlSpot(1, 150), FlSpot(2, 180), FlSpot(3, 140), FlSpot(4, 210), FlSpot(5, 280)],
            isCurved: true, color: const Color(0xFF3B82F6), barWidth: 4, isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: const Color(0xFF3B82F6).withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChart() {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(enabled: true),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2, centerSpaceRadius: 50,
        sections: [
          PieChartSectionData(color: const Color(0xFF3B82F6), value: 45, title: '45%', radius: 40, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: const Color(0xFF10B981), value: 25, title: '25%', radius: 40, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: const Color(0xFFF59E0B), value: 15, title: '15%', radius: 40, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: const Color(0xFF8B5CF6), value: 10, title: '', radius: 30),
          PieChartSectionData(color: const Color(0xFF94A3B8), value: 5, title: '', radius: 30),
        ],
      ),
    );
  }

  Widget _buildDonutLegend(String label, Color color, String percent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF475569)))),
          Text(percent, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET ITEM LAPORAN (DIUPGRADE DENGAN FOTO BEFORE-AFTER)
  // ===========================================================================
  Widget _buildLaporanItem(BuildContext context, String judul, String deskripsi, String kategori, String waktu, String status, Color statusColor, String? fotoSebelum, String? fotoSesudah) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon User
          Container(padding: const EdgeInsets.all(12), decoration:const BoxDecoration(color:  Color(0xFFF1F5F9), shape: BoxShape.circle), child: const Icon(Icons.person_outline, color: Color(0xFF64748B))),
          const SizedBox(width: 20),
          
          // Konten Tengah (Teks & Foto)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(kategori, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF3B82F6))),
                    Text(waktu, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(judul, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                
                if (deskripsi.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('"$deskripsi"', style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontStyle: FontStyle.italic)),
                ],

                // --- AREA FOTO BUKTI (SEBELUM & SESUDAH) ---
                if (fotoSebelum != null && fotoSebelum.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // KOTAK FOTO SEBELUM (DARI WARGA)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange),
                                SizedBox(width: 6),
                                Text('SEBELUM (Laporan Warga)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _showImagePreviewPublic(context, fotoSebelum, 'Kondisi Sebelum Perbaikan'),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(base64Decode(fotoSebelum), height: 160, width: double.infinity, fit: BoxFit.cover),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // KOTAK FOTO SESUDAH (DARI ADMIN) - Hanya muncul jika sudah di-upload Admin
                      if (fotoSesudah != null && fotoSesudah.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.green),
                                  SizedBox(width: 6),
                                  Text('SESUDAH (Tindak Lanjut)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _showImagePreviewPublic(context, fotoSesudah, 'Kondisi Sesudah Perbaikan (Selesai)'),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(base64Decode(fotoSesudah), height: 160, width: double.infinity, fit: BoxFit.cover),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                    ],
                  )
                ]
              ],
            ),
          ),
          const SizedBox(width: 24),
          
          // Badge Status di Kanan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor.withValues(alpha: 0.3))),
            child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
          )
        ],
      ),
    );
  }
}

// ===========================================================================
// CLASS MANDIRI: FORM LAPORAN DENGAN UPLOAD FIREBASE (KOMPRESI AKTIF)
// ===========================================================================
class FormLaporDialogWidget extends StatefulWidget {
  const FormLaporDialogWidget({super.key});

  @override
  State<FormLaporDialogWidget> createState() => _FormLaporDialogWidgetState();
}

class _FormLaporDialogWidgetState extends State<FormLaporDialogWidget> {
  String _kategoriPilihan = 'Infrastruktur & Jalan';
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  String? _imageName;
  bool isSubmitting = false;

  // Fungsi Pilih Foto
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800, 
      maxHeight: 800, // Menambah maxHeight agar rasio terjaga
      imageQuality: 30, // Mengubah ke 30 agar file size sangat kecil & aman untuk Base64
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = pickedFile.name;
      });
    }
  }

  // Fungsi Kirim Data ke Firebase
  Future<void> _kirimLaporanKeFirebase() async {
    if (_judulController.text.trim().isEmpty || _deskripsiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap isi Judul dan Deskripsi Laporan!')));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // Encode Gambar ke Base64
      String? base64Image;
      if (_imageBytes != null) {
        base64Image = base64Encode(_imageBytes!);
      }

      // Simpan ke Koleksi "laporan_warga"
      await FirebaseFirestore.instance.collection('laporan_warga').add({
        'kategori': _kategoriPilihan,
        'judul': _judulController.text,
        'deskripsi': _deskripsiController.text,
        'image_base64': base64Image, // Foto Sebelum
        'foto_sesudah': '', // Foto Sesudah (Kosong di awal, akan diisi Admin nanti)
        'status': 'Menunggu Verifikasi',
        'waktu': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        Navigator.pop(context); // Tutup dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Laporan beserta bukti foto berhasil dikirim!', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 32, right: 32, left: 32),
          ),
        );
      }
    } catch (e) {
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Form
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.campaign_rounded, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text('Sampaikan Laporan Anda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    if (!isSubmitting)
                      InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, color: Colors.white)),
                  ],
                ),
              ),
              
              // Body Form
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori Aduan
                    const Text('Kategori Laporan *', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _kategoriPilihan,
                          isExpanded: true,
                          items: ['Infrastruktur & Jalan', 'Kebersihan & Lingkungan', 'Ketertiban Umum', 'Bantuan Sosial', 'Layanan Publik'].map((String val) {
                            return DropdownMenuItem<String>(value: val, child: Text(val, style: const TextStyle(fontSize: 14)));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _kategoriPilihan = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Judul Laporan
                    const Text('Judul Laporan *', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _judulController,
                      decoration: InputDecoration(
                        hintText: 'Misal: Jalan Berlubang di Pasar Ibuh',
                        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Detail Laporan
                    const Text('Deskripsi Lengkap *', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _deskripsiController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Ceritakan detail kronologi, lokasi spesifik, dan masalah yang terjadi...',
                        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Upload Foto Bukti
                    const Text('Lampiran Bukti Foto (Sangat Disarankan)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: isSubmitting ? null : _pickImage,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_imageBytes != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(_imageBytes!, height: 100, fit: BoxFit.cover),
                              ),
                              const SizedBox(height: 12),
                              Text(_imageName!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              const SizedBox(height: 4),
                              const Text('Klik kotak ini untuk mengganti foto', style: TextStyle(fontSize: 12, color: Colors.blue)),
                            ] else ...[
                              Icon(Icons.cloud_upload_outlined, size: 32, color: Colors.blue.shade400),
                              const SizedBox(height: 8),
                              const Text('Klik untuk memilih foto dari perangkat Anda', style: TextStyle(fontSize: 13, color: Colors.grey)),
                            ]
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tombol Submit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!isSubmitting)
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                          ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: isSubmitting ? null : _kirimLaporanKeFirebase,
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: isSubmitting 
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Kirim Laporan', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}