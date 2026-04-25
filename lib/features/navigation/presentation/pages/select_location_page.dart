import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../widgets/map_view.dart';

class SelectLocationPage extends StatelessWidget {
  const SelectLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Stack(
        children: [
          const Positioned.fill(
            child: MapView(variant: MapViewVariant.selectLocation),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(26),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        size: 28, color: AppColors.inactive),
                    const SizedBox(width: 10),
                    Text(
                      'Search places...',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 246,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 58,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9DBDE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Location',
                    style: AppTextStyles.title.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _ModeChip(label: 'Directions', selected: true),
                      const SizedBox(width: 8),
                      _ModeChip(label: 'Menu', selected: false),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NaruBottomNavBar(currentIndex: 1),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _ModeChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(27),
        border: selected ? null : Border.all(color: const Color(0xFFD0D2D6)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 11.3,
          color: selected ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w500,
          height: 1.1,
        ),
      ),
    );
  }
}
