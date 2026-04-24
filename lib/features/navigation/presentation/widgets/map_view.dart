import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // TODO: Replace this styled placeholder with the exact Figma map image asset when available.
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(color: const Color(0xFFE2E7E2)),
            const Positioned(
              left: -18,
              top: 118,
              right: -18,
              child: _RoadBand(angle: -0.16),
            ),
            const Positioned(
              left: -30,
              top: 260,
              right: -30,
              child: _RoadBand(angle: 0.08),
            ),
            Positioned(
              left: constraints.maxWidth * 0.22,
              top: constraints.maxHeight * 0.30,
              child: const _Pin(),
            ),
            Positioned(
              left: constraints.maxWidth * 0.58,
              top: constraints.maxHeight * 0.43,
              child: const _Pin(),
            ),
            Positioned(
              left: constraints.maxWidth * 0.42,
              top: constraints.maxHeight * 0.60,
              child: const _Pin(),
            ),
          ],
        );
      },
    );
  }
}

class _RoadBand extends StatelessWidget {
  final double angle;
  const _RoadBand({required this.angle});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFD7DFD8),
          border: Border.all(color: const Color(0xFFC9D2CB), width: 1),
        ),
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: AppColors.accentOrange,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
