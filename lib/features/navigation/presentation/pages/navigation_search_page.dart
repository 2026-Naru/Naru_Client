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
  _LandmarkSuggestion? _selectedFrom;
  _LandmarkSuggestion? _selectedTo;
  bool _selectingFrom = true;

  static const _suggestions = <_LandmarkSuggestion>[
    _LandmarkSuggestion(
      name: 'Seoul Forest',
      imagePath: 'assets/images/landmarks/seoul_forest.jpg',
    ),
    _LandmarkSuggestion(
      name: 'Seongsu',
      imagePath: 'assets/images/landmarks/seongsu.jpg',
    ),
    _LandmarkSuggestion(
      name: 'Myeongdong',
      imagePath: 'assets/images/landmarks/myeongdong.jpg',
    ),
    _LandmarkSuggestion(
      name: 'Gyeongbokgung Palace',
      imagePath: 'assets/images/landmarks/gyeongbokgung_palace.jpg',
    ),
    _LandmarkSuggestion(
      name: 'Lotte World',
      imagePath: 'assets/images/landmarks/lotte_world.jpg',
    ),
    _LandmarkSuggestion(
      name: 'N Seoul Tower',
      imagePath: 'assets/images/landmarks/n_seoul_tower.jpg',
    ),
    _LandmarkSuggestion(
      name: 'Hangang Park',
      imagePath: 'assets/images/landmarks/hangang_park.jpg',
    ),
    _LandmarkSuggestion(
      name: 'Bukchon Hanok Village',
      imagePath: 'assets/images/landmarks/bukchon_hanok_village.jpg',
    ),
    _LandmarkSuggestion(
      name: 'Dongdaemun Design Plaza',
      imagePath: 'assets/images/landmarks/ddp.jpg',
    ),
    _LandmarkSuggestion(
      name: 'Gwanghwamun Square',
      imagePath: 'assets/images/landmarks/gwanghwamun_square.jpg',
    ),
  ];

  void _selectSuggestion(_LandmarkSuggestion val) {
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
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: _suggestions.length,
                itemBuilder: (_, i) {
                  final s = _suggestions[i];
                  final isSelected = _selectedFrom == s || _selectedTo == s;
                  return InkWell(
                    onTap: () => _selectSuggestion(s),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 11, horizontal: 4),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.north_west_rounded,
                            size: 15,
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFBBBBBB),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            s.name,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
  final _LandmarkSuggestion? selectedFrom;
  final _LandmarkSuggestion? selectedTo;
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

class _LandmarkSuggestion {
  final String name;
  final String imagePath;

  const _LandmarkSuggestion({
    required this.name,
    required this.imagePath,
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
