import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  final bool isWideScreen;

  const FooterSection({super.key, required this.isWideScreen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF213145),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: isWideScreen ? 4 : 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_balance_rounded, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Pemkot Payakumbuh',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pusat Informasi dan Data Pemerintahan Kota Payakumbuh, Sumatera Barat.',
                      style: TextStyle(color: Colors.blue.shade100, fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
              if (isWideScreen) ...[
                const SizedBox(width: 32),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tautan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildFooterLink('Hubungi Kami'),
                      _buildFooterLink('Kebijakan Privasi'),
                      _buildFooterLink('Informasi Publik'),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kontak', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Jl. Jend. Sudirman No. 1', style: TextStyle(color: Colors.blue.shade100, fontSize: 13)),
                      Text('Payakumbuh, Sumatera Barat', style: TextStyle(color: Colors.blue.shade100, fontSize: 13)),
                      Text('Telp: (0752) 92023', style: TextStyle(color: Colors.blue.shade100, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const Divider(color: Colors.white12, height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2024 Pemerintah Kota Payakumbuh. All Rights Reserved.',
                style: TextStyle(color: Colors.blue.shade200, fontSize: 12),
              ),
              const Row(
                children: [
                  Icon(Icons.public, color: Colors.white70, size: 18),
                  SizedBox(width: 12),
                  Icon(Icons.share, color: Colors.white70, size: 18),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(color: Colors.blue.shade100, fontSize: 13),
      ),
    );
  }
}
