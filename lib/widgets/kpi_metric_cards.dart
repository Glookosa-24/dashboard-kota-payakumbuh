import 'package:flutter/material.dart';

class KpiMetricCards extends StatelessWidget {
  final bool isWideScreen;

  const KpiMetricCards({super.key, required this.isWideScreen});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _buildKpiCard(
        icon: Icons.groups_rounded,
        iconGradient: const [Color(0xFF003F87), Color(0xFF0056B3)],
        label: 'TOTAL PENDUDUK',
        value: '140.000',
        unit: 'Jiwa',
      ),
      _buildKpiCard(
        icon: Icons.trending_up_rounded,
        iconGradient: const [Color(0xFF204171), Color(0xFF3A598A)],
        label: 'PERTUMBUHAN EKONOMI',
        value: '5.2%',
        badge: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_upward, size: 12, color: Colors.green.shade700),
                  const SizedBox(width: 2),
                  Text(
                    'YoY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      _buildKpiCard(
        icon: Icons.psychology_rounded,
        iconGradient: const [Color(0xFF565F69), Color(0xFF727784)],
        label: 'INDEKS PEMB. MANUSIA',
        value: '74.5',
        unit: 'Skor',
      ),
    ];

    if (isWideScreen) {
      return Row(
        children: cards.map((c) => Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: c,
        ))).toList(),
      );
    }

    return Column(
      children: cards.map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: c,
      )).toList(),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required List<Color> iconGradient,
    required String label,
    required String value,
    String? unit,
    Widget? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: iconGradient),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF565F69),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B1C30),
                      ),
                    ),
                    if (unit != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF565F69),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      badge,
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
