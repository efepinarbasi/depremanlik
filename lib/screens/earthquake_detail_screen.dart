import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/earthquake.dart';

class EarthquakeDetailScreen extends StatelessWidget {
  final Earthquake earthquake;

  const EarthquakeDetailScreen({
    super.key,
    required this.earthquake,
  });

  @override
  Widget build(BuildContext context) {
    // Fallback to today if formatting fails
    final date = earthquake.date.toLocal();
    final timeStr = DateFormat('HH:mm').format(date);
    final dateStr = DateFormat('MMM d').format(date);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1326),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1326).withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFDAE2FD)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            // Logo
            Image.asset(
              'assets/logo.png', // Assuming logo is in assets
              height: 24,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.radar,
                color: Color(0xFFDAE2FD),
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Earthquake Detail',
                style: TextStyle(
                  color: Color(0xFFDAE2FD),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF060E20),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag Handle
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC4C7C8).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header / Hero Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      earthquake.mag.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFDAE2FD),
                                        height: 1.1,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'MAGNITUDE',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                        color: Color(0xFFC4C7C8),
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  earthquake.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFDAE2FD),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            width: 8,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getMagnitudeColor(earthquake.mag),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Map Thumbnail Placeholder
                    Container(
                      height: 192,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF171F33),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Fake static map tint
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF060E20),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          // Map Marker animation placeholder
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _getMagnitudeColor(earthquake.mag).withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                          ),
                          // Map Marker core
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _getMagnitudeColor(earthquake.mag),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Data Grid
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 24,
                          children: [
                            _buildDataCell(
                              icon: Icons.straighten,
                              title: 'DEPTH',
                              value: '${earthquake.depth.toStringAsFixed(1)} km',
                            ),
                            _buildDataCell(
                              icon: Icons.schedule,
                              title: 'TIME',
                              value: '$timeStr Local',
                              subtitle: dateStr,
                            ),
                            _buildDataCell(
                              icon: Icons.explore,
                              title: 'COORDINATES',
                              value: '${earthquake.latitude.toStringAsFixed(2)}°N',
                              subtitle: '${earthquake.longitude.toStringAsFixed(2)}°E',
                            ),
                            _buildDataCell(
                              icon: Icons.verified_user_outlined,
                              title: 'STATUS',
                              value: 'Reviewed',
                              subtitle: earthquake.id.isNotEmpty ? 'Verified' : 'Pending',
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Add share functionality
                              },
                              icon: const Icon(Icons.ios_share, size: 20),
                              label: const Text('Share Report', style: TextStyle(fontFamily: 'Inter')),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFDAE2FD),
                                side: const BorderSide(color: Color(0xFF444749)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Add map intent/launcher
                              },
                              icon: const Icon(Icons.map_outlined, size: 20),
                              label: const Text('Open Maps', style: TextStyle(fontFamily: 'Inter')),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFDAE2FD),
                                side: const BorderSide(color: Color(0xFF444749)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFFC4C7C8)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFC4C7C8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFDAE2FD),
            fontSize: 17,
            fontWeight: FontWeight.w400,
            fontFamily: 'Inter',
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFC4C7C8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ],
    );
  }

  Color _getMagnitudeColor(double mag) {
    if (mag < 4.0) return const Color(0xFFD97706); // Muted Amber
    if (mag < 5.0) return const Color(0xFFE2725B); // Soft Terracotta
    return const Color(0xFF93000A); // Deep Crimson // error-container
    if (mag >= 5.0) return const Color(0xFFFFB4AB); // error
    if (mag >= 4.0) return const Color(0xFFFD8B00); // secondary (from orange)
    return const Color(0xFF2AE500); // tertiary (green from main theme)
  }
}

