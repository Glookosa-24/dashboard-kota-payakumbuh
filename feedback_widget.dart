import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ==========================================
// 1. WIDGET TOMBOL MELAYANG (SIDE BUTTON)
// ==========================================
class FeedbackSideButton extends StatelessWidget {
  const FeedbackSideButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      top: MediaQuery.of(context).size.height * 0.45,
      child: GestureDetector(
        onTap: () {
          showDialog(context: context, builder: (context) => const FeedbackDialogWidget());
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0056B3),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(-2, 0))]
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          child: const RotatedBox(
            quarterTurns: 3, 
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.feedback_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Feedback', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. DIALOG POP-UP FEEDBACK UTAMA (BERSIH)
// ==========================================
class FeedbackDialogWidget extends StatefulWidget {
  const FeedbackDialogWidget({super.key});

  @override
  State<FeedbackDialogWidget> createState() => _FeedbackDialogWidgetState();
}

class _FeedbackDialogWidgetState extends State<FeedbackDialogWidget> {
  int? _indeksKepuasan; 
  final List<String> _topikTerpilih = [];
  final TextEditingController _ceritaController = TextEditingController();
  bool isSubmitting = false;

  final List<String> _daftarEmoji = ['😡', '🙁', '😐', '😊', '😍'];
  final List<String> _daftarTopik = [
    'Pemerintahan', 'Pariwisata', 'Pendidikan', 'Kesehatan', 
    'Infrastruktur', 'Kependudukan', 'Industri & UMKM', 'Keuangan'
  ];

  void _toggleTopik(String topik) {
    setState(() {
      if (_topikTerpilih.contains(topik)) {
        _topikTerpilih.remove(topik);
      } else {
        _topikTerpilih.add(topik);
      }
    });
  }

  // Fungsi Pengiriman ke Firebase (Tanpa Foto)
  Future<void> _kirimFeedbackKeFirebase() async {
    if (_indeksKepuasan == null || _ceritaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih emoji dan isi pengalaman Anda terlebih dahulu!')));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // Simpan ke koleksi khusus feedback app
      await FirebaseFirestore.instance.collection('pesan_masuk_app').add({
        'rating': _indeksKepuasan,
        'topik': _topikTerpilih,
        'pesan': _ceritaController.text,
        'waktu': FieldValue.serverTimestamp(),
        'dibaca': false,
      });

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Terima kasih! Feedback Anda sangat berharga.', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
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
    _ceritaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        width: 550, 
        padding: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFFEFF4FF), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.dashboard_customize_rounded, color: Color(0xFF003F87)),
                        ),
                        const SizedBox(width: 12),
                        const Text('DASHBOARD\nPAYAKUMBUH', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, height: 1.1, color: Color(0xFF0B1C30))),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context), splashRadius: 24)
                  ],
                ),
              ),
              const Divider(height: 1),

              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('Seberapa puaskah Anda dengan Dashboard ini?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                        Text(' *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_daftarEmoji.length, (index) {
                        bool isSelected = _indeksKepuasan == index;
                        return InkWell(
                          onTap: () => setState(() => _indeksKepuasan = index),
                          borderRadius: BorderRadius.circular(40),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? const Color(0xFFFFFBEB) : Colors.transparent,
                              border: Border.all(color: isSelected ? const Color(0xFFF59E0B) : Colors.transparent, width: 2),
                            ),
                            child: Text(
                              _daftarEmoji[index],
                              style: TextStyle(fontSize: 48, color: _indeksKepuasan == null || isSelected ? Colors.black : Colors.black.withValues(alpha: 0.3)),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 40),

                    const Text('Topik Apa yang dirasa bermanfaat?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _daftarTopik.map((topik) {
                        bool isSelected = _topikTerpilih.contains(topik);
                        return InkWell(
                          onTap: () => _toggleTopik(topik),
                          borderRadius: BorderRadius.circular(24),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFEFF4FF) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: isSelected ? const Color(0xFF0056B3) : Colors.grey.shade300),
                            ),
                            child: Text(topik, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFF0056B3) : Colors.grey.shade700)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),

                    const Row(
                      children: [
                        Text('Ceritakan Pengalaman Anda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                        Text(' *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ceritaController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan pengalaman atau saran Anda untuk perbaikan aplikasi ini...',
                        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0056B3), width: 2)),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_indeksKepuasan == null || isSubmitting) ? null : _kirimFeedbackKeFirebase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0056B3),
                          disabledBackgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.grey.shade500,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Kirim Penilaian', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
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