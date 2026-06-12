import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../home/data/store_service.dart';
import '../../../lists/presentation/providers/store_history_provider.dart';
import '../../data/models/favorite_store_model.dart';
import '../providers/favorites_provider.dart';
import 'menu_option_page.dart';

enum StoreDetailPreset {
  jokbal,
  tteokbokki,
  burger,
  chicken,
  pizza,
  cafe,
  jjukkumi,
}

StoreDetailPreset _presetForStoreIdentity({
  required String storeName,
  required String storeSubtitle,
  required String heroImagePath,
  required StoreDetailPreset fallback,
}) {
  final identity = '$storeName $heroImagePath'.toLowerCase();
  final value = '$identity $storeSubtitle'.toLowerCase();

  if (_containsAnyText(identity, const [
    'ediya',
    'coffee',
    'cafe',
    'bombom',
    'bback',
    'dabang',
  ])) {
    return StoreDetailPreset.cafe;
  }
  if (_containsAnyText(value, const ['tteokbokki', 'ddukbokki'])) {
    return StoreDetailPreset.tteokbokki;
  }
  if (_containsAnyText(value, const ['burger', 'lotteria', 'bongus'])) {
    return StoreDetailPreset.burger;
  }
  if (_containsAnyText(value, const [
    'chicken',
    'bhc',
    'bbq',
    'nene',
    'goobne',
    'gupne',
    'puradak',
  ])) {
    return StoreDetailPreset.chicken;
  }
  if (_containsAnyText(value, const ['pizza', 'domino'])) {
    return StoreDetailPreset.pizza;
  }
  if (_containsAnyText(value, const [
    'coffee',
    'cafe',
    'bombom',
    'bback',
    'dabang',
  ])) {
    return StoreDetailPreset.cafe;
  }
  if (_containsAnyText(value, const ['jjukkumi'])) {
    return StoreDetailPreset.jjukkumi;
  }

  return fallback;
}

bool _containsAnyText(String value, List<String> tokens) {
  return tokens.any(value.contains);
}

class StoreDetailPage extends StatefulWidget {
  final int? storeId;
  final bool? syncFavoriteRemote;
  final String storeName;
  final String storeSubtitle;
  final String heroImagePath;
  final String logoImagePath;
  final StoreDetailPreset preset;
  final String rating;
  final String reviewCount;
  final String deliveryTime;
  final int? bottomNavIndex;

  const StoreDetailPage({
    super.key,
    this.storeId,
    this.syncFavoriteRemote,
    required this.storeName,
    required this.storeSubtitle,
    required this.heroImagePath,
    required this.logoImagePath,
    this.preset = StoreDetailPreset.jokbal,
    this.rating = '5.0',
    this.reviewCount = '(2,002)',
    this.deliveryTime = '25~40min',
    this.bottomNavIndex,
  });

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isUpdatingFavorite = false;
  StoreService? _storeService;
  int? _resolvedStoreId;
  List<NaruMenu> _remoteMenus = const [];
  List<NaruReview> _remoteReviews = const [];
  bool _isLoadingRemoteData = false;

  StoreDetailPreset get _effectivePreset => _presetForStoreIdentity(
        storeName: widget.storeName,
        storeSubtitle: widget.storeSubtitle,
        heroImagePath: widget.heroImagePath,
        fallback: widget.preset,
      );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initRemoteData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreHistoryProvider>().recordViewedStore(
            storeId: widget.storeId,
            name: widget.storeName,
            description: widget.storeSubtitle,
            imageUrl: widget.heroImagePath,
            rating: double.tryParse(widget.rating) ?? 0,
            reviewCount: _reviewCountValue,
          );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initRemoteData() async {
    final api = await ApiClient.getInstance();
    if (!mounted) return;
    _storeService = StoreService(api);
    _resolvedStoreId = widget.storeId ?? await _findStoreIdByName();
    await _loadRemoteData();
  }

  Future<void> _loadRemoteData() async {
    final service = _storeService;
    final storeId = _resolvedStoreId;
    if (service == null || storeId == null || _isLoadingRemoteData) return;
    setState(() => _isLoadingRemoteData = true);
    try {
      final results = await Future.wait([
        service.fetchMenus(storeId),
        service.fetchReviews(storeId),
      ]);
      if (!mounted) return;
      setState(() {
        _remoteMenus = results[0] as List<NaruMenu>;
        _remoteReviews = results[1] as List<NaruReview>;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _remoteMenus = const [];
        _remoteReviews = const [];
      });
    } finally {
      if (mounted) setState(() => _isLoadingRemoteData = false);
    }
  }

  Future<int?> _findStoreIdByName() async {
    final service = _storeService;
    if (service == null) return null;

    final queries = <String>[
      widget.storeName,
      ...widget.storeName
          .split(RegExp(r'\s+'))
          .where((word) => word.length > 2),
    ];

    for (final query in queries) {
      try {
        final stores = await service.searchStores(query);
        final matched = _bestStoreMatch(stores);
        if (matched != null && matched.id != 0) return matched.id;
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  NaruStore? _bestStoreMatch(List<NaruStore> stores) {
    if (stores.isEmpty) return null;
    final target = widget.storeName.toLowerCase();
    for (final store in stores) {
      final name = store.name.toLowerCase();
      if (name == target || name.contains(target) || target.contains(name)) {
        return store;
      }
    }
    return stores.first;
  }

  List<NaruMenu> _remoteMenusForPreset(StoreDetailPreset preset) {
    if (_remoteMenus.isEmpty) return const [];
    if (preset != StoreDetailPreset.cafe) return _remoteMenus;

    return _remoteMenus.where(_isCafeMenu).toList();
  }

  bool _isCafeMenu(NaruMenu menu) {
    final value =
        '${menu.name} ${menu.description} ${menu.imageUrl ?? ''}'.toLowerCase();
    if (_containsAnyText(value, const [
      'pizza',
      'pepperoni',
      'domino',
      'tteokbokki',
      'ddukbokki',
      'jokbal',
      'bossam',
      'chicken',
      'burger',
      'jjukkumi',
    ])) {
      return false;
    }

    return _containsAnyText(value, const [
      'coffee',
      'americano',
      'latte',
      'ade',
      'tea',
      'mocha',
      'espresso',
      'cold brew',
      'smoothie',
      'frappe',
      'milk tea',
      'juice',
      'dessert',
      'cake',
      'bread',
      'cookie',
      'croffle',
    ]);
  }

  int get _reviewCountValue {
    final digits = widget.reviewCount.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      bottomNavigationBar: widget.bottomNavIndex == null
          ? null
          : NaruBottomNavBar(currentIndex: widget.bottomNavIndex!),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStoreHeader(),
                _buildDeliveryTabs(),
                _buildDeliveryInfo(),
                const Divider(
                    height: 1, thickness: 8, color: Color(0xFFF3F5F7)),
                _buildPopularMenu(),
                const Divider(
                    height: 1, thickness: 8, color: Color(0xFFF3F5F7)),
                _buildAllergySection(),
                const Divider(
                    height: 1, thickness: 8, color: Color(0xFFF3F5F7)),
                _buildReviewSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.bgWhite,
      leading: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              size: 16, color: AppColors.textPrimary),
        ),
      ),
      actions: [
        Consumer<FavoritesProvider>(
          builder: (context, favoritesProvider, _) {
            final favoriteStoreId = _favoriteStoreId;
            final isLiked = favoritesProvider.isFavorite(favoriteStoreId);

            return GestureDetector(
              onTap: _isUpdatingFavorite
                  ? null
                  : () => _toggleFavorite(favoritesProvider),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: isLiked
                      ? AppColors.accentOrange
                      : AppColors.textSecondary,
                ),
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _storeHeroImage(widget.heroImagePath),
      ),
    );
  }

  Widget _storeHeroImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, fit: BoxFit.cover);
    }
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.bgLight,
        alignment: Alignment.center,
        child: const Icon(Icons.store, color: AppColors.textMuted),
      ),
    );
  }

  int get _favoriteStoreId {
    return widget.storeId ?? _localStoreId(widget.storeName);
  }

  Future<void> _toggleFavorite(FavoritesProvider favoritesProvider) async {
    setState(() => _isUpdatingFavorite = true);
    await favoritesProvider.toggle(
      FavoriteStoreModel(
        storeId: _favoriteStoreId,
        name: widget.storeName,
        imageUrl: widget.heroImagePath,
        rating: double.tryParse(widget.rating) ?? 0,
        reviewCount: _reviewCountNumber,
        categoryName: widget.storeSubtitle,
        syncRemote: _syncFavoriteRemote,
      ),
    );
    if (!mounted) return;
    setState(() => _isUpdatingFavorite = false);
  }

  bool get _syncFavoriteRemote {
    return widget.syncFavoriteRemote ?? widget.storeId != null;
  }

  int get _reviewCountNumber {
    final digits = widget.reviewCount.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  int _localStoreId(String value) {
    var hash = 17;
    for (final codeUnit in value.codeUnits) {
      hash = (hash * 37 + codeUnit) & 0x3fffffff;
    }
    return hash == 0 ? 1 : hash;
  }

  Widget _buildStoreHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.storeName,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFFC107), size: 16),
                    const SizedBox(width: 3),
                    Text(
                      widget.rating,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      widget.reviewCount,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTabs() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.textPrimary,
      unselectedLabelColor: AppColors.inactive,
      indicatorColor: AppColors.textPrimary,
      indicatorWeight: 2,
      labelStyle: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      tabs: const [
        Tab(text: 'Delivery'),
        Tab(text: 'Pick up'),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Minimum Order', '₩15,000'),
          const SizedBox(height: 6),
          _infoRow('Store Delivery', widget.deliveryTime),
          const SizedBox(height: 6),
          const Text(
            'Free Delivery Fee',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        if (label.isNotEmpty)
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        Text(
          CurrencyFormatter.krwTextToUsd(value),
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPopularMenu() {
    final effectivePreset = _effectivePreset;
    final remoteMenus = _remoteMenusForPreset(effectivePreset);
    final menus = remoteMenus.isNotEmpty
        ? remoteMenus.asMap().entries.map((entry) {
            final menu = entry.value;
            return _MenuItem(
              menuId: menu.id,
              rank: entry.key == 0 ? 'Top 1' : 'Menu ${entry.key + 1}',
              name: menu.name,
              description: menu.description,
              options: ['Menu price: ₩${menu.price}'],
              imagePath: menu.displayImage,
              price: menu.price,
              allergyNotice: menu.allergyNotice,
            );
          }).toList()
        : _menusForPreset(effectivePreset);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Menu',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'This is a highly rated menu item',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoadingRemoteData)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          ...menus.asMap().entries.map((e) => _MenuItemRow(
                item: e.value,
                isLast: e.key == menus.length - 1,
                storeId: widget.storeId,
                storeName: widget.storeName,
                storeImagePath: widget.heroImagePath,
                isPickupGetter: () => _tabController.index == 1,
              )),
        ],
      ),
    );
  }

  List<_MenuItem> _menusForPreset(StoreDetailPreset preset) {
    switch (preset) {
      case StoreDetailPreset.burger:
        return const [
          _MenuItem(
            rank: 'Top 1',
            name: 'Bulgogi Burger Set',
            description: 'Burger + Fries + Soft drink',
            options: [
              'Single set: ₩8,900',
              'Double set: ₩11,900',
              'Family pack: ₩24,000',
            ],
            imagePath: 'assets/images/franchise_lotteria_bg.png',
          ),
          _MenuItem(
            rank: 'Top 2',
            name: 'Cheese Burger',
            description: 'Beef patty + Cheese + Pickle',
            options: [
              'Burger only: ₩5,900',
              'Regular set: ₩8,400',
              'Large set: ₩9,400',
            ],
            imagePath: 'assets/images/cat_fastfood.png',
          ),
          _MenuItem(
            rank: 'Top 3',
            name: 'Shrimp Burger',
            description: 'Crispy shrimp patty + Tartar sauce',
            options: [
              'Burger only: ₩6,500',
              'Regular set: ₩9,000',
              'Large set: ₩10,000',
            ],
            imagePath: 'assets/images/franchise_lotteria_bg.png',
          ),
        ];
      case StoreDetailPreset.chicken:
        return const [
          _MenuItem(
            rank: 'Top 1',
            name: 'Original Fried Chicken',
            description: 'Crispy fried chicken + Pickled radish',
            options: [
              'Half chicken: ₩12,000',
              'Whole chicken: ₩21,000',
              'Boneless: ₩23,000',
            ],
            imagePath: 'assets/images/franchise_nene_bg.png',
          ),
          _MenuItem(
            rank: 'Top 2',
            name: 'Sweet Spicy Chicken',
            description: 'Fried chicken + Korean spicy sauce',
            options: [
              'Half chicken: ₩13,000',
              'Whole chicken: ₩22,000',
              'Boneless: ₩24,000',
            ],
            imagePath: 'assets/images/cat_chicken_single.png',
          ),
          _MenuItem(
            rank: 'Top 3',
            name: 'Soy Garlic Chicken',
            description: 'Crispy chicken + Soy garlic glaze',
            options: [
              'Half chicken: ₩13,000',
              'Whole chicken: ₩22,000',
              'Boneless: ₩24,000',
            ],
            imagePath: 'assets/images/franchise_nene_bg.png',
          ),
        ];
      case StoreDetailPreset.pizza:
        return const [
          _MenuItem(
            rank: 'Top 1',
            name: 'Signature Cheese Pizza',
            description: 'Mozzarella + Tomato sauce + Herbs',
            options: [
              'Medium: ₩18,900',
              'Large: ₩24,900',
              'Family: ₩31,900',
            ],
            imagePath: 'assets/images/franchise_domino_bg.png',
          ),
          _MenuItem(
            rank: 'Top 2',
            name: 'Pepperoni Pizza',
            description: 'Pepperoni + Cheese + Tomato sauce',
            options: [
              'Medium: ₩20,900',
              'Large: ₩26,900',
              'Family: ₩33,900',
            ],
            imagePath: 'assets/images/franchise_domino_bg.png',
          ),
          _MenuItem(
            rank: 'Top 3',
            name: 'Potato Bacon Pizza',
            description: 'Potato + Bacon + Cheese sauce',
            options: [
              'Medium: ₩21,900',
              'Large: ₩27,900',
              'Family: ₩34,900',
            ],
            imagePath: 'assets/images/franchise_domino_bg.png',
          ),
        ];
      case StoreDetailPreset.cafe:
        return const [
          _MenuItem(
            rank: 'Top 1',
            name: 'Iced Americano',
            description: 'Espresso + Ice water',
            options: [
              'Regular: ₩3,500',
              'Large: ₩4,000',
              'Extra shot: + ₩500',
            ],
            imagePath: 'assets/images/food_cafe.png',
            price: 3500,
          ),
          _MenuItem(
            rank: 'Top 2',
            name: 'Cafe Latte',
            description: 'Espresso + Steamed milk',
            options: [
              'Regular: ₩4,500',
              'Large: ₩5,000',
              'Oat milk: + ₩700',
            ],
            imagePath: 'assets/images/food_cafe.png',
            price: 4500,
          ),
          _MenuItem(
            rank: 'Top 3',
            name: 'Grapefruit Ade',
            description: 'Grapefruit + Sparkling water',
            options: [
              'Regular: ₩5,200',
              'Large: ₩5,900',
              'Extra fruit: + ₩800',
            ],
            imagePath: 'assets/images/food_cafe.png',
            price: 5200,
          ),
        ];
      case StoreDetailPreset.jjukkumi:
        return const [
          _MenuItem(
            rank: 'Top 1',
            name: 'Spicy Jjukkumi Set',
            description: 'Jjukkumi + Bean sprouts + Spicy sauce',
            options: [
              'Small (1~2 servings): ₩24,000',
              'Medium (2~3 servings): ₩32,000',
              'Large (3~4 servings): ₩42,000',
            ],
            imagePath: 'assets/images/banner_food.png',
          ),
          _MenuItem(
            rank: 'Top 2',
            name: 'Cheese Jjukkumi',
            description: 'Jjukkumi + Mozzarella + Rice cake',
            options: [
              'Small (1~2 servings): ₩27,000',
              'Medium (2~3 servings): ₩35,000',
              'Large (3~4 servings): ₩45,000',
            ],
            imagePath: 'assets/images/banner_food.png',
          ),
          _MenuItem(
            rank: 'Top 3',
            name: 'Jjukkumi Fried Rice',
            description: 'Rice + Seaweed + Spicy jjukkumi sauce',
            options: [
              'Single: ₩5,000',
              'Double: ₩9,000',
              'Add cheese: + ₩2,000',
            ],
            imagePath: 'assets/images/banner_food.png',
          ),
        ];
      case StoreDetailPreset.tteokbokki:
        return const [
          _MenuItem(
            rank: 'Top 1',
            name: 'Original Tteokbokki',
            description: 'Rice cake + Fish cake + Spicy sauce',
            options: [
              'Small (1~2 servings): ₩14,000',
              'Medium (2~3 servings): ₩18,000',
              'Large (3~4 servings): ₩24,000',
            ],
            imagePath: 'assets/images/food_tteokbokki.png',
          ),
          _MenuItem(
            rank: 'Top 2',
            name: 'Rosé Tteokbokki',
            description: 'Rice cake + Cream sauce + Sausage',
            options: [
              'Small (1~2 servings): ₩16,000',
              'Medium (2~3 servings): ₩21,000',
              'Large (3~4 servings): ₩27,000',
            ],
            imagePath: 'assets/images/food_tteokbokki.png',
          ),
          _MenuItem(
            rank: 'Top 3',
            name: 'Mala Tteokbokki',
            description: 'Rice cake + Mala sauce + Vegetables',
            options: [
              'Small (1~2 servings): ₩15,000',
              'Medium (2~3 servings): ₩20,000',
              'Large (3~4 servings): ₩26,000',
            ],
            imagePath: 'assets/images/banner_food.png',
          ),
          _MenuItem(
            rank: 'Set Menu',
            name: 'Tteokbokki Set',
            description: 'Tteokbokki + Fries + Rice balls',
            options: [
              'Basic set: ₩23,000',
              'Cheese set: ₩26,000',
              'Family set: ₩32,000',
            ],
            imagePath: 'assets/images/food_tteokbokki.png',
          ),
        ];
      case StoreDetailPreset.jokbal:
        return const [
          _MenuItem(
            rank: 'Top 1',
            name: 'Half [Jok, Bo Set]',
            description: 'Makguksu + Kimchi + Onion + Ssam',
            options: [
              'Small (2~3 servings): ₩38,000',
              'Medium (3~4 servings): ₩48,000',
              'Large (4~5 servings): ₩58,000',
            ],
            imagePath: 'assets/images/food_jokbal.png',
          ),
          _MenuItem(
            rank: 'Top 2',
            name: 'Bossam',
            description: 'Makguksu + Kimchi + Radish + Ssam',
            options: [
              'Small (2~3 servings): ₩28,000',
              'Medium (3~4 servings): ₩38,000',
              'Large (4~5 servings): ₩48,000',
            ],
            imagePath: 'assets/images/food_jokbal.png',
          ),
          _MenuItem(
            rank: 'Top 3',
            name: 'Jokbal',
            description: 'Makguksu + Kimchi + Radish + Ssam',
            options: [
              'Small (2~3 servings): ₩34,000',
              'Medium (3~4 servings): ₩39,000',
              'Large (4~5 servings): ₩45,000',
            ],
            imagePath: 'assets/images/food_jokbal.png',
          ),
          _MenuItem(
            rank: 'Mini Jokbo',
            name: 'Mini Jokbo',
            description: 'Makguksu + Kimchi + Onion + Ssam',
            options: [
              'Small (2~3 servings): ₩22,000',
              'Medium (3~4 servings): ₩32,000',
              'Large (4~5 servings): ₩42,000',
            ],
            imagePath: 'assets/images/food_jokbal.png',
          ),
        ];
    }
  }

  Widget _buildAllergySection() {
    const allergens = [
      _Allergen(
        label: 'Peanut',
        sublabel: 'For topping',
        assetPath: 'assets/images/peanut.png',
      ),
      _Allergen(
        label: 'Tomato',
        sublabel: 'For salad',
        assetPath: 'assets/images/tomato.png',
      ),
      _Allergen(
        label: 'Milk',
        sublabel: 'For ripening',
        assetPath: 'assets/images/milk.png',
      ),
      _Allergen(
        label: 'Meat',
        sublabel: 'For all menu',
        assetPath: 'assets/images/meat.png',
      ),
      _Allergen(
        label: 'Egg',
        sublabel: 'For bread',
        assetPath: 'assets/images/egg.png',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Caution of Allergic',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Chinese check the allergy information before ordering',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: allergens
                .map((allergen) => _AllergenBadge(allergen: allergen))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    final effectivePreset = _effectivePreset;
    final reviewImage = _reviewImageForPreset(effectivePreset);
    final reviewTexts = _reviewTextsForPreset(effectivePreset);
    final remoteReviews = _remoteReviews
        .where((review) => review.imageUrl?.trim().isNotEmpty ?? false)
        .take(3)
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.rating,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(5, (i) {
                  final val = 5 - i;
                  final width = val == 5
                      ? 80.0
                      : val == 4
                          ? 20.0
                          : 8.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        Text(
                          '$val.0',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: width,
                          height: 6,
                          decoration: BoxDecoration(
                            color: val == 5
                                ? AppColors.brandOrange
                                : const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoadingRemoteData)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (remoteReviews.isNotEmpty)
            ...remoteReviews.map(
              (review) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _ReviewCard(
                  name: review.userName,
                  rating: review.rating,
                  flag: _flagForCountry(review.country),
                  timeAgo: review.timeAgo,
                  text: review.content,
                  imagePath: review.imageUrl!,
                ),
              ),
            )
          else ...[
            _ReviewCard(
              name: 'Jake',
              flag: 'US',
              timeAgo: 'last week',
              text: reviewTexts.first,
              imagePath: reviewImage,
            ),
            const SizedBox(height: 20),
            _ReviewCard(
              name: 'Kimana',
              flag: 'KR',
              timeAgo: 'last week',
              text: reviewTexts.last,
              imagePath: reviewImage,
            ),
          ],
        ],
      ),
    );
  }

  String _flagForCountry(String? country) {
    final rawCountry = country?.trim() ?? '';
    final normalizedCountry = rawCountry.toUpperCase();

    switch (normalizedCountry) {
      case 'KR':
      case 'KOR':
      case 'KOREA':
      case 'SOUTH KOREA':
      case 'REPUBLIC OF KOREA':
      case '대한민국':
      case '한국':
      case '🇰🇷':
        return 'KR';
      case 'US':
      case 'USA':
      case 'AMERICA':
      case 'UNITED STATES':
      case 'UNITED STATES OF AMERICA':
      case '미국':
      case '🇺🇸':
        return 'US';
      case 'JP':
      case 'JPN':
      case 'JAPAN':
      case '🇯🇵':
        return 'JP';
      case 'CN':
      case 'CHN':
      case 'CHINA':
      case '🇨🇳':
        return 'CN';
      default:
        final lettersOnly = normalizedCountry.replaceAll(RegExp(r'[^A-Z]'), '');
        if (lettersOnly.length >= 2) return lettersOnly.substring(0, 2);
        return 'GL';
    }
  }

  String _reviewImageForPreset(StoreDetailPreset preset) {
    switch (preset) {
      case StoreDetailPreset.jokbal:
        return 'assets/images/food_jokbal.png';
      case StoreDetailPreset.tteokbokki:
        return 'assets/images/food_tteokbokki.png';
      case StoreDetailPreset.burger:
        return 'assets/images/franchise_lotteria_bg.png';
      case StoreDetailPreset.chicken:
        return 'assets/images/franchise_nene_bg.png';
      case StoreDetailPreset.pizza:
        return 'assets/images/franchise_domino_bg.png';
      case StoreDetailPreset.cafe:
        return 'assets/images/food_cafe.png';
      case StoreDetailPreset.jjukkumi:
        return 'assets/images/banner_food.png';
    }
  }

  List<String> _reviewTextsForPreset(StoreDetailPreset preset) {
    switch (preset) {
      case StoreDetailPreset.jokbal:
        return const [
          'I was making fresh kimchi at home, so I ordered jokbal too~ 😄 I ordered the medium size, and the portion was huge. The bossam and jokbal were so tender—they melted in my mouth. So delicious!',
          'The portion was generous and everything arrived warm. The meat was tender and flavorful—definitely ordering again!',
        ];
      case StoreDetailPreset.tteokbokki:
        return const [
          'The tteokbokki was spicy, chewy, and perfect with the rice balls. The sauce stayed warm and rich until the last bite.',
          'Great balance of sweetness and heat. The portion was generous and the fish cake was really good.',
        ];
      case StoreDetailPreset.burger:
        return const [
          'The burger set arrived hot and the fries were still crispy. It was exactly the quick comfort food I wanted.',
          'The bulgogi sauce was sweet and savory, and the portion was perfect for lunch.',
        ];
      case StoreDetailPreset.chicken:
        return const [
          'The chicken was crispy outside and juicy inside. The sauce was packed separately, so it stayed fresh.',
          'Great for sharing. Everything arrived warm and the pickled radish made it even better.',
        ];
      case StoreDetailPreset.pizza:
        return const [
          'The cheese pull was great and the crust was crisp. It arrived faster than expected.',
          'The toppings were generous and the pizza was still warm when it arrived. Ordering again soon.',
        ];
      case StoreDetailPreset.cafe:
        return const [
          'The coffee was smooth and still cold when it arrived. Perfect afternoon pick-me-up.',
          'The ade tasted fresh and not too sweet. Great spot for quick drinks nearby.',
        ];
      case StoreDetailPreset.jjukkumi:
        return const [
          'The jjukkumi was spicy in the best way, and the portion was generous. It paired perfectly with rice.',
          'Fresh, bold, and full of flavor. The sauce was rich and everything arrived hot.',
        ];
    }
  }
}

class _MenuItemRow extends StatelessWidget {
  final _MenuItem item;
  final bool isLast;
  final int? storeId;
  final String storeName;
  final String storeImagePath;
  final bool Function() isPickupGetter;

  const _MenuItemRow({
    required this.item,
    required this.isLast,
    required this.storeId,
    required this.storeName,
    required this.storeImagePath,
    required this.isPickupGetter,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MenuOptionPage(
            menuId: item.menuId,
            storeId: storeId,
            storeName: storeName,
            storeImagePath: storeImagePath,
            basePrice: item.price,
            rank: item.rank,
            menuName: item.name,
            description: item.description,
            imagePath: item.imagePath,
            initialIsPickup: isPickupGetter(),
          ),
        ),
      ),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.rank.startsWith('Top') ? item.rank : item.rank,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: item.rank.startsWith('Top')
                          ? AppColors.brandOrange
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...item.options.map(
                    (opt) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '• ${CurrencyFormatter.krwTextToUsd(opt)}',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _DetailImage(
                imagePath: item.imagePath,
                width: 80,
                height: 80,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllergenBadge extends StatelessWidget {
  final _Allergen allergen;

  const _AllergenBadge({required this.allergen});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      height: 157,
      child: Container(
        padding: const EdgeInsets.fromLTRB(11, 11, 11, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFCFCF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.textPrimary, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.textPrimary, width: 1.2),
              ),
              alignment: Alignment.center,
              child: Image.asset(
                allergen.assetPath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              allergen.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              allergen.sublabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final int rating;
  final String flag;
  final String timeAgo;
  final String text;
  final String imagePath;

  const _ReviewCard({
    required this.name,
    this.rating = 5,
    required this.flag,
    required this.timeAgo,
    required this.text,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE0E0E0),
              child: Text(
                name[0],
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _CountryFlag(code: flag),
                  ],
                ),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        Icons.star_rounded,
                        color: index < rating
                            ? const Color(0xFFFFC107)
                            : const Color(0xFFE5E5E5),
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (text.trim().isNotEmpty) ...[
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _DetailImage(
            imagePath: imagePath,
            height: 130,
            width: double.infinity,
          ),
        ),
      ],
    );
  }
}

class _CountryFlag extends StatelessWidget {
  final String code;

  const _CountryFlag({required this.code});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Container(
        width: 22,
        height: 15,
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          border: Border.all(color: const Color(0xFFD8D8D8), width: 0.6),
          borderRadius: BorderRadius.circular(2),
        ),
        child: SvgPicture.asset(
          _flagAssetFor(code),
          width: 22,
          height: 15,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  String _flagAssetFor(String value) {
    switch (value.trim().toUpperCase()) {
      case 'KR':
        return 'assets/images/flag_kr.svg';
      case 'US':
        return 'assets/images/flag_us.svg';
      case 'JP':
        return 'assets/images/flag_jp.svg';
      case 'CN':
        return 'assets/images/flag_cn.svg';
      default:
        return 'assets/images/flag_global.svg';
    }
  }
}

class _MenuItem {
  final int? menuId;
  final String rank;
  final String name;
  final String description;
  final List<String> options;
  final String imagePath;
  final int? price;
  final String? allergyNotice;

  const _MenuItem({
    this.menuId,
    required this.rank,
    required this.name,
    required this.description,
    required this.options,
    required this.imagePath,
    this.price,
    this.allergyNotice,
  });
}

class _DetailImage extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;

  const _DetailImage({
    required this.imagePath,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath,
          width: width, height: height, fit: BoxFit.cover);
    }
    return Image.network(
      imagePath,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: AppColors.bgLight,
        alignment: Alignment.center,
        child: const Icon(Icons.fastfood, color: AppColors.textMuted),
      ),
    );
  }
}

class _Allergen {
  final String label;
  final String sublabel;
  final String assetPath;

  const _Allergen({
    required this.label,
    required this.sublabel,
    required this.assetPath,
  });
}
