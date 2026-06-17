import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/main_tab_page.dart';
import 'navigation_search_page.dart';
import 'navigation_route_list_page.dart';
import 'navigation_store_detail_page.dart';
import '../widgets/map_view.dart';
import '../widgets/search_filter_sheet.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final Set<String> _selectedFilters = {};

  void _onBackTap(BuildContext context) {
    final tabNotifier = MainTabScope.of(context);
    if (tabNotifier != null) {
      tabNotifier.value = 0;
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushReplacementNamed(context, AppRouter.main, arguments: 0);
  }

  void _openStoreDetail(BuildContext context, MapStorePin pin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NavigationStoreDetailPage(pin: pin),
      ),
    );
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchFilterSheet(
        options: _filterOptions,
        initialSelected: _selectedFilters,
        fieldPlaceholder: 'Choose area or category',
        sectionTitle: 'Areas and categories',
        applyLabel: 'Show spots',
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _selectedFilters
        ..clear()
        ..addAll(selected);
    });
  }

  void _openFriendTourDetail(BuildContext context, _FriendTourCardItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FriendTourDetailSheet(
        item: item,
        onFollowRoute: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NavigationRouteListPage(
                from: item.routeStops.first.name,
                to: item.routeStops.last.name,
                fromImagePath: item.routeStops.first.imagePath,
                toImagePath: item.routeStops.last.imagePath,
              ),
            ),
          );
        },
      ),
    );
  }

  void _openFilterRoute(BuildContext context) {
    final route = _filterRoute;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NavigationRouteListPage(
          from: route.from.name,
          to: route.to.name,
          fromImagePath: route.from.imagePath,
          toImagePath: route.to.imagePath,
        ),
      ),
    );
  }

  void _openRecommendationRoute(
    BuildContext context,
    _FilterRecommendation item,
  ) {
    _showActionMessage('${item.title} added to your plan');
  }

  void _openTrendingPreview(BuildContext context, _TrendingItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SpotPreviewSheet(
        item: item,
        onViewMap: () {
          Navigator.pop(context);
          _showActionMessage('${item.title} highlighted on map');
        },
        onBuildRoute: () {
          Navigator.pop(context);
          _showActionMessage('${item.title} route draft saved');
        },
        onSave: () {
          Navigator.pop(context);
          _showActionMessage('${item.title} saved');
        },
      ),
    );
  }

  void _openPickDetail(BuildContext context, _PickItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MenuDetailSheet(
        item: item,
        onRoute: () {
          Navigator.pop(context);
          _showActionMessage('${item.title} added as a menu stop');
        },
        onLike: () {
          Navigator.pop(context);
          _showActionMessage('${item.title} added to Likes');
        },
        onViewStore: () {
          Navigator.pop(context);
          _showActionMessage('${item.title} store preview opened');
        },
      ),
    );
  }

  void _openFriendRoutes(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FriendRoutesSheet(
        tours: _friendTours,
        onFollow: (tour) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NavigationRouteListPage(
                from: tour.routeStops.first.name,
                to: tour.routeStops.last.name,
                fromImagePath: tour.routeStops.first.imagePath,
                toImagePath: tour.routeStops.last.imagePath,
              ),
            ),
          );
        },
      ),
    );
  }

  void _openSharingSpotDetail(BuildContext context, _SharingSpotItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SharingSpotDetailSheet(
        item: item,
        onAddRoute: () {
          Navigator.pop(context);
          _showActionMessage('${item.title} added to your route');
        },
        onOpenMenus: () {
          Navigator.pop(context);
          _showActionMessage('Nearby menus opened for ${item.title}');
        },
      ),
    );
  }

  void _showActionMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Pretendard'),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  bool _matchesFilters(String value) {
    if (_selectedFilters.isEmpty) return true;
    final text = value.toLowerCase();
    return _selectedFilters.any((filter) {
      final normalized = filter.toLowerCase();
      if (normalized == 'nearby') {
        return text.contains('sillim') || text.contains('km away');
      }
      if (normalized == 'open now') {
        return true;
      }
      if (normalized == 'street food') {
        return text.contains('street') || text.contains('tteokbokki');
      }
      return text.contains(normalized);
    });
  }

  List<_TrendingItem> get _visibleTrending => _trending
      .where((item) => _matchesFilters(
            '${item.title} ${item.distance} ${item.subtitle}',
          ))
      .toList();

  List<_PickItem> get _visiblePicks => _picks
      .where((item) => _matchesFilters(
            '${item.title} ${item.subtitle} ${item.price}',
          ))
      .toList();

  List<_SharingSpotItem> get _visibleSharingSpots => _sharingSpots
      .where((item) => _matchesFilters('${item.title} ${item.subtitle}'))
      .toList();

  List<_FriendTourCardItem> get _visibleFriendTours => _friendTours
      .where((item) => _matchesFilters(
            '${item.storeName} ${item.category} ${item.comment}',
          ))
      .toList();

  _SuggestedFilterRoute get _filterRoute {
    if (_selectedFilters.contains('Cafe')) {
      return const _SuggestedFilterRoute(
        from: _TourStop(
          name: 'Seoul Forest',
          note: 'Start with an easy park walk before cafe hopping.',
          imagePath: 'assets/images/landmarks/seoul_forest.jpg',
        ),
        to: _TourStop(
          name: 'Seongsu',
          note: 'Cafe-heavy streets with dessert spots open nearby.',
          imagePath: 'assets/images/landmarks/seongsu.jpg',
        ),
      );
    }
    if (_selectedFilters.contains('BBQ')) {
      return const _SuggestedFilterRoute(
        from: _TourStop(
          name: 'Myeongdong',
          note: 'Start near bright dinner streets and transit.',
          imagePath: 'assets/images/landmarks/myeongdong.jpg',
        ),
        to: _TourStop(
          name: 'N Seoul Tower',
          note: 'Finish with a night-view route after dinner.',
          imagePath: 'assets/images/landmarks/n_seoul_tower.jpg',
        ),
      );
    }
    if (_selectedFilters.contains('Street food')) {
      return const _SuggestedFilterRoute(
        from: _TourStop(
          name: 'Gwanghwamun Square',
          note: 'A central start with easy route options.',
          imagePath: 'assets/images/landmarks/gwanghwamun_square.jpg',
        ),
        to: _TourStop(
          name: 'Myeongdong',
          note: 'Street food, snacks, and late open stops.',
          imagePath: 'assets/images/landmarks/myeongdong.jpg',
        ),
      );
    }
    return const _SuggestedFilterRoute(
      from: _TourStop(
        name: 'Seoul Forest',
        note: 'Nearby-friendly start for a relaxed food route.',
        imagePath: 'assets/images/landmarks/seoul_forest.jpg',
      ),
      to: _TourStop(
        name: 'Dongdaemun Design Plaza',
        note: 'Open-now route with late shops and bright streets.',
        imagePath: 'assets/images/landmarks/ddp.jpg',
      ),
    );
  }

  List<_FilterRecommendation> get _filterPlaceRecommendations {
    if (_selectedFilters.contains('Cafe')) {
      return const [
        _FilterRecommendation(
          title: 'Seongsu',
          subtitle: 'Cafe street · 12 matched menus',
          imagePath: 'assets/images/landmarks/seongsu.jpg',
          badge: 'Place',
        ),
        _FilterRecommendation(
          title: 'Seoul Forest',
          subtitle: 'Picnic route · dessert nearby',
          imagePath: 'assets/images/landmarks/seoul_forest.jpg',
          badge: 'Place',
        ),
      ];
    }
    if (_selectedFilters.contains('Street food')) {
      return const [
        _FilterRecommendation(
          title: 'Myeongdong',
          subtitle: 'Street food · late snacks',
          imagePath: 'assets/images/landmarks/myeongdong.jpg',
          badge: 'Place',
        ),
        _FilterRecommendation(
          title: 'Gwanghwamun Square',
          subtitle: 'Central start · walkable route',
          imagePath: 'assets/images/landmarks/gwanghwamun_square.jpg',
          badge: 'Place',
        ),
      ];
    }
    return const [
      _FilterRecommendation(
        title: 'Seoul Forest',
        subtitle: 'Nearby · open route',
        imagePath: 'assets/images/landmarks/seoul_forest.jpg',
        badge: 'Place',
      ),
      _FilterRecommendation(
        title: 'Dongdaemun Design Plaza',
        subtitle: 'Open now · night walk',
        imagePath: 'assets/images/landmarks/ddp.jpg',
        badge: 'Place',
      ),
    ];
  }

  List<_FilterRecommendation> get _filterMenuRecommendations {
    if (_selectedFilters.contains('BBQ')) {
      return const [
        _FilterRecommendation(
          title: 'N Seoul Tower BBQ Dinner',
          subtitle: 'Dinner · night-view route',
          imagePath: 'assets/images/food_jokbal.png',
          badge: 'Menu',
        ),
        _FilterRecommendation(
          title: 'Myeongdong Grill Plate',
          subtitle: 'BBQ · open now',
          imagePath: 'assets/images/Spicy-MarinatedSa.png',
          badge: 'Menu',
        ),
      ];
    }
    if (_selectedFilters.contains('Street food')) {
      return const [
        _FilterRecommendation(
          title: 'Myeongdong Street Tteokbokki',
          subtitle: 'Tteokbokki · spicy pick',
          imagePath: 'assets/images/food_tteokbokki.png',
          badge: 'Menu',
        ),
        _FilterRecommendation(
          title: 'DDP Late Night Dessert',
          subtitle: 'Dessert · open now',
          imagePath: 'assets/navigation/cafe3.png',
          badge: 'Menu',
        ),
      ];
    }
    return const [
      _FilterRecommendation(
        title: 'Cafe Latte in Seongsu',
        subtitle: 'Cafe · dessert route',
        imagePath: 'assets/images/food_cafe.png',
        badge: 'Menu',
      ),
      _FilterRecommendation(
        title: 'Hangang Chicken Picnic',
        subtitle: 'Chicken · picnic set',
        imagePath: 'assets/images/Spicyseasoned.png',
        badge: 'Menu',
      ),
    ];
  }

  static const List<String> _filterOptions = [
    'Sillim',
    'Cafe',
    'BBQ',
    'Street food',
    'Nearby',
    'Open now',
  ];

  static const List<_TrendingItem> _trending = [
    _TrendingItem(
      rank: 1,
      title: 'SIMZPATI KUSSEOUL STATION',
      distance: '4.2km away',
      subtitle: '#Hot place\n#Corkage-free',
      imagePath: 'assets/images/food_cafe.png',
    ),
    _TrendingItem(
      rank: 2,
      title: 'TEXAS BBQ GHOST BLACK YE...',
      distance: '9.9km away',
      subtitle: '#BBQ\n#Loved by all',
      imagePath: 'assets/images/food_jokbal.png',
    ),
    _TrendingItem(
      rank: 3,
      title: 'FAMOUS Sillim TTEOKBOKKI',
      distance: '1.2km away',
      subtitle: '#Locals pick\n#Street food',
      imagePath: 'assets/images/food_tteokbokki.png',
    ),
  ];

  static const List<_PickItem> _picks = [
    _PickItem(
      title: 'Musa Kimchi BBQ',
      subtitle: 'Grilled Pork',
      price: '₩7,000(~16,000)',
      imagePath: 'assets/images/food_jokbal.png',
    ),
    _PickItem(
      title: 'Dokkkaebjjip',
      subtitle: 'Rice cake hotpot',
      price: '₩3,000(~38,000)',
      imagePath: 'assets/images/food_tteokbokki.png',
    ),
    _PickItem(
      title: 'Small Octopus',
      subtitle: 'Small Octopus',
      price: '₩9,000',
      imagePath: 'assets/images/smalloctopus.png',
    ),
  ];

  static const List<_SharingSpotItem> _sharingSpots = [
    _SharingSpotItem(
      title: 'EMON N M',
      subtitle: 'Cafe/Dessert',
      imagePath: 'assets/navigation/cafe1.png',
    ),
    _SharingSpotItem(
      title: 'KOMU',
      subtitle: 'Cafe Dessert',
      imagePath: 'assets/navigation/cafe2.png',
    ),
    _SharingSpotItem(
      title: 'FOODSEOUL',
      subtitle: 'Cafe Dessert',
      imagePath: 'assets/navigation/cafe3.png',
    ),
    _SharingSpotItem(
      title: 'PandaExpress IFC Mall',
      subtitle: 'Chinese Food',
      imagePath: 'assets/navigation/chinesefood.png',
    ),
    _SharingSpotItem(
      title: 'HAPPY?',
      subtitle: 'Restaurant',
      imagePath: 'assets/navigation/restaurant.png',
    ),
    _SharingSpotItem(
      title: 'Humming Bella',
      subtitle: 'Cafe Dessert',
      imagePath: 'assets/navigation/cafe4.png',
    ),
  ];

  static const List<_FriendTourCardItem> _friendTours = [
    _FriendTourCardItem(
      name: 'Jake',
      timeAgo: 'last week',
      storeName: 'ehbd',
      category: 'Cafe,Dessert',
      comment:
          'This place is really the best.\nBeautiful cafes and desserts made me happy!',
      imagePath: 'assets/navigation/feed1.png',
      routeStops: [
        _TourStop(
          name: 'Seoul Forest',
          note: 'Start with a slow walk before dessert.',
          imagePath: 'assets/images/landmarks/seoul_forest.jpg',
        ),
        _TourStop(
          name: 'Seongsu',
          note: 'Cafe streets and the friend-recommended dessert stop.',
          imagePath: 'assets/images/landmarks/seongsu.jpg',
        ),
        _TourStop(
          name: 'Dongdaemun Design Plaza',
          note: 'Finish with an evening walk and late open spots.',
          imagePath: 'assets/images/landmarks/ddp.jpg',
        ),
      ],
    ),
    _FriendTourCardItem(
      name: 'JOY',
      timeAgo: 'last week',
      storeName: 'Tumors Yeonhui',
      category: 'Cafe,Dessert',
      comment:
          'The cozy interior is....\nbeautiful!!!\nI want to come back in the summer.',
      imagePath: 'assets/navigation/feed2.png',
      routeStops: [
        _TourStop(
          name: 'Gyeongbokgung Palace',
          note: 'Begin around classic Seoul scenery.',
          imagePath: 'assets/images/landmarks/gyeongbokgung_palace.jpg',
        ),
        _TourStop(
          name: 'Bukchon Hanok Village',
          note: 'A quiet photo walk before the cafe stop.',
          imagePath: 'assets/images/landmarks/bukchon_hanok_village.jpg',
        ),
        _TourStop(
          name: 'Gwanghwamun Square',
          note: 'Finish near transit, food streets, and open plazas.',
          imagePath: 'assets/images/landmarks/gwanghwamun_square.jpg',
        ),
      ],
    ),
  ];

  static const List<_FriendAvatarItem> _friendAvatars = [
    _FriendAvatarItem(
        name: 'Hongdae', imagePath: 'assets/navigation/hongdae.png'),
    _FriendAvatarItem(
        name: 'Jongno', imagePath: 'assets/navigation/jongno.png'),
    _FriendAvatarItem(
        name: 'Hannam', imagePath: 'assets/navigation/hannam.png'),
    _FriendAvatarItem(name: 'Suwon', imagePath: 'assets/navigation/suwon.png'),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final mapHeight = screenWidth * 1.03;
    final visibleTrending = _visibleTrending;
    final visiblePicks = _visiblePicks;
    final visibleSharingSpots = _visibleSharingSpots;
    final visibleFriendTours = _visibleFriendTours;
    final hasFilters = _selectedFilters.isNotEmpty;
    final filterPlaces = _filterPlaceRecommendations;
    final filterMenus = _filterMenuRecommendations;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: mapHeight,
                    child: MapView(
                      variant: MapViewVariant.navigation,
                      onStorePinTap: (pin) => _openStoreDetail(context, pin),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 18,
                    right: 18,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _onBackTap(context),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2.5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const NavigationSearchPage(),
                                    ),
                                  ),
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F1F1),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.06),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2.5),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.search,
                                          color: AppColors.inactive,
                                          size: 26,
                                        ),
                                        const SizedBox(width: 8.5),
                                        Expanded(
                                          child: Text(
                                            _selectedFilters.isEmpty
                                                ? 'Search your destination'
                                                : _selectedFilters.join(', '),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.body.copyWith(
                                              fontSize: 14,
                                              color: AppColors.textMuted,
                                              fontWeight: FontWeight.w400,
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _openFilterSheet(context),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: _selectedFilters.isEmpty
                                        ? Colors.white
                                        : AppColors.brandOrange,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2.5),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.tune_rounded,
                                    size: 22,
                                    color: _selectedFilters.isEmpty
                                        ? AppColors.textPrimary
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(0, -10),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 28, 14, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeading(
                        leading: Text(
                          'Trending in ',
                          style: AppTextStyles.title,
                        ),
                        highlighted: Text(
                          'Sillim',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentOrange,
                          ),
                        ),
                        subtitle: 'Updated 9 min ago',
                      ),
                      const SizedBox(height: 14),
                      if (hasFilters) ...[
                        _FilterActionCard(
                          filters: _selectedFilters,
                          route: _filterRoute,
                          visibleCount: filterPlaces.length +
                              filterMenus.length +
                              visibleFriendTours.length,
                          onTap: () => _openFilterRoute(context),
                          onClear: () => setState(_selectedFilters.clear),
                        ),
                        const SizedBox(height: 16),
                        _FilterRecommendationSection(
                          title: 'Places',
                          items: filterPlaces,
                          onTap: (item) => _openRecommendationRoute(
                            context,
                            item,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _FilterRecommendationSection(
                          title: 'Menus',
                          items: filterMenus,
                          onTap: (item) => _openRecommendationRoute(
                            context,
                            item,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ] else ...[
                        SizedBox(
                          height: 220,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: visibleTrending.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, index) => _TrendingCard(
                              item: visibleTrending[index],
                              onTap: () => _openTrendingPreview(
                                context,
                                visibleTrending[index],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        const _SectionHeading(
                          leading: Text(
                            'Sillim Restaurant ',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentOrange,
                            ),
                          ),
                          highlighted: Text(
                            'Picks',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: 'For Baegopa',
                          subtitleStyle: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: visiblePicks.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, index) => _PickCard(
                              item: visiblePicks[index],
                              onTap: () => _openPickDetail(
                                context,
                                visiblePicks[index],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                      _FriendPromoBanner(
                        onTap: () => _openFriendRoutes(context),
                      ),
                      const SizedBox(height: 48),
                      if (!hasFilters) ...[
                        const Text(
                          'Find new spots in the sharing list',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: visibleSharingSpots.map((item) {
                            final itemWidth = (screenWidth - (14 * 2) - 8) / 2;
                            return SizedBox(
                              width: itemWidth,
                              child: _SharingSpotCard(
                                item: item,
                                onTap: () => _openSharingSpotDetail(
                                  context,
                                  item,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 48),
                      ],
                      if (visibleFriendTours.isNotEmpty) ...[
                        const Text(
                          'Restaurant tour with friends',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 290,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: visibleFriendTours.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, index) => _FriendTourCard(
                              item: visibleFriendTours[index],
                              onTap: () => _openFriendTourDetail(
                                context,
                                visibleFriendTours[index],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                      const Text(
                        'Trending Neighborhoods',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _friendAvatars.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (_, index) => _FriendAvatar(
                            item: _friendAvatars[index],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NaruBottomNavBar(currentIndex: 1),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final Text leading;
  final Text highlighted;
  final String subtitle;
  final TextStyle? subtitleStyle;

  const _SectionHeading({
    required this.leading,
    required this.highlighted,
    required this.subtitle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: leading.data, style: leading.style),
              TextSpan(text: highlighted.data, style: highlighted.style),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: subtitleStyle ??
              AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: AppColors.textMuted,
                height: 1.2,
              ),
        ),
      ],
    );
  }
}

class _FilterActionCard extends StatelessWidget {
  final Set<String> filters;
  final _SuggestedFilterRoute route;
  final int visibleCount;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _FilterActionCard({
    required this.filters,
    required this.route,
    required this.visibleCount,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final filterText = filters.join(', ');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD4C5)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.brandOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New route unlocked',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$visibleCount spots matched · $filterText',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClear,
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _RouteEndpoint(imagePath: route.from.imagePath),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: AppColors.brandOrange,
                ),
              ),
              _RouteEndpoint(imagePath: route.to.imagePath),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${route.from.name} to ${route.to.name}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.route_rounded, size: 18),
              label: const Text(
                'Build this route',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.brandOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteEndpoint extends StatelessWidget {
  final String imagePath;

  const _RouteEndpoint({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(imagePath, fit: BoxFit.cover),
    );
  }
}

class _FilterRecommendationSection extends StatelessWidget {
  final String title;
  final List<_FilterRecommendation> items;
  final ValueChanged<_FilterRecommendation> onTap;

  const _FilterRecommendationSection({
    required this.title,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 10),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) => _FilterRecommendationCard(
              item: items[index],
              onTap: () => onTap(items[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterRecommendationCard extends StatelessWidget {
  final _FilterRecommendation item;
  final VoidCallback onTap;

  const _FilterRecommendationCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 190,
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7E7E7)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(item.imagePath, fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.badge,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.route_rounded,
                    size: 18,
                    color: AppColors.brandOrange,
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

class _TrendingCard extends StatelessWidget {
  final _TrendingItem item;
  final VoidCallback onTap;

  const _TrendingCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 196,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(item.imagePath, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.18),
                      Colors.black.withValues(alpha: 0.74),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.rank}',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.distance,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.80),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickCard extends StatelessWidget {
  final _PickItem item;
  final VoidCallback onTap;

  const _PickCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.asset(
                  item.imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                width: double.infinity,
                color: const Color(0xFF1C1C1E),
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.krwTextToUsd(item.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendPromoBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _FriendPromoBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 84,
        decoration: BoxDecoration(
          color: const Color(0xFFC88F46),
          borderRadius: BorderRadius.circular(13),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Not sure where to go?',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontSize: 9,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Discover a new Korea\nthrough friends!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: Image.asset(
                'assets/images/speechbubble.png',
                width: 52,
                height: 52,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SharingSpotCard extends StatelessWidget {
  final _SharingSpotItem item;
  final VoidCallback onTap;

  const _SharingSpotCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            SizedBox(
              height: 94,
              width: double.infinity,
              child: Image.asset(item.imagePath, fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.64),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.captionMedium.copyWith(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.15,
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

class _SpotPreviewSheet extends StatelessWidget {
  final _TrendingItem item;
  final VoidCallback onViewMap;
  final VoidCallback onBuildRoute;
  final VoidCallback onSave;

  const _SpotPreviewSheet({
    required this.item,
    required this.onViewMap,
    required this.onBuildRoute,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return _PreviewSheetFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeroImage(imagePath: item.imagePath),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.brandOrange,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${item.rank}',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${item.distance} · ${item.subtitle.replaceAll('\n', ' ')}',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SheetActionButton(
                  label: 'View on map',
                  icon: Icons.map_outlined,
                  onTap: onViewMap,
                  outlined: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SheetActionButton(
                  label: 'Build route',
                  icon: Icons.route_rounded,
                  onTap: onBuildRoute,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SheetActionButton(
            label: 'Save',
            icon: Icons.bookmark_border_rounded,
            onTap: onSave,
            outlined: true,
          ),
        ],
      ),
    );
  }
}

class _MenuDetailSheet extends StatelessWidget {
  final _PickItem item;
  final VoidCallback onRoute;
  final VoidCallback onLike;
  final VoidCallback onViewStore;

  const _MenuDetailSheet({
    required this.item,
    required this.onRoute,
    required this.onLike,
    required this.onViewStore,
  });

  @override
  Widget build(BuildContext context) {
    return _PreviewSheetFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeroImage(imagePath: item.imagePath),
          const SizedBox(height: 16),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${item.subtitle} · ${CurrencyFormatter.krwTextToUsd(item.price)}',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Recommended near Sillim Restaurant Picks',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 18),
          _SheetActionButton(
            label: 'Route to this menu',
            icon: Icons.near_me_outlined,
            onTap: onRoute,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SheetActionButton(
                  label: 'Add to Likes',
                  icon: Icons.favorite_border_rounded,
                  onTap: onLike,
                  outlined: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SheetActionButton(
                  label: 'View store',
                  icon: Icons.storefront_outlined,
                  onTap: onViewStore,
                  outlined: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FriendRoutesSheet extends StatelessWidget {
  final List<_FriendTourCardItem> tours;
  final ValueChanged<_FriendTourCardItem> onFollow;

  const _FriendRoutesSheet({
    required this.tours,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    return _PreviewSheetFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Friend routes',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick a friend-made route and keep it in your plan.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ...tours.map(
            (tour) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FriendRouteTile(
                tour: tour,
                onFollow: () => onFollow(tour),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendRouteTile extends StatelessWidget {
  final _FriendTourCardItem tour;
  final VoidCallback onFollow;

  const _FriendRouteTile({
    required this.tour,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              tour.imagePath,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tour.name}\'s ${tour.category} route',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tour.routeStops.map((stop) => stop.name).join(' → '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onFollow,
            child: const Text(
              'Follow',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                color: AppColors.brandOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SharingSpotDetailSheet extends StatelessWidget {
  final _SharingSpotItem item;
  final VoidCallback onAddRoute;
  final VoidCallback onOpenMenus;

  const _SharingSpotDetailSheet({
    required this.item,
    required this.onAddRoute,
    required this.onOpenMenus,
  });

  @override
  Widget build(BuildContext context) {
    return _PreviewSheetFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeroImage(imagePath: item.imagePath),
          const SizedBox(height: 16),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${item.subtitle} · saved by 128 friends',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SheetActionButton(
                  label: 'Add to my route',
                  icon: Icons.add_location_alt_outlined,
                  onTap: onAddRoute,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SheetActionButton(
                  label: 'Open menus',
                  icon: Icons.restaurant_menu_rounded,
                  onTap: onOpenMenus,
                  outlined: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewSheetFrame extends StatelessWidget {
  final Widget child;

  const _PreviewSheetFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.84,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _SheetHeroImage extends StatelessWidget {
  final String imagePath;

  const _SheetHeroImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1.85,
        child: Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }
}

class _SheetActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  const _SheetActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
          ),
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.brandOrange,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(46),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(23),
        ),
      ),
      child: child,
    );
  }
}

class _FriendTourCard extends StatelessWidget {
  final _FriendTourCardItem item;
  final VoidCallback onTap;

  const _FriendTourCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 220,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Expanded(
                flex: 55,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(item.imagePath, fit: BoxFit.cover),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.black.withValues(alpha: 0.25),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Image.asset(
                                  'assets/navigation/profile.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      ...List.generate(
                                        5,
                                        (_) => Padding(
                                          padding:
                                              const EdgeInsets.only(right: 2),
                                          child: SvgPicture.asset(
                                            'assets/icons/star.svg',
                                            width: 12,
                                            height: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.timeAgo,
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white
                                              .withValues(alpha: 0.85),
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            item.storeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.category,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.88),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 45,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF1C1C1E),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Text(
                    item.comment,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendTourDetailSheet extends StatelessWidget {
  final _FriendTourCardItem item;
  final VoidCallback onFollowRoute;

  const _FriendTourDetailSheet({
    required this.item,
    required this.onFollowRoute,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1.8,
                child: Image.asset(item.imagePath, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.hardEdge,
                  child: Image.asset(
                    'assets/navigation/profile.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.name} recommends',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.storeName} · ${item.category}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              item.comment.replaceAll('\n', ' '),
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Suggested route',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            ...item.routeStops.asMap().entries.map(
                  (entry) => _TourStopTile(
                    index: entry.key + 1,
                    stop: entry.value,
                    isLast: entry.key == item.routeStops.length - 1,
                  ),
                ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onFollowRoute,
                icon: const Icon(Icons.route_rounded, size: 20),
                label: const Text(
                  'Follow this route',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.brandOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourStopTile extends StatelessWidget {
  final int index;
  final _TourStop stop;
  final bool isLast;

  const _TourStopTile({
    required this.index,
    required this.stop,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.textPrimary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 1,
                  height: 44,
                  color: const Color(0xFFE2E2E2),
                ),
            ],
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              stop.imagePath,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stop.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  final _FriendAvatarItem item;
  const _FriendAvatar({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(item.imagePath, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingItem {
  final int rank;
  final String title;
  final String distance;
  final String subtitle;
  final String imagePath;
  const _TrendingItem({
    required this.rank,
    required this.title,
    required this.distance,
    required this.subtitle,
    required this.imagePath,
  });
}

class _PickItem {
  final String title;
  final String subtitle;
  final String price;
  final String imagePath;
  const _PickItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imagePath,
  });
}

class _SharingSpotItem {
  final String title;
  final String subtitle;
  final String imagePath;
  const _SharingSpotItem({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}

class _FriendTourCardItem {
  final String name;
  final String timeAgo;
  final String storeName;
  final String category;
  final String comment;
  final String imagePath;
  final List<_TourStop> routeStops;

  const _FriendTourCardItem({
    required this.name,
    required this.timeAgo,
    required this.storeName,
    required this.category,
    required this.comment,
    required this.imagePath,
    required this.routeStops,
  });
}

class _TourStop {
  final String name;
  final String note;
  final String imagePath;

  const _TourStop({
    required this.name,
    required this.note,
    required this.imagePath,
  });
}

class _SuggestedFilterRoute {
  final _TourStop from;
  final _TourStop to;

  const _SuggestedFilterRoute({
    required this.from,
    required this.to,
  });
}

class _FilterRecommendation {
  final String title;
  final String subtitle;
  final String imagePath;
  final String badge;

  const _FilterRecommendation({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.badge,
  });
}

class _FriendAvatarItem {
  final String name;
  final String imagePath;
  const _FriendAvatarItem({
    required this.name,
    required this.imagePath,
  });
}
