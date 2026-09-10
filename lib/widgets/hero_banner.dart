import 'package:flutter/material.dart';

class HeroBanner extends StatefulWidget {
  final bool isWideScreen;
  final ValueChanged<String>? onSearch;

  const HeroBanner({
    super.key,
    required this.isWideScreen,
    this.onSearch,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  // Menambahkan pengontrol untuk membaca teks yang diketik pengguna
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose(); // Membersihkan memori saat widget dihapus
    super.dispose();
  }

  // Fungsi untuk memicu pencarian
  void _submitSearch() {
    if (widget.onSearch != null) {
      widget.onSearch!(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: _buildTextContent(context),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 6,
            child: _buildIllustrationCard(),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildTextContent(context),
        const SizedBox(height: 24),
        _buildIllustrationCard(),
      ],
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hadirkan Visualisasi Data Payakumbuh Dalam Satu Kanal',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Akses informasi terkini mengenai kependudukan, ekonomi, pendidikan, dan sektor penting lainnya di Kota Payakumbuh.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue.shade100,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          constraints: const BoxConstraints(maxWidth: 440),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.search, color: Color(0xFF727784)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController, // Menyambungkan pengontrol ke TextField
                  onSubmitted: (_) => _submitSearch(), // Bereaksi saat tombol 'Enter' ditekan
                  decoration: const InputDecoration(
                    hintText: 'Cari data atau dashboard...',
                    hintStyle: TextStyle(fontSize: 14, color: Color(0xFF727784)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _submitSearch, // Bereaksi saat tombol 'Cari' diklik
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003F87),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Cari', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIllustrationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: const Color(0xFFE5EEFF),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAJRyjvZEdGy8uhS-AVbJ-m9yeG3eUleYDzTvX7X3nOFsdJXkrPfp09nw7Z99ADyQR--RP0Kh6sSgASaf3TFzjpkfESqYuXWxRYL_jCOQ_XnTN1DldaNCZUfTEbx8hEkcAKf1VGC1FsBAGCOoJ7hY5cBOtFSqNNkjDX1PkBM9EBGg8h4rwtK0hxqSNZ0ur8VsphLH-gZt8A9kdPgku4fH_fZr_OESqNibAYGm3QJ7HoIjiQKljVum6Y',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF003F87),
                      child: const Center(
                        child: Icon(Icons.analytics_rounded, size: 80, color: Colors.white70),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}