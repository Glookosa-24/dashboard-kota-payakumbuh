import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORT UNTUK FITUR PDF ---
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// --- IMPORT UNTUK FITUR EXCEL (CSV) ---
import 'package:file_saver/file_saver.dart'; 
import 'dart:typed_data';
import 'dart:convert';

// --- IMPORT UNTUK UPLOAD FOTO ---
import 'package:image_picker/image_picker.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String _activeMenu = 'Laporan Warga (LAPOR)'; // Default menu

  // =========================================================================
  // REFERENSI FIREBASE & CONTROLLER (KHUSUS ADMIN KOTA)
  // =========================================================================
  final CollectionReference _laporanCollection = FirebaseFirestore.instance.collection('laporan_warga');

  final CollectionReference _umkmCollection = FirebaseFirestore.instance.collection('sektor_umkm');
  final TextEditingController _namaUmkmCtrl = TextEditingController();
  final TextEditingController _bidangUmkmCtrl = TextEditingController();
  final TextEditingController _omzetUmkmCtrl = TextEditingController();
  final TextEditingController _produkCtrl = TextEditingController();
  final TextEditingController _stokCtrl = TextEditingController();

  final CollectionReference _pendidikanCollection = FirebaseFirestore.instance.collection('sektor_pendidikan');
  final TextEditingController _namaSekolahCtrl = TextEditingController();
  final TextEditingController _jenjangCtrl = TextEditingController();
  final TextEditingController _jumlahSiswaCtrl = TextEditingController();
  final TextEditingController _statusCtrl = TextEditingController();
  final TextEditingController _akreditasiCtrl = TextEditingController();
  final TextEditingController _alamatCtrl = TextEditingController();
  final TextEditingController _latitudeCtrl = TextEditingController();
  final TextEditingController _longitudeCtrl = TextEditingController();

  final CollectionReference _kesehatanCollection = FirebaseFirestore.instance.collection('sektor_kesehatan');
  final TextEditingController _namaFaskesCtrl = TextEditingController();
  final TextEditingController _jenisFaskesCtrl = TextEditingController();
  final TextEditingController _layananFaskesCtrl = TextEditingController();

  final CollectionReference _kependudukanCollection = FirebaseFirestore.instance.collection('sektor_kependudukan');
  final TextEditingController _kecamatanCtrl = TextEditingController();
  final TextEditingController _populasiCtrl = TextEditingController();
  final TextEditingController _kepadatanCtrl = TextEditingController();

  final CollectionReference _pariwisataCollection = FirebaseFirestore.instance.collection('sektor_pariwisata');
  final TextEditingController _namaDestinasiCtrl = TextEditingController();
  final TextEditingController _kategoriWisataCtrl = TextEditingController();
  final TextEditingController _lokasiWisataCtrl = TextEditingController();
  final TextEditingController _deskripsiWisataCtrl = TextEditingController();
  final TextEditingController _hargaWisataCtrl = TextEditingController();
  final TextEditingController _latWisataCtrl = TextEditingController();
  final TextEditingController _lngWisataCtrl = TextEditingController();

  @override
  void dispose() {
    _namaUmkmCtrl.dispose(); _bidangUmkmCtrl.dispose(); _omzetUmkmCtrl.dispose(); _produkCtrl.dispose(); _stokCtrl.dispose();
    _namaSekolahCtrl.dispose(); _jenjangCtrl.dispose(); _jumlahSiswaCtrl.dispose(); _statusCtrl.dispose(); _akreditasiCtrl.dispose(); _alamatCtrl.dispose(); _latitudeCtrl.dispose(); _longitudeCtrl.dispose(); 
    _namaFaskesCtrl.dispose(); _jenisFaskesCtrl.dispose(); _layananFaskesCtrl.dispose();
    _kecamatanCtrl.dispose(); _populasiCtrl.dispose(); _kepadatanCtrl.dispose();
    _namaDestinasiCtrl.dispose(); _kategoriWisataCtrl.dispose(); _lokasiWisataCtrl.dispose(); _deskripsiWisataCtrl.dispose(); _hargaWisataCtrl.dispose(); _latWisataCtrl.dispose(); _lngWisataCtrl.dispose();
    super.dispose();
  }

  // =========================================================================
  // FUNGSI NOTIFIKASI REAL-TIME (ADUAN BARU)
  // =========================================================================
  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 520, 
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
             child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.notifications_active_rounded, color: Colors.amber, size: 28),
                  SizedBox(width: 12),
                  Text('Laporan Warga Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              SizedBox(
                height: 400, 
                child: StreamBuilder<QuerySnapshot>(
                  stream: _laporanCollection.where('status', isEqualTo: 'Menunggu Verifikasi').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mark_email_read_rounded, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('Hore! Semua laporan sudah diproses.', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }
                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final waktu = data['waktu'] != null ? (data['waktu'] as Timestamp).toDate().toString().substring(0, 16) : 'Baru saja';
                        
                        return Card(
                          elevation: 0,
                          color: const Color(0xFFF8F9FF),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.red.shade100)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(backgroundColor: Colors.red.shade100, child: const Icon(Icons.warning_rounded, color: Colors.red)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(data['judul'] ?? 'Tanpa Judul', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 6),
                                      Text('Kategori: ${data['kategori'] ?? '-'}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                      Text('Waktu: $waktu WIB', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    setState(() => _activeMenu = 'Laporan Warga (LAPOR)');
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003F87), foregroundColor: Colors.white, elevation: 0),
                                  child: const Text('Cek Detail', style: TextStyle(fontSize: 12)),
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Tutup Panel', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
        ),
      ),
    );
  }

  // =========================================================================
  // HELPER UNTUK MENDAPATKAN KOLEKSI AKTIF
  // =========================================================================
  Query _getActiveQuery() {
    switch (_activeMenu) {
      case 'Laporan Warga (LAPOR)': return _laporanCollection.orderBy('waktu', descending: true);
      case 'Kelola UMKM': return _umkmCollection;
      case 'Pendidikan': return _pendidikanCollection;
      case 'Kesehatan': return _kesehatanCollection;
      case 'Kependudukan': return _kependudukanCollection;
      case 'Pariwisata': return _pariwisataCollection;
      default: return _laporanCollection;
    }
  }

  // =========================================================================
  // FUNGSI EKSPOR KE EXCEL (CSV)
  // =========================================================================
  Future<void> _unduhCSV(String title, List<String> columns) async {
    final Query activeQuery = _getActiveQuery();
    final QuerySnapshot snapshot = await activeQuery.get();
    List<List<dynamic>> rows = [];
    
    List<String> header = columns.where((col) => col != 'AKSI' && col != 'BUKTI FOTO').toList();
    rows.add(header);

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>; 
      if (_activeMenu == 'Kelola UMKM') {
        rows.add([data['nama'] ?? '-', '${data['produk'] ?? '-'} (${data['stok'] ?? 0})', data['omzet'] ?? '0']);
      } else if (_activeMenu == 'Pendidikan') {
        rows.add([data['nama_sekolah'] ?? '-', data['jenjang'] ?? '-', data['jumlah_siswa'] ?? '0']);
      } else if (_activeMenu == 'Kesehatan') {
        rows.add([data['nama_faskes'] ?? '-', data['jenis'] ?? '-', data['layanan'] ?? '-']);
      } else if (_activeMenu == 'Kependudukan') {
        rows.add([data['kecamatan'] ?? '-', data['populasi'] ?? '0', data['kepadatan'] ?? '-']);
      } else if (_activeMenu == 'Pariwisata') {
        rows.add([data['nama_destinasi'] ?? '-', data['kategori'] ?? '-', data['lokasi'] ?? '-']);
      } else if (_activeMenu == 'Laporan Warga (LAPOR)') {
        String tgl = data['waktu'] != null ? (data['waktu'] as Timestamp).toDate().toString().substring(0, 16) : '-';
        rows.add([tgl, data['kategori'] ?? '-', data['judul'] ?? '-', data['status'] ?? '-']);
      }
    }

    String csvData = rows.map((row) => row.map((item) => '"${item.toString().replaceAll('"', '""')}"').join(',')).join('\n');
    Uint8List bytes = Uint8List.fromList(utf8.encode(csvData));

    await FileSaver.instance.saveFile(
      name: 'Rekap_Data_${_activeMenu.replaceAll(" ", "_")}.csv',
      bytes: bytes,
    );

    _showSuccessSnackbar('File Excel (CSV) berhasil diunduh!');
  }

  // =========================================================================
  // FUNGSI CETAK LAPORAN PDF (SUDAH DIPERBAIKI CONST-NYA)
  // =========================================================================
  Future<void> _cetakLaporanPDF(String title, List<String> columns) async {
    final Query activeQuery = _getActiveQuery();
    final QuerySnapshot snapshot = await activeQuery.get();
    final List<DocumentSnapshot> docs = snapshot.docs;
    final pdf = pw.Document();

    List<List<String>> pdfData = [];
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>; 
      if (_activeMenu == 'Kelola UMKM') {
        pdfData.add([data['nama'] ?? '-', '${data['produk'] ?? '-'} (${data['stok'] ?? 0} Pcs)', 'Rp ${data['omzet'] ?? '0'}']);
      } else if (_activeMenu == 'Pendidikan') {
        pdfData.add([data['nama_sekolah'] ?? '-', data['jenjang'] ?? '-', '${data['jumlah_siswa'] ?? '0'} Siswa']);
      } else if (_activeMenu == 'Kesehatan') {
        pdfData.add([data['nama_faskes'] ?? '-', data['jenis'] ?? '-', data['layanan'] ?? '-']);
      } else if (_activeMenu == 'Kependudukan') {
        pdfData.add([data['kecamatan'] ?? '-', '${data['populasi'] ?? '0'} Jiwa', '${data['kepadatan'] ?? '-'} /km²']);
      } else if (_activeMenu == 'Pariwisata') {
        pdfData.add([data['nama_destinasi'] ?? '-', data['kategori'] ?? '-', data['lokasi'] ?? '-']);
      } else if (_activeMenu == 'Laporan Warga (LAPOR)') {
        String tgl = data['waktu'] != null ? (data['waktu'] as Timestamp).toDate().toString().substring(0, 16) : '-';
        pdfData.add([tgl, data['kategori'] ?? '-', data['judul'] ?? '-', data['status'] ?? '-']);
      }
    }

    if (pdfData.isEmpty) pdfData.add(['Data Kosong', '-', '-']);
    List<String> pdfColumns = columns.where((col) => col != 'AKSI' && col != 'BUKTI FOTO').toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('PEMERINTAH KOTA PAYAKUMBUH', style: const pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('DASHBOARD MANAJEMEN KOTA', style: const pw.TextStyle(fontSize: 12)),
                  ]
                ),
                pw.Text('Dokumen Resmi', style: const pw.TextStyle(fontSize: 12, color: PdfColors.blue800, fontWeight: pw.FontWeight.bold)),
              ]
            ),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 20),
            pw.Center(child: pw.Text('LAPORAN DATA ${_activeMenu.toUpperCase()}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 20),
            pw.Text('Dicetak pada: ${DateTime.now().toLocal().toString().substring(0, 16)} WIB', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 10),
            
            pw.TableHelper.fromTextArray(
              headers: pdfColumns,
              data: pdfData,
              border: pw.TableBorder.all(color: PdfColors.grey400),
              headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              cellStyle: const pw.TextStyle(fontSize: 11),
              oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
            ),
            pw.SizedBox(height: 50),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Admin Pusat Diskominfo,'),
                  pw.SizedBox(height: 60),
                  pw.Text('(............................................)'),
                ]
              )
            )
          ];
        }
      )
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_Data_${_activeMenu.replaceAll(" ", "_")}_Payakumbuh.pdf',
    );
  }

  // =========================================================================
  // FUNGSI INTERAKTIF (SNACKBAR, KONFIRMASI, & PREVIEW GAMBAR)
  // =========================================================================
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(24),
        elevation: 10,
      ),
    );
  }

  void _confirmDelete(DocumentSnapshot doc, CollectionReference collection) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Konfirmasi Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin menghapus data ini secara permanen? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await collection.doc(doc.id).delete();
              if (context.mounted) {
                Navigator.pop(ctx);
                _showSuccessSnackbar('Data berhasil dihapus selamanya!');
              }
            },
            child: const Text('Ya, Hapus Data'),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(String base64Image) {
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
            )
          ],
        ),
      )
    );
  }

  // =========================================================================
  // POP-UP UNTUK MENGUBAH STATUS LAPORAN WARGA
  // =========================================================================
  void _showUpdateStatusLapor(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    String currentStatus = data['status'] ?? 'Menunggu Verifikasi';
    String existingFotoSesudah = data['foto_sesudah'] ?? ''; 

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (ctx) {
        String tempStatus = currentStatus;
        
        Uint8List? selectedImageBytes;
        String selectedImageName = '';
        bool isUploading = false;

        return StatefulBuilder(
          builder: (context, setStateModal) {
            
            Widget buildStatusOption(String title, Color color, String value) {
              bool isSelected = tempStatus == value;
              return InkWell(
                onTap: () => setStateModal(() => tempStatus = value),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 1.5 : 1)
                  ),
                  child: Row(
                    children: [
                      Icon(isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: isSelected ? color : Colors.grey),
                      const SizedBox(width: 12),
                      Text(title, style: TextStyle(color: isSelected ? color : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    ],
                  ),
                ),
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Update Status Laporan', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildStatusOption('Menunggu Verifikasi', Colors.red, 'Menunggu Verifikasi'),
                      buildStatusOption('Sedang Diproses', Colors.orange.shade700, 'Sedang Diproses'),
                      buildStatusOption('Selesai', Colors.green, 'Selesai'),

                      if (tempStatus == 'Selesai') ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text('Upload Foto Bukti Perbaikan (Sesudah)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 13)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                          child: Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 30,
                                    maxWidth: 800,
                                    maxHeight: 800,
                                  );
                                  
                                  if (image != null) {
                                    final bytes = await image.readAsBytes();
                                    setStateModal(() {
                                      selectedImageBytes = bytes;
                                      selectedImageName = image.name;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.photo_camera_rounded, size: 18),
                                label: const Text('Pilih Foto'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white, elevation: 0),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  selectedImageName.isNotEmpty 
                                    ? 'Dipilih: $selectedImageName' 
                                    : (existingFotoSesudah.isNotEmpty ? '✓ Bukti foto sudah tersimpan' : 'Pilih foto hasil pengerjaan'),
                                  style: TextStyle(fontSize: 12, color: selectedImageName.isNotEmpty || existingFotoSesudah.isNotEmpty ? const Color(0xFF10B981) : Colors.grey.shade600, fontWeight: FontWeight.bold),
                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],

                      if (isUploading) ...[
                        const SizedBox(height: 24),
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 8),
                        const Center(child: Text('Menyimpan status & mengunggah foto...', style: TextStyle(color: Colors.grey, fontSize: 12))),
                      ]
                    ]
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: isUploading ? null : () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003F87), foregroundColor: Colors.white),
                  onPressed: isUploading ? null : () async {
                    
                    if (tempStatus == 'Selesai' && existingFotoSesudah.isEmpty && selectedImageBytes == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mohon unggah Foto Bukti Perbaikan terlebih dahulu!'), backgroundColor: Colors.red)
                      );
                      return; 
                    }

                    setStateModal(() => isUploading = true); 

                    try {
                      Map<String, dynamic> updateData = {'status': tempStatus};
                      
                      if (tempStatus == 'Selesai') {
                        if (selectedImageBytes != null) {
                          updateData['foto_sesudah'] = base64Encode(selectedImageBytes!); 
                        } else {
                          updateData['foto_sesudah'] = existingFotoSesudah;
                        }
                      }

                      await _laporanCollection.doc(doc.id).update(updateData);
                      
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        _showSuccessSnackbar('Status laporan dan Bukti berhasil diperbarui!');
                      }
                    } catch (e) {
                      setStateModal(() => isUploading = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
                      }
                    }
                  },
                  child: const Text('Simpan Status')
                )
              ]
            );
          }
        );
      }
    );
  }

  // =========================================================================
  // FUNGSI INPUT TEXT MODERN
  // =========================================================================
  Widget _buildModernTextField(TextEditingController controller, String label, {TextInputType type = TextInputType.text, String? prefix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefix,
          filled: true,
          fillColor: const Color(0xFFF4F7FC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF003F87), width: 1.5)),
          labelStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  // =========================================================================
  // PEMANGGIL DIALOG POP-UP (SUDAH DIPERBAIKI LOGIKA NULL CHECK-NYA)
  // =========================================================================
  void _showUMKMDialog([DocumentSnapshot? doc]) {
    if (doc != null) { 
      final data = doc.data() as Map<String, dynamic>; 
      _namaUmkmCtrl.text = data['nama'] ?? ''; 
      _bidangUmkmCtrl.text = data['bidang'] ?? ''; 
      _omzetUmkmCtrl.text = data['omzet']?.toString() ?? ''; 
      _produkCtrl.text = data['produk'] ?? '';
      _stokCtrl.text = data['stok']?.toString() ?? '0';
    } else { 
      _namaUmkmCtrl.clear(); _bidangUmkmCtrl.clear(); _omzetUmkmCtrl.clear(); _produkCtrl.clear(); _stokCtrl.clear(); 
    }
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 450, padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc != null ? 'Edit Data UMKM' : 'Tambah UMKM Baru', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
                const SizedBox(height: 24),
                _buildModernTextField(_namaUmkmCtrl, 'Nama Usaha'), 
                _buildModernTextField(_bidangUmkmCtrl, 'Kategori (Misal: Kuliner, Kriya)'), 
                _buildModernTextField(_produkCtrl, 'Produk Unggulan (Misal: Randang)'),
                Row(
                  children: [
                    Expanded(child: _buildModernTextField(_stokCtrl, 'Sisa Stok (Pcs)', type: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildModernTextField(_omzetUmkmCtrl, 'Omzet/Bulan', type: TextInputType.number, prefix: 'Rp ')),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003F87), foregroundColor: Colors.white),
                      onPressed: () async {
                        final data = {'nama': _namaUmkmCtrl.text, 'bidang': _bidangUmkmCtrl.text, 'produk': _produkCtrl.text, 'stok': int.tryParse(_stokCtrl.text) ?? 0, 'omzet': _omzetUmkmCtrl.text};
                        if (doc != null) {
                          await _umkmCollection.doc(doc.id).update(data);
                        } else {
                          await _umkmCollection.add(data);
                        }
                        if (context.mounted) { Navigator.pop(context); _showSuccessSnackbar('Data berhasil disimpan!'); }
                      },
                      child: const Text('Simpan Data')
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      )
    );
  }

  void _showPendidikanDialog([DocumentSnapshot? doc]) {
    Uint8List? selectedImageBytes;
    String selectedImageName = '';
    String existingPhotoData = '';
    bool isUploading = false; 

    if (doc != null) { 
      final data = doc.data() as Map<String, dynamic>;
      _namaSekolahCtrl.text = data['nama_sekolah'] ?? ''; 
      _jenjangCtrl.text = data['jenjang'] ?? ''; 
      _jumlahSiswaCtrl.text = data['jumlah_siswa']?.toString() ?? ''; 
      _statusCtrl.text = data['status'] ?? ''; 
      _akreditasiCtrl.text = data['akreditasi'] ?? ''; 
      _alamatCtrl.text = data['alamat'] ?? ''; 
      _latitudeCtrl.text = data['latitude']?.toString() ?? ''; 
      _longitudeCtrl.text = data['longitude']?.toString() ?? ''; 
      existingPhotoData = data['foto_profil'] ?? ''; 
    } else { 
      _namaSekolahCtrl.clear(); _jenjangCtrl.clear(); _jumlahSiswaCtrl.clear(); 
      _statusCtrl.clear(); _akreditasiCtrl.clear(); _alamatCtrl.clear(); _latitudeCtrl.clear(); _longitudeCtrl.clear();
    }
    
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(doc != null ? 'Edit Sekolah' : 'Tambah Sekolah Baru', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Silakan lengkapi data di bawah ini.', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      _buildModernTextField(_namaSekolahCtrl, 'Nama Sekolah (Cth: SMA NEGERI 2 PAYAKUMBUH)'), 
                      Row(
                        children: [
                          Expanded(child: _buildModernTextField(_jenjangCtrl, 'Jenjang (SD/SMP/SMA/SMK)')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildModernTextField(_statusCtrl, 'Status (Negeri/Swasta)')),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildModernTextField(_akreditasiCtrl, 'Akreditasi (A/B/C/Belum)')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildModernTextField(_jumlahSiswaCtrl, 'Jumlah Siswa Aktif', type: TextInputType.number)),
                        ],
                      ),
                      _buildModernTextField(_alamatCtrl, 'Alamat Lengkap'),
                      Row(
                        children: [
                          Expanded(child: _buildModernTextField(_latitudeCtrl, 'Latitude (Cth: -0.2280)', type: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildModernTextField(_longitudeCtrl, 'Longitude (Cth: 100.6350)', type: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      const Text('Foto Profil Sekolah (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 30,
                                  maxWidth: 800,
                                  maxHeight: 800,
                                );
                                
                                if (image != null) {
                                  final bytes = await image.readAsBytes();
                                  setDialogState(() {
                                    selectedImageBytes = bytes;
                                    selectedImageName = image.name;
                                  });
                                }
                              },
                              icon: const Icon(Icons.photo_library_rounded, size: 18),
                              label: const Text('Pilih Foto'),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003F87), foregroundColor: Colors.white, elevation: 0),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                selectedImageName.isNotEmpty 
                                  ? 'Dipilih: $selectedImageName' 
                                  : (existingPhotoData.isNotEmpty ? '✓ Foto sudah ada di database' : 'Belum ada foto yang dipilih'),
                                style: TextStyle(fontSize: 12, color: selectedImageName.isNotEmpty || existingPhotoData.isNotEmpty ? const Color(0xFF10B981) : Colors.grey.shade600, fontWeight: FontWeight.bold),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                      
                      if (isUploading) ...[
                        const SizedBox(height: 24),
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 8),
                        const Center(child: Text('Sedang menyimpan dan memproses foto...', style: TextStyle(color: Colors.grey, fontSize: 12))),
                      ]
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUploading ? null : () => Navigator.pop(context), 
                  child: const Text('Batal', style: TextStyle(color: Colors.grey))
                ),
                ElevatedButton(
                  onPressed: isUploading ? null : () async {
                    setDialogState(() => isUploading = true); 
                    
                    String finalPhotoData = existingPhotoData;

                    try {
                      if (selectedImageBytes != null) {
                        finalPhotoData = base64Encode(selectedImageBytes!);
                      }

                      final data = {
                        'nama_sekolah': _namaSekolahCtrl.text, 
                        'jenjang': _jenjangCtrl.text, 
                        'jumlah_siswa': int.tryParse(_jumlahSiswaCtrl.text) ?? 0,
                        'status': _statusCtrl.text,
                        'akreditasi': _akreditasiCtrl.text,
                        'alamat': _alamatCtrl.text,
                        'latitude': double.tryParse(_latitudeCtrl.text) ?? 0.0,
                        'longitude': double.tryParse(_longitudeCtrl.text) ?? 0.0,
                        'foto_profil': finalPhotoData, 
                      };
                      
                      if (doc != null) {
                         await _pendidikanCollection.doc(doc.id).update(data);
                      } else {
                         await _pendidikanCollection.add(data);
                      }
                      
                      if (context.mounted) {
                        Navigator.pop(context); 
                        _showSuccessSnackbar('Data Sekolah Berhasil Disimpan!');
                      } 
                    } catch (e) {
                      setDialogState(() => isUploading = false); 
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003F87), foregroundColor: Colors.white),
                  child: const Text('Simpan Data'),
                )
              ],
            );
          }
        );
      }
    );
  }

  void _showKesehatanDialog([DocumentSnapshot? doc]) {
    if (doc != null) { 
      final data = doc.data() as Map<String, dynamic>;
      _namaFaskesCtrl.text = data['nama_faskes'] ?? ''; 
      _jenisFaskesCtrl.text = data['jenis'] ?? ''; 
      _layananFaskesCtrl.text = data['layanan'] ?? ''; 
    } else { 
      _namaFaskesCtrl.clear(); _jenisFaskesCtrl.clear(); _layananFaskesCtrl.clear(); 
    }
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 450, padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc != null ? 'Edit Faskes' : 'Tambah Fasilitas Kesehatan', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
                const SizedBox(height: 24),
                _buildModernTextField(_namaFaskesCtrl, 'Nama Fasilitas (Misal: RSUD)'), 
                _buildModernTextField(_jenisFaskesCtrl, 'Jenis (RS/Puskesmas/Klinik)'), 
                _buildModernTextField(_layananFaskesCtrl, 'Status Layanan (Misal: 24 Jam)'),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003F87), foregroundColor: Colors.white),
                      onPressed: () async {
                        final data = {'nama_faskes': _namaFaskesCtrl.text, 'jenis': _jenisFaskesCtrl.text, 'layanan': _layananFaskesCtrl.text};
                        if (doc != null) {
                          await _kesehatanCollection.doc(doc.id).update(data);
                        } else {
                          await _kesehatanCollection.add(data);
                        }
                        if (context.mounted) { Navigator.pop(context); _showSuccessSnackbar('Data berhasil disimpan!'); }
                      },
                      child: const Text('Simpan Data')
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      )
    );
  }

  void _showKependudukanDialog([DocumentSnapshot? doc]) {
    if (doc != null) { 
      final data = doc.data() as Map<String, dynamic>;
      _kecamatanCtrl.text = data['kecamatan'] ?? ''; 
      _populasiCtrl.text = data['populasi']?.toString() ?? ''; 
      _kepadatanCtrl.text = data['kepadatan'] ?? ''; 
    } else { 
      _kecamatanCtrl.clear(); _populasiCtrl.clear(); _kepadatanCtrl.clear(); 
    }
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 450, padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc != null ? 'Edit Data Kecamatan' : 'Tambah Data Penduduk', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
                const SizedBox(height: 24),
                _buildModernTextField(_kecamatanCtrl, 'Nama Kecamatan'), 
                _buildModernTextField(_populasiCtrl, 'Total Populasi', type: TextInputType.number), 
                _buildModernTextField(_kepadatanCtrl, 'Kepadatan (Jiwa/km²)'),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003F87), foregroundColor: Colors.white),
                      onPressed: () async {
                         final data = {'kecamatan': _kecamatanCtrl.text, 'populasi': _populasiCtrl.text, 'kepadatan': _kepadatanCtrl.text};
                         if (doc != null) {
                           await _kependudukanCollection.doc(doc.id).update(data);
                         } else {
                           await _kependudukanCollection.add(data);
                         }
                         if (context.mounted) { Navigator.pop(context); _showSuccessSnackbar('Data berhasil disimpan!'); }
                      },
                      child: const Text('Simpan Data')
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      )
    );
  }

  void _showPariwisataDialog([DocumentSnapshot? doc]) {
    if (doc != null) { 
      final data = doc.data() as Map<String, dynamic>;
      _namaDestinasiCtrl.text = data['nama_destinasi'] ?? ''; 
      _kategoriWisataCtrl.text = data['kategori'] ?? ''; 
      _lokasiWisataCtrl.text = data['lokasi'] ?? ''; 
      _deskripsiWisataCtrl.text = data['deskripsi'] ?? ''; 
      _hargaWisataCtrl.text = data['harga_tiket']?.toString() ?? ''; 
      _latWisataCtrl.text = data['latitude']?.toString() ?? ''; 
      _lngWisataCtrl.text = data['longitude']?.toString() ?? ''; 
    } else { 
      _namaDestinasiCtrl.clear(); _kategoriWisataCtrl.clear(); _lokasiWisataCtrl.clear(); 
      _deskripsiWisataCtrl.clear(); _hargaWisataCtrl.clear(); _latWisataCtrl.clear(); _lngWisataCtrl.clear(); 
    }
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 450, padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc != null ? 'Edit Destinasi' : 'Tambah Destinasi Wisata', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
                const SizedBox(height: 24),
                _buildModernTextField(_namaDestinasiCtrl, 'Nama Destinasi (Cth: Ngalau Indah)'), 
                Row(
                  children: [
                    Expanded(child: _buildModernTextField(_kategoriWisataCtrl, 'Kategori (Wisata Alam, dll)')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildModernTextField(_hargaWisataCtrl, 'Harga Tiket (Rp)', type: TextInputType.number)),
                  ],
                ),
                _buildModernTextField(_lokasiWisataCtrl, 'Alamat / Lokasi'),
                _buildModernTextField(_deskripsiWisataCtrl, 'Deskripsi Singkat', type: TextInputType.multiline),
                Row(
                  children: [
                    Expanded(child: _buildModernTextField(_latWisataCtrl, 'Latitude (Cth: -0.2280)', type: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildModernTextField(_lngWisataCtrl, 'Longitude (Cth: 100.6350)', type: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003F87), foregroundColor: Colors.white),
                      onPressed: () async {
                        final data = {
                          'nama_destinasi': _namaDestinasiCtrl.text, 
                          'kategori': _kategoriWisataCtrl.text, 
                          'lokasi': _lokasiWisataCtrl.text,
                          'deskripsi': _deskripsiWisataCtrl.text,
                          'harga_tiket': _hargaWisataCtrl.text,
                          'latitude': double.tryParse(_latWisataCtrl.text) ?? 0.0,
                          'longitude': double.tryParse(_lngWisataCtrl.text) ?? 0.0,
                        };
                        if (doc != null) {
                          await _pariwisataCollection.doc(doc.id).update(data);
                        } else {
                          await _pariwisataCollection.add(data);
                        }
                        if (context.mounted) { Navigator.pop(context); _showSuccessSnackbar('Data berhasil disimpan!'); }
                      },
                      child: const Text('Simpan Data')
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      )
    );
  }

  // =========================================================================
  // TAMPILAN UTAMA
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: Row(
        children: [
          // SIDEBAR MODERN
          Container(
            width: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF003F87), Color(0xFF00224D)]),
            ),
            child: Column(
              children: [
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.admin_panel_settings_rounded, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text('COMMAND CENTER', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                Text('Admin Payakumbuh', style: TextStyle(color: Colors.blue.shade200, fontSize: 13)),
                const SizedBox(height: 48),

                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildSidebarMenu(Icons.campaign_rounded, 'Laporan Warga (LAPOR)'),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white24)),
                      _buildSidebarMenu(Icons.storefront_rounded, 'Kelola UMKM'),
                      _buildSidebarMenu(Icons.school_rounded, 'Pendidikan'),
                      _buildSidebarMenu(Icons.favorite_rounded, 'Kesehatan'),
                      _buildSidebarMenu(Icons.groups_rounded, 'Kependudukan'),
                      _buildSidebarMenu(Icons.landscape_rounded, 'Pariwisata'),
                    ],
                  ),
                ),

                const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Divider(color: Colors.white24, height: 1)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: const Icon(Icons.logout_rounded, color: Color(0xFFFFA3A3)),
                    title: const Text('Keluar Sistem', style: TextStyle(color: Color(0xFFFFA3A3), fontWeight: FontWeight.w600)),
                    hoverColor: Colors.red.withValues(alpha: 0.1),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),

          // KONTEN KANAN DENGAN ANIMATED SWITCHER
          Expanded(
            child: Column(
              children: [
                // Header Modern Atas
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selamat datang kembali, Admin!', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          const Text('Dashboard Manajemen Data', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
                        ],
                      ),
                      Row(
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: _laporanCollection.where('status', isEqualTo: 'Menunggu Verifikasi').snapshots(),
                            builder: (context, snapshot) {
                              int unreadCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                              return InkWell(
                                onTap: _showNotificationDialog,
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(12)),
                                      child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF0B1C30)),
                                    ),
                                    if (unreadCount > 0)
                                      Positioned(
                                        right: -2, top: -2,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                          child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      )
                                  ],
                                ),
                              );
                            }
                          ),
                          const SizedBox(width: 16),
                          const CircleAvatar(radius: 20, backgroundColor: Color(0xFF003F87), child: Icon(Icons.person, color: Colors.white)),
                        ],
                      )
                    ],
                  ),
                ),

                // Area Tabel dengan Animasi Transisi Halus
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0.0, 0.05), end: Offset.zero).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<String>(_activeMenu),
                        child: _buildMainContent(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSidebarMenu(IconData icon, String title) {
    bool isActive = _activeMenu == title;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isActive ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
        leading: Icon(icon, color: isActive ? Colors.white : Colors.white60),
        title: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.white60, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
        hoverColor: Colors.white.withValues(alpha: 0.05),
        onTap: () => setState(() => _activeMenu = title),
      ),
    );
  }

  // =========================================================================
  // PENENTU KONTEN BERDASARKAN MENU
  // =========================================================================
  Widget _buildMainContent() {
    switch (_activeMenu) {
      case 'Laporan Warga (LAPOR)':
        return _buildModernTable(
          title: 'Rekapitulasi Laporan Warga', 
          collectionQuery: _laporanCollection.orderBy('waktu', descending: true), 
          columns: const ['TANGGAL', 'KATEGORI', 'JUDUL LAPORAN', 'STATUS', 'BUKTI AWAL', 'AKSI'],
          buildRow: (doc) {
            final data = doc.data() as Map<String, dynamic>; 
            String status = data['status'] ?? 'Menunggu Verifikasi';
            Color statusColor = status == 'Selesai' ? Colors.green : (status == 'Sedang Diproses' ? Colors.orange : Colors.red);
            String tgl = data['waktu'] != null ? (data['waktu'] as Timestamp).toDate().toString().substring(0, 16) : '-';

            return [
              DataCell(Text(tgl, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(_buildModernBadge(data['kategori'] ?? '-', Colors.blue)),
              DataCell(
                SizedBox(
                  width: 250, 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(data['judul'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(data['deskripsi'] ?? '-', style: TextStyle(color: Colors.grey.shade600, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
              DataCell(_buildModernBadgeColor(status, statusColor)), 
              DataCell(
                data['image_base64'] != null && (data['image_base64'] as String).isNotEmpty
                  ? InkWell(
                      onTap: () => _showImagePreview(data['image_base64']),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.memory(base64Decode(data['image_base64']), width: 50, height: 40, fit: BoxFit.cover),
                      ),
                    )
                  : const Text('Tidak Ada Foto', style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic))
              ),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(Icons.edit_rounded, color: Colors.blue.shade600, size: 18), 
                      tooltip: 'Update Status & Upload Bukti Selesai', 
                      onPressed: () => _showUpdateStatusLapor(doc)
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(Icons.delete_rounded, color: Colors.red.shade600, size: 18), 
                      tooltip: 'Hapus Laporan', 
                      onPressed: () => _confirmDelete(doc, _laporanCollection)
                    ),
                  ),
                ],
              ))
            ];
          },
        );
      case 'Kelola UMKM':
        return _buildModernTable(
          title: 'Manajemen Inventaris & UMKM', 
          buttonText: 'Tambah Data UMKM', 
          onAddPressed: () => _showUMKMDialog(), 
          collectionQuery: _umkmCollection,
          columns: const ['NAMA USAHA', 'PRODUK & STOK', 'OMZET', 'AKSI'],
          buildRow: (doc) {
            final data = doc.data() as Map<String, dynamic>; 
            
            int stok = data['stok'] ?? 0;
            Color stokColor = stok > 50 ? Colors.green : (stok > 10 ? Colors.orange.shade700 : Colors.red);
            String stokStatus = stok > 50 ? 'Aman' : (stok > 10 ? 'Menipis' : 'Kritis');

            return [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(data['nama'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    _buildModernBadge(data['bidang'] ?? '-', Colors.blue),
                  ],
                )
              ),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(data['produk'] ?? 'Belum ada data', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Sisa: $stok Pcs ($stokStatus)', style: TextStyle(color: stokColor, fontSize: 11, fontWeight: FontWeight.w900)),
                  ],
                )
              ),
              DataCell(Text('Rp ${data['omzet'] ?? '0'}', style: const TextStyle(fontWeight: FontWeight.w600))), 
              _buildActionButtons(doc, _showUMKMDialog, _umkmCollection)
            ];
          },
        );
      case 'Pendidikan':
        return _buildModernTable(
          title: 'Data Sektor Pendidikan', buttonText: 'Tambah Sekolah', onAddPressed: () => _showPendidikanDialog(), collectionQuery: _pendidikanCollection,
          columns: const ['NAMA SEKOLAH', 'JENJANG', 'JUMLAH SISWA', 'AKSI'],
          buildRow: (doc) {
            final data = doc.data() as Map<String, dynamic>;
            return [DataCell(Text(data['nama_sekolah'] ?? '-')), DataCell(_buildModernBadge(data['jenjang'] ?? '-', Colors.blue)), DataCell(Text('${data['jumlah_siswa'] ?? '0'} Siswa', style: const TextStyle(fontWeight: FontWeight.w600))), _buildActionButtons(doc, _showPendidikanDialog, _pendidikanCollection)];
          }
        );
      case 'Kesehatan':
        return _buildModernTable(
          title: 'Data Fasilitas Kesehatan', buttonText: 'Tambah Faskes', onAddPressed: () => _showKesehatanDialog(), collectionQuery: _kesehatanCollection,
          columns: const ['NAMA FASILITAS', 'JENIS', 'LAYANAN', 'AKSI'],
          buildRow: (doc) {
            final data = doc.data() as Map<String, dynamic>;
            return [DataCell(Text(data['nama_faskes'] ?? '-')), DataCell(_buildModernBadge(data['jenis'] ?? '-', Colors.red)), DataCell(Text(data['layanan'] ?? '-')), _buildActionButtons(doc, _showKesehatanDialog, _kesehatanCollection)];
          }
        );
      case 'Kependudukan':
        return _buildModernTable(
          title: 'Demografi & Kependudukan', buttonText: 'Tambah Data', onAddPressed: () => _showKependudukanDialog(), collectionQuery: _kependudukanCollection,
          columns: const ['KECAMATAN', 'TOTAL POPULASI', 'KEPADATAN', 'AKSI'],
          buildRow: (doc) {
            final data = doc.data() as Map<String, dynamic>;
            return [DataCell(Text(data['kecamatan'] ?? '-')), DataCell(Text('${data['populasi'] ?? '0'} Jiwa', style: const TextStyle(fontWeight: FontWeight.w600))), DataCell(_buildModernBadge('${data['kepadatan'] ?? '-'} Jiwa/km²', Colors.teal)), _buildActionButtons(doc, _showKependudukanDialog, _kependudukanCollection)];
          }
        );
      case 'Pariwisata':
        return _buildModernTable(
          title: 'Data Destinasi Wisata', buttonText: 'Tambah Destinasi', onAddPressed: () => _showPariwisataDialog(), collectionQuery: _pariwisataCollection,
          columns: const ['NAMA DESTINASI', 'KATEGORI', 'LOKASI', 'AKSI'],
          buildRow: (doc) {
            final data = doc.data() as Map<String, dynamic>;
            return [DataCell(Text(data['nama_destinasi'] ?? '-')), DataCell(_buildModernBadge(data['kategori'] ?? '-', Colors.green)), DataCell(Text(data['lokasi'] ?? '-')), _buildActionButtons(doc, _showPariwisataDialog, _pariwisataCollection)];
          }
        );
      default: return const Center(child: Text('Modul tidak ditemukan.'));
    }
  }

  // =========================================================================
  // TEMPLATE TABEL MODERN INTERAKTIF
  // =========================================================================
  Widget _buildModernTable({
    required String title, 
    String? buttonText, 
    VoidCallback? onAddPressed, 
    required Query collectionQuery, 
    required List<String> columns, 
    required List<DataCell> Function(DocumentSnapshot) buildRow,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))),
            Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: const Text('Unduh CSV'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    side: BorderSide(color: Colors.green.shade700, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _unduhCSV(title, columns),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.print_rounded, size: 20),
                  label: const Text('Cetak PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF003F87),
                    side: const BorderSide(color: Color(0xFF003F87), width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _cetakLaporanPDF(title, columns),
                ),
                
                if (buttonText != null && onAddPressed != null) ...[
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: Text(buttonText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003F87),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      shadowColor: const Color(0xFF003F87).withValues(alpha: 0.3),
                    ),
                    onPressed: onAddPressed,
                  ),
                ]
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: StreamBuilder(
                stream: collectionQuery.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('Belum ada data di database.', style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(), 
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal, 
                          physics: const BouncingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FF)),
                              dividerThickness: 1,
                              dataRowMaxHeight: 75,
                              dataRowMinHeight: 65,
                              showBottomBorder: true,
                              dataRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                if (states.contains(WidgetState.hovered)) return Colors.blue.withValues(alpha: 0.04);
                                return null; 
                              }),
                              columnSpacing: 24, 
                              columns: columns.map((col) => DataColumn(label: Text(col, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF565F69), fontSize: 12, letterSpacing: 0.5)))).toList(),
                              rows: snapshot.data!.docs.map((doc) => DataRow(cells: buildRow(doc))).toList(),
                            ),
                          ),
                        ),
                      );
                    }
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernBadge(String text, MaterialColor baseColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: baseColor.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: baseColor.shade200)),
      child: Text(text, style: TextStyle(color: baseColor.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildModernBadgeColor(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  DataCell _buildActionButtons(DocumentSnapshot doc, Function(DocumentSnapshot) onEdit, CollectionReference collection) {
    return DataCell(Row(
      mainAxisSize: MainAxisSize.min, 
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
          child: IconButton(
            icon: Icon(Icons.edit_rounded, color: Colors.blue.shade600, size: 18), 
            tooltip: 'Edit Data', 
            hoverColor: Colors.blue.shade100,
            onPressed: () => onEdit(doc)
          ),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
          child: IconButton(
            icon: Icon(Icons.delete_rounded, color: Colors.red.shade600, size: 18), 
            tooltip: 'Hapus Data', 
            hoverColor: Colors.red.shade100,
            onPressed: () => _confirmDelete(doc, collection)
          ),
        ),
      ],
    ));
  }
}