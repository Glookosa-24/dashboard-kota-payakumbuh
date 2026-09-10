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

class AdminExecutiveDashboardPage extends StatefulWidget {
  const AdminExecutiveDashboardPage({super.key});

  @override
  State<AdminExecutiveDashboardPage> createState() => _AdminExecutiveDashboardPageState();
}

class _AdminExecutiveDashboardPageState extends State<AdminExecutiveDashboardPage> {
  final String _activeMenu = 'Data Realisasi APBD'; 

  final CollectionReference _apbdCollection = FirebaseFirestore.instance.collection('realisasi_apbd');
  
  final TextEditingController _namaOpdCtrl = TextEditingController();
  final TextEditingController _paguCtrl = TextEditingController();
  final TextEditingController _realisasiRpCtrl = TextEditingController();
  final TextEditingController _keuanganPctCtrl = TextEditingController();
  final TextEditingController _fisikPctCtrl = TextEditingController();
  
  String _kategoriPilihan = 'Dinas';
  String _tahunPilihan = 'Tahun 2024';
  String _triwulanPilihan = 'Triwulan II';
  
  final List<String> _kategoriList = const ['Dinas', 'Badan', 'Kecamatan', 'Sekretariat'];
  final List<String> _tahunList = const ['Tahun 2023', 'Tahun 2024', 'Tahun 2025', 'Tahun 2026'];
  final List<String> _triwulanList = const ['Triwulan I', 'Triwulan II', 'Triwulan III', 'Triwulan IV'];

  String _searchQuery = '';
  String _filterKategori = 'Semua';

  late Stream<QuerySnapshot> _apbdStream;

  @override
  void initState() {
    super.initState();
    _apbdStream = _apbdCollection.orderBy('waktu', descending: true).snapshots();
  }

  @override
  void dispose() {
    _namaOpdCtrl.dispose(); 
    _paguCtrl.dispose(); 
    _realisasiRpCtrl.dispose(); 
    _keuanganPctCtrl.dispose(); 
    _fisikPctCtrl.dispose();
    super.dispose();
  }

  // =========================================================================
  // FUNGSI EKSPOR EXCEL (CSV)
  // =========================================================================
  Future<void> _unduhCSV() async {
    final QuerySnapshot snapshot = await _apbdCollection.orderBy('waktu', descending: true).get();
    List<List<dynamic>> rows = [
      ['NAMA OPD', 'KATEGORI', 'TAHUN', 'TRIWULAN', 'PAGU ANGGARAN', 'REALISASI KEUANGAN (%)', 'REALISASI FISIK (%)']
    ];
    
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>; 
      rows.add([
        data['nama_opd'] ?? '-', 
        data['kategori'] ?? '-', 
        data['tahun'] ?? '-', 
        data['triwulan'] ?? '-', 
        data['pagu'] ?? '0', 
        '${data['keuangan_pct'] ?? 0}%', 
        '${data['fisik_pct'] ?? 0}%'
      ]);
    }
    
    String csvData = rows.map((row) => row.map((item) => '"${item.toString().replaceAll('"', '""')}"').join(',')).join('\n');
    await FileSaver.instance.saveFile(name: 'Data_Realisasi_APBD.csv', bytes: Uint8List.fromList(utf8.encode(csvData)));
    _showSuccessSnackbar('File Excel (CSV) berhasil diunduh!');
  }

  // =========================================================================
  // FUNGSI CETAK LAPORAN PDF
  // =========================================================================
  Future<void> _cetakLaporanPDF() async {
    final QuerySnapshot snapshot = await _apbdCollection.orderBy('waktu', descending: true).get();
    final pdf = pw.Document();
    
    List<List<String>> pdfData = [];
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>; 
      pdfData.add([
        data['nama_opd'] ?? '-', 
        '${data['tahun'] ?? '-'} (${data['triwulan'] ?? '-'})', 
        '${data['keuangan_pct'] ?? 0}%', 
        '${data['fisik_pct'] ?? 0}%'
      ]);
    }
    
    if (pdfData.isEmpty) pdfData.add(['Data Kosong', '-', '-', '-']);

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4, 
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) {
        return [
          pw.Text('PEMERINTAH KOTA PAYAKUMBUH', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text('LAPORAN REALISASI APBD OPD', style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['NAMA OPD', 'PERIODE', 'KEUANGAN (%)', 'FISIK (%)'], 
            data: pdfData,
            border: pw.TableBorder.all(color: PdfColors.grey400),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            cellStyle: const pw.TextStyle(fontSize: 10),
            oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
          )
        ];
      }
    ));
    
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save(), name: 'Laporan_APBD.pdf');
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  // =========================================================================
  // POP-UP FORM INPUT/EDIT DATA APBD
  // =========================================================================
  void _showAPBDDialog([DocumentSnapshot? doc]) {
    if (doc != null) { 
      final data = doc.data() as Map<String, dynamic>; 
      _namaOpdCtrl.text = data['nama_opd'] ?? ''; 
      _kategoriPilihan = data['kategori'] ?? 'Dinas'; 
      _tahunPilihan = data['tahun'] ?? 'Tahun 2024'; 
      _triwulanPilihan = data['triwulan'] ?? 'Triwulan II'; 
      _keuanganPctCtrl.text = data['keuangan_pct']?.toString() ?? ''; 
      _fisikPctCtrl.text = data['fisik_pct']?.toString() ?? '';
      _paguCtrl.text = data['pagu']?.toString() ?? '';
      _realisasiRpCtrl.text = data['realisasi_rp']?.toString() ?? '';
    } else { 
      _namaOpdCtrl.clear(); 
      _keuanganPctCtrl.clear(); 
      _fisikPctCtrl.clear(); 
      _paguCtrl.clear(); 
      _realisasiRpCtrl.clear(); 
      _kategoriPilihan = 'Dinas'; 
      _tahunPilihan = 'Tahun 2024'; 
      _triwulanPilihan = 'Triwulan II';
    }
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                width: 600, 
                padding: const EdgeInsets.all(32),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, 
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc != null ? 'Edit Kinerja OPD' : 'Input Kinerja OPD Baru', 
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0B1C30))
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _namaOpdCtrl, 
                        decoration: _inputDecoration('Nama Organisasi Perangkat Daerah (OPD)')
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildDropdownField('Kategori', _kategoriPilihan, _kategoriList, (val) => setDialogState(() => _kategoriPilihan = val))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDropdownField('Tahun', _tahunPilihan, _tahunList, (val) => setDialogState(() => _tahunPilihan = val))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDropdownField('Triwulan', _triwulanPilihan, _triwulanList, (val) => setDialogState(() => _triwulanPilihan = val))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _paguCtrl, keyboardType: TextInputType.number, decoration: _inputDecoration('Total Pagu Anggaran (Rp)'))),
                          const SizedBox(width: 16),
                          Expanded(child: TextField(controller: _realisasiRpCtrl, keyboardType: TextInputType.number, decoration: _inputDecoration('Realisasi Anggaran (Rp)'))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _keuanganPctCtrl, keyboardType: TextInputType.number, decoration: _inputDecoration('Realisasi Keuangan (%)'))),
                          const SizedBox(width: 16),
                          Expanded(child: TextField(controller: _fisikPctCtrl, keyboardType: TextInputType.number, decoration: _inputDecoration('Realisasi Fisik (%)'))),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003F87), 
                              foregroundColor: Colors.white, 
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                            ),
                            onPressed: () async {
                              final data = {
                                'nama_opd': _namaOpdCtrl.text, 
                                'kategori': _kategoriPilihan, 
                                'tahun': _tahunPilihan, 
                                'triwulan': _triwulanPilihan,
                                'keuangan_pct': double.tryParse(_keuanganPctCtrl.text) ?? 0.0, 
                                'fisik_pct': double.tryParse(_fisikPctCtrl.text) ?? 0.0,
                                'pagu': double.tryParse(_paguCtrl.text) ?? 0.0, 
                                'realisasi_rp': double.tryParse(_realisasiRpCtrl.text) ?? 0.0,
                                'waktu': FieldValue.serverTimestamp(),
                              };
                              if (doc != null) { 
                                await _apbdCollection.doc(doc.id).update(data); 
                              } else { 
                                await _apbdCollection.add(data); 
                              }
                              if (context.mounted) { 
                                Navigator.pop(context); 
                                _showSuccessSnackbar('Data Kinerja OPD berhasil disimpan!'); 
                              }
                            },
                            child: const Text('Simpan Data')
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint, 
      filled: true, 
      fillColor: const Color(0xFFF4F7FC), 
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), 
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF003F87), width: 1.5))
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value, 
              isExpanded: true,
              items: items.map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
              onChanged: (val) => onChanged(val!),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: Row(
        children: [
          Container(
            width: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, 
                end: Alignment.bottomCenter, 
                colors: [Color(0xFF0F172A), Color(0xFF020617)]
              )
            ),
            child: Column(
              children: [
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(16), 
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), shape: BoxShape.circle), 
                  child: const Icon(Icons.account_balance_rounded, size: 48, color: Colors.amber)
                ),
                const SizedBox(height: 16),
                const Text('EXECUTIVE ADMIN', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                Text('Pusat Kendali Data', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                const SizedBox(height: 48),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1), 
                          borderRadius: BorderRadius.circular(12), 
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.5))
                        ), 
                        child: ListTile(
                          leading: const Icon(Icons.analytics_rounded, color: Colors.amber), 
                          title: const Text('Data Realisasi APBD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
                          onTap: () {}
                        )
                      ),
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
                    onTap: () => Navigator.pop(context)
                  )
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24), 
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          Text('Selamat datang, Admin', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)), 
                          const SizedBox(height: 4), 
                          const Text('Kelola Data Executive Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))
                        ]
                      ),
                      const CircleAvatar(radius: 20, backgroundColor: Color(0xFF0F172A), child: Icon(Icons.person, color: Colors.amber)),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween, 
                          crossAxisAlignment: WrapCrossAlignment.center, 
                          spacing: 16, 
                          runSpacing: 16, 
                          children: [
                            const Text('Data Realisasi APBD per OPD', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            Wrap(
                              spacing: 12, 
                              runSpacing: 12,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.print_rounded, size: 20), 
                                  label: const Text('Cetak PDF'), 
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF0F172A), 
                                    side: const BorderSide(color: Color(0xFF0F172A), width: 1.5), 
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), 
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                  ), 
                                  onPressed: _cetakLaporanPDF
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.download_rounded, size: 20), 
                                  label: const Text('Unduh CSV'), 
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.green.shade700, 
                                    side: BorderSide(color: Colors.green.shade700, width: 1.5), 
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), 
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                  ), 
                                  onPressed: _unduhCSV
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.add_rounded, size: 20), 
                                  label: const Text('Input Data OPD'), 
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A), 
                                    foregroundColor: Colors.amber, 
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18), 
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                  ), 
                                  onPressed: () => _showAPBDDialog()
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              flex: 2, 
                              child: TextField(
                                onChanged: (val) => setState(() => _searchQuery = val), 
                                decoration: InputDecoration(
                                  hintText: 'Cari Nama OPD...', 
                                  prefixIcon: const Icon(Icons.search, color: Colors.grey), 
                                  filled: true, 
                                  fillColor: Colors.white, 
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                                )
                              )
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1, 
                              child: _buildAdminDropdown(
                                value: _filterKategori, 
                                items: ['Semua', ..._kategoriList], 
                                onChanged: (val) => setState(() => _filterKategori = val)
                              )
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
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4))
                              ]
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: StreamBuilder(
                                stream: _apbdStream,
                                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text('Belum ada data.', style: TextStyle(color: Colors.grey.shade500)));

                                  final filteredDocs = snapshot.data!.docs.where((doc) {
                                    final data = doc.data() as Map<String, dynamic>;
                                    final nama = (data['nama_opd'] ?? '').toString().toLowerCase();
                                    final kat = data['kategori'] ?? '';
                                    return nama.contains(_searchQuery.toLowerCase()) && (_filterKategori == 'Semua' || kat == _filterKategori);
                                  }).toList();

                                  if (filteredDocs.isEmpty) return const Center(child: Text('Data tidak ditemukan.', style: TextStyle(color: Colors.grey)));

                                  return LayoutBuilder(
                                    builder: (context, constraints) {
                                      return SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(), 
                                        scrollDirection: Axis.vertical,
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
                                              columnSpacing: 24, 
                                              columns: const [
                                                DataColumn(label: Text('NAMA OPD', style: TextStyle(fontWeight: FontWeight.bold))), 
                                                DataColumn(label: Text('PERIODE', style: TextStyle(fontWeight: FontWeight.bold))), 
                                                DataColumn(label: Text('KEUANGAN (%)', style: TextStyle(fontWeight: FontWeight.bold))), 
                                                DataColumn(label: Text('FISIK (%)', style: TextStyle(fontWeight: FontWeight.bold))), 
                                                DataColumn(label: Text('AKSI', style: TextStyle(fontWeight: FontWeight.bold)))
                                              ],
                                              rows: filteredDocs.map((doc) {
                                                final data = doc.data() as Map<String, dynamic>; 
                                                double keu = double.tryParse(data['keuangan_pct']?.toString() ?? '0') ?? 0;
                                                double fisik = double.tryParse(data['fisik_pct']?.toString() ?? '0') ?? 0;
                                                String periode = '${data['tahun'] ?? '-'} \n(${data['triwulan'] ?? '-'})';
                                                
                                                return DataRow(cells: [
                                                  DataCell(Text(data['nama_opd'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                                                  DataCell(Text(periode, style: const TextStyle(fontSize: 11, color: Colors.grey))),
                                                  DataCell(Text('$keu %', style: const TextStyle(fontWeight: FontWeight.bold))), 
                                                  DataCell(Text('$fisik %', style: const TextStyle(fontWeight: FontWeight.bold))), 
                                                  DataCell(Row(
                                                    mainAxisSize: MainAxisSize.min, 
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(Icons.edit_rounded, color: Colors.blue.shade600, size: 18), 
                                                        onPressed: () => _showAPBDDialog(doc)
                                                      ), 
                                                      IconButton(
                                                        icon: Icon(Icons.delete_rounded, color: Colors.red.shade600, size: 18), 
                                                        onPressed: () async { 
                                                          await _apbdCollection.doc(doc.id).delete(); 
                                                        }
                                                      )
                                                    ]
                                                  ))
                                                ]);
                                              }).toList(),
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

  Widget _buildAdminDropdown({required String value, required List<String> items, required Function(String) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, 
          isExpanded: true,
          items: items.map((val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
          onChanged: (val) => onChanged(val!),
        ),
      ),
    );
  }
}