import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';

class NaruBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const NaruBottomNavBar({super.key, required this.currentIndex});

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_outlined, label: 'Home', route: AppRouter.home),
    _NavItem(
        icon: Icons.location_on_outlined,
        label: 'Navigation',
        route: AppRouter.navigation),
    _NavItem(
        icon: Icons.favorite_border,
        label: 'Likes',
        route: AppRouter.favorites),
    _NavItem(
        icon: Icons.list_alt_outlined, label: 'Lists', route: AppRouter.lists),
    _NavItem(icon: Icons.person_outline, label: 'My', route: AppRouter.myPage),
  ];

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    const selectedColor = Color(0xFF151515);
    const unselectedColor = Color(0xFFB9B9B9);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        border: const Border(top: BorderSide(color: Color(0xFFE7E7E7))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(12, 8, 12, 6 + safeBottom),
      child: Row(
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final active = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (!active) {
                  Navigator.pushReplacementNamed(context, item.route);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 21,
                    color: active ? selectedColor : unselectedColor,
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        item.label,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        softWrap: false,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 9,
                          color: active ? selectedColor : unselectedColor,
                          fontWeight:
                              active ? FontWeight.w500 : FontWeight.w400,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem(
      {required this.icon, required this.label, required this.route});
}
