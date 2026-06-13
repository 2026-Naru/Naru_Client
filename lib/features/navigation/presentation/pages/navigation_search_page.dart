import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/main_tab_page.dart';
import 'navigation_route_list_page.dart';

class NavigationSearchPage extends StatefulWidget {
  const NavigationSearchPage({super.key});

  @override
  State<NavigationSearchPage> createState() => _NavigationSearchPageState();
}

class _NavigationSearchPageState extends State<NavigationSearchPage> {
  _NavigationSuggestion? _selectedFrom;
  _NavigationSuggestion? _selectedTo;
  bool _selectingFrom = true;

  static const _placeSuggestions = <_NavigationSuggestion>[
    _NavigationSuggestion(
      name: 'Seoul Forest',
      subtitle: 'Park · walkable picnic route',
      imagePath: 'assets/images/landmarks/seoul_forest.jpg',
      icon: Icons.place_outlined,
    ),
    _NavigationSuggestion(
      name: 'Seongsu',
      subtitle: 'Cafe street · design shops',
      imagePath: 'assets/images/landmarks/seongsu.jpg',
      icon: Icons.place_outlined,
    ),
    _NavigationSuggestion(
      name: 'Myeongdong',
      subtitle: 'Shopping · street food',
      imagePath: 'assets/images/landmarks/myeongdong.jpg',
      icon: Icons.place_outlined,
    ),
    _NavigationSuggestion(
      name: 'Gyeongbokgung Palace',
      subtitle: 'Palace · photo route',
      imagePath: 'assets/images/landmarks/gyeongbokgung_palace.jpg',
      icon: Icons.place_outlined,
    ),
    _NavigationSuggestion(
      name: 'Lotte World',
      subtitle: 'Theme park · indoor date',
      imagePath: 'assets/images/landmarks/lotte_world.jpg',
      icon: Icons.place_outlined,
    ),
    _NavigationSuggestion(
      name: 'N Seoul Tower',
      subtitle: 'Night view · landmark',
      imagePath: 'assets/images/landmarks/n_seoul_tower.jpg',
      icon: Icons.place_outlined,
    ),
    _NavigationSuggestion(
      name: 'Hangang Park',
      subtitle: 'River park · evening walk',
      imagePath: 'assets/images/landmarks/hangang_park.jpg',
      icon: Icons.place_outlined,
    ),
    _NavigationSuggestion(
      name: 'Bukchon Hanok Village',
      subtitle: 'Hanok street · quiet walk',
      imagePath: 'assets/images/landmarks/bukchon_hanok_village.jpg',
      icon: Icons.place_outlined,
    ),
    _NavigationSuggestion(
      name: 'Dongdaemun Design Plaza',
      subtitle: 'DDP · late open spots',
      imagePath: 'assets/images/landmarks/ddp.jpg',
      icon: Icons.place_outlined,
    ),
    _NavigationSuggestion(
      name: 'Gwanghwamun Square',
      subtitle: 'Square · central route',
      imagePath: 'assets/images/landmarks/gwanghwamun_square.jpg',
      icon: Icons.place_outlined,
    ),
  ];

  static const _menuSuggestions = <_NavigationSuggestion>[
    _NavigationSuggestion(
      name: 'Cafe Latte in Seongsu',
      subtitle: 'Menu · cafe/dessert route',
      imagePath: 'assets/images/food_cafe.png',
      icon: Icons.restaurant_menu_rounded,
    ),
    _NavigationSuggestion(
      name: 'Myeongdong Street Tteokbokki',
      subtitle: 'Menu · street food',
      imagePath: 'assets/images/food_tteokbokki.png',
      icon: Icons.restaurant_menu_rounded,
    ),
    _NavigationSuggestion(
      name: 'N Seoul Tower BBQ Dinner',
      subtitle: 'Menu · dinner with night view',
      imagePath: 'assets/images/food_jokbal.png',
      icon: Icons.restaurant_menu_rounded,
    ),
    _NavigationSuggestion(
      name: 'Hangang Chicken Picnic',
      subtitle: 'Menu · chicken by the river',
      imagePath: 'assets/images/Spicyseasoned.png',
      icon: Icons.restaurant_menu_rounded,
    ),
    _NavigationSuggestion(
      name: 'DDP Late Night Dessert',
      subtitle: 'Menu · open-now sweet stop',
      imagePath: 'assets/navigation/cafe3.png',
      icon: Icons.restaurant_menu_rounded,
    ),
  ];

  void _selectSuggestion(_NavigationSuggestion val) {
    setState(() {
      if (_selectingFrom) {
        _selectedFrom = _selectedFrom == val ? null : val;
        if (_selectedFrom != null) {
          _selectingFrom = false;
        }
      } else {
        _selectedTo = _selectedTo == val ? null : val;
      }
    });
    _tryNavigate();
  }

  void _tryNavigate() {
    final from = _selectedFrom?.name.trim() ?? '';
    final to = _selectedTo?.name.trim() ?? '';
    if (from.isNotEmpty && to.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NavigationRouteListPage(
            from: from,
            to: to,
            fromImagePath: _selectedFrom!.imagePath,
            toImagePath: _selectedTo!.imagePath,
          ),
        ),
      );
    }
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    final tabNotifier = MainTabScope.of(context);
    if (tabNotifier != null) {
      tabNotifier.value = 1;
      return;
    }
    Navigator.pushReplacementNamed(context, AppRouter.main, arguments: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _RoundBackButton(onTap: _handleBack),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SearchPill(
                      selectedFrom: _selectedFrom,
                      selectedTo: _selectedTo,
                      selectingFrom: _selectingFrom,
                      onSelectFrom: () => setState(() => _selectingFrom = true),
                      onSelectTo: () => setState(() => _selectingFrom = false),
                      onClearFrom: () => setState(() {
                        _selectedFrom = null;
                        _selectingFrom = true;
                      }),
                      onClearTo: () => setState(() {
                        _selectedTo = null;
                        _selectingFrom = false;
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  _SuggestionSection(
                    title: 'Places',
                    items: _placeSuggestions,
                    selectedFrom: _selectedFrom,
                    selectedTo: _selectedTo,
                    onTap: _selectSuggestion,
                  ),
                  const SizedBox(height: 20),
                  _SuggestionSection(
                    title: 'Menus',
                    items: _menuSuggestions,
                    selectedFrom: _selectedFrom,
                    selectedTo: _selectedTo,
                    onTap: _selectSuggestion,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionSection extends StatelessWidget {
  final String title;
  final List<_NavigationSuggestion> items;
  final _NavigationSuggestion? selectedFrom;
  final _NavigationSuggestion? selectedTo;
  final ValueChanged<_NavigationSuggestion> onTap;

  const _SuggestionSection({
    required this.title,
    required this.items,
    required this.selectedFrom,
    required this.selectedTo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...items.map((item) {
          final isSelected = selectedFrom == item || selectedTo == item;
          return _SuggestionTile(
            item: item,
            selected: isSelected,
            onTap: () => onTap(item),
          );
        }),
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final _NavigationSuggestion item;
  final bool selected;
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF2F2F2),
                border: Border.all(
                  color: selected ? AppColors.primary : const Color(0xFFE7E7E7),
                ),
              ),
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  item.icon,
                  size: 18,
                  color: selected ? AppColors.primary : const Color(0xFFBBBBBB),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              selected ? Icons.check_circle_rounded : item.icon,
              size: 16,
              color: selected ? AppColors.primary : const Color(0xFFBBBBBB),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color:
                          selected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RoundBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  final _NavigationSuggestion? selectedFrom;
  final _NavigationSuggestion? selectedTo;
  final bool selectingFrom;
  final VoidCallback onSelectFrom;
  final VoidCallback onSelectTo;
  final VoidCallback onClearFrom;
  final VoidCallback onClearTo;

  const _SearchPill({
    required this.selectedFrom,
    required this.selectedTo,
    required this.selectingFrom,
    required this.onSelectFrom,
    required this.onSelectTo,
    required this.onClearFrom,
    required this.onClearTo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Color(0xFF888888),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              size: 15,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ReadonlyPlaceField(
              label: selectedFrom?.name ?? 'Select departure',
              selected: selectedFrom != null,
              active: selectingFrom,
              onTap: onSelectFrom,
              onClear: selectedFrom == null ? null : onClearFrom,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '→',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF888888),
              ),
            ),
          ),
          Expanded(
            child: _ReadonlyPlaceField(
              label: selectedTo?.name ?? 'Select destination',
              selected: selectedTo != null,
              active: !selectingFrom,
              onTap: onSelectTo,
              onClear: selectedTo == null ? null : onClearTo,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationSuggestion {
  final String name;
  final String subtitle;
  final String imagePath;
  final IconData icon;

  const _NavigationSuggestion({
    required this.name,
    required this.subtitle,
    required this.imagePath,
    required this.icon,
  });
}

class _ReadonlyPlaceField extends StatelessWidget {
  final String label;
  final bool selected;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _ReadonlyPlaceField({
    required this.label,
    required this.selected,
    required this.active,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 15,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color:
                    selected ? AppColors.textPrimary : const Color(0xFFAAAAAA),
              ),
            ),
          ),
          if (onClear != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClear,
              child: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: Color(0xFF999999),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
