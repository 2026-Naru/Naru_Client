import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import 'navigation_search_page.dart';
import '../widgets/map_view.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Stack(
        children: [
          const Positioned.fill(child: MapView()),
          // Search bar at top
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NavigationSearchPage()),
                    ),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.bgWhite,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.11),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/ic_search_bar.svg',
                            width: 18,
                            height: 18,
                          ),
                          const SizedBox(width: 8),
                          Text('Search places...',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w400,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom sheet handle
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 188,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1E3E6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Select Location', style: AppTextStyles.title),
                  const SizedBox(height: 10),
                  const _LocationTab(),
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

class _LocationTab extends StatefulWidget {
  const _LocationTab();

  @override
  State<_LocationTab> createState() => _LocationTabState();
}

class _LocationTabState extends State<_LocationTab> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(
          label: 'Directions',
          active: _selected == 0,
          onTap: () => setState(() => _selected = 0),
        ),
        const SizedBox(width: 6),
        _Chip(
          label: 'Menu',
          active: _selected == 1,
          onTap: () => setState(() => _selected = 1),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.bgLight,
          border: active ? null : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: active ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
