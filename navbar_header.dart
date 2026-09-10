import 'package:flutter/material.dart';
import '../main.dart';

class NavbarHeader extends StatefulWidget implements PreferredSizeWidget {
  final String activeTab;
  final Function(String)? onNavTap;

  const NavbarHeader({
    super.key,
    this.activeTab = 'Dashboard',
    this.onNavTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  State<NavbarHeader> createState() => _NavbarHeaderState();
}

class _NavbarHeaderState extends State<NavbarHeader> {
  late String _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.activeTab;
  }

  @override
  void didUpdateWidget(covariant NavbarHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeTab != widget.activeTab) {
      setState(() {
        _activeTab = widget.activeTab;
      });
    }
  }

  // Fungsi saat menu navigasi diklik
  void _onNavTap(String title) {
    setState(() {
      _activeTab = title;
    });

    if (widget.onNavTap != null) {
      widget.onNavTap!(title);
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              'Mengalihkan ke halaman $title...',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF003F87),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 840;

    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.95),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      titleSpacing: isDesktop ? 32 : 16,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF003F87).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              'assets/images/logo.png',
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.location_city_rounded,
                color: Color(0xFF003F87),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Kota Payakumbuh',
            style: TextStyle(
              color: Color(0xFF003F87),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 40),
            _buildNavLink('Dashboard'),
            _buildNavLink('Statistik'),
            _buildNavLink('Publikasi'),
            _buildNavLink('Peta'),
          ],
        ],
      ),
      actions: [
         ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (_, ThemeMode currentMode, __) {
            final isDark = currentMode == ThemeMode.dark;
            return IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, 
                color: isDark ? Colors.yellow.shade400 : const Color(0xFF0B1C30),
              ),
              tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
              onPressed: () {
                // Membalikkan tema saat ditekan
                themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
              },
            );
          },
        ),
        const SizedBox(width: 8),
        // Builder memastikan context Scaffold ditemukan untuk membuka drawer dari kanan
        Builder(
          builder: (scaffoldContext) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF0B1C30), size: 26),
              tooltip: 'Buka Menu Navigasi',
              onPressed: () {
                Scaffold.of(scaffoldContext).openEndDrawer();
              },
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNavLink(String title) {
    final bool isActive = _activeTab == title;

    return InkWell(
      onTap: () => _onNavTap(title),
      borderRadius: BorderRadius.circular(8),
      hoverColor: const Color(0xFF003F87).withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? const Color(0xFF003F87) : const Color(0xFF424752),
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}