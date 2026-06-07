import 'dart:async';
import 'dart:math' as math;
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/main_tab_page.dart';
import '../../../cart/presentation/pages/cart_list_page.dart';
import '../../../likes/presentation/pages/store_detail_page.dart';
import '../../../likes/presentation/providers/favorites_provider.dart';
import '../../data/category_dummy_data.dart';
import '../../domain/category_model.dart';
import '../widgets/delivery_pickup_tab.dart';
import 'category_detail_page.dart';
import 'search_page.dart';

class HomeDeliveryPage extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const HomeDeliveryPage({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  State<HomeDeliveryPage> createState() => _HomeDeliveryPageState();
}

class _HomeLocationLabel {
  static const fallback = 'Sillim-dong···';
  static String? _cachedLabel;
  static Future<String>? _inFlight;

  static Future<String> resolve({bool forceRefresh = false}) {
    final pending = _inFlight;
    if (pending != null) return pending;

    if (!forceRefresh) {
      final cached = _cachedLabel;
      if (cached != null) return Future.value(cached);
    }

    final future = _resolve().then((label) {
      if (label != fallback) {
        _cachedLabel = label;
      }
      return label;
    }).whenComplete(() => _inFlight = null);

    _inFlight = future;
    return future;
  }

  static Future<String> _resolve() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return fallback;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return fallback;
      }

      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      final position = lastKnownPosition ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 8),
            ),
          );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) return fallback;

      final locationName = _formatLocationName(placemarks.first);
      if (locationName.isEmpty) return fallback;
      return '$locationName···';
    } catch (_) {
      return fallback;
    }
  }

  static String _formatLocationName(Placemark placemark) {
    return _joinUnique([
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.subAdministrativeArea,
      placemark.administrativeArea,
    ]);
  }

  static String _joinUnique(List<String?> values) {
    final normalized = <String>[];
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) continue;
      if (normalized.contains(trimmed)) continue;
      normalized.add(trimmed);
    }
    return normalized.join(', ');
  }
}

class _HomeDeliveryPageState extends State<HomeDeliveryPage>
    with WidgetsBindingObserver {
  final _pageController = PageController();
  int _bannerPage = 0;
  Timer? _bannerTimer;
  String _locationLabel = _HomeLocationLabel.fallback;
  ValueNotifier<int>? _mainTabNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLocationLabel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().fetch();
    });
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted ||
          !_pageController.hasClients ||
          widget.selectedIndex != 0) {
        return;
      }
      final next = (_bannerPage + 1) % 3;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = MainTabScope.of(context);
    if (_mainTabNotifier == notifier) return;

    _mainTabNotifier?.removeListener(_handleMainTabChanged);
    _mainTabNotifier = notifier;
    _mainTabNotifier?.addListener(_handleMainTabChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mainTabNotifier?.removeListener(_handleMainTabChanged);
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadLocationLabel(forceRefresh: true);
    }
  }

  void _handleMainTabChanged() {
    if (_mainTabNotifier?.value == 0) {
      _loadLocationLabel(forceRefresh: true);
    }
  }

  Future<void> _loadLocationLabel({bool forceRefresh = false}) async {
    final label = await _HomeLocationLabel.resolve(forceRefresh: forceRefresh);
    if (!mounted) return;
    setState(() => _locationLabel = label);
  }

  @override
  Widget build(BuildContext context) {
    final isPickupMode = widget.selectedIndex == 1;

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          color: AppColors.accentOrange,
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _locationLabel,
                                  style: AppTextStyles.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Transform.rotate(
                                angle: math.pi / 2,
                                child: SvgPicture.asset(
                                  'assets/images/ic_right_small.svg',
                                  width: 8,
                                  height: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SvgPicture.asset(
                        'assets/images/ic_search_header.svg',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CartListPage(),
                          ),
                        ),
                        child: SvgPicture.asset(
                          'assets/images/ic_cart.svg',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchPage(
                          initialTabIndex: widget.selectedIndex,
                        ),
                      ),
                    ),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(39),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 0, 16, 0),
                      child: Row(
                        children: [
                          Text(
                            'Search name of food',
                            style: AppTextStyles.body
                                .copyWith(color: const Color(0xFF7B7B7B)),
                          ),
                          const Spacer(),
                          SvgPicture.asset(
                            'assets/images/ic_search_bar.svg',
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 144,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _bannerPage = i),
                    itemCount: 3,
                    itemBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: _BannerCard(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (i) => Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color:
                            _bannerPage == i ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeliveryPickupTab(
                selectedIndex: widget.selectedIndex,
                onChanged: widget.onTabChanged,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: isPickupMode
                    ? const _PickupBrandGrid()
                    : const _CategoryGrid(),
              ),
              const SizedBox(height: 16),
              Container(height: 10, color: AppColors.bgLight),
              // Recently Ordered Stores
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _SectionHeader(
                  title: 'Recently Ordered Stores',
                  subtitle: 'You can order Again',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    _StoreCard(
                      storeId: 2,
                      imagePath: 'assets/images/food_tteokbokki.png',
                      name: 'Yupki Ddukbokki Sillim',
                      storeSubtitle: 'Spicy Korean street food',
                      preset: StoreDetailPreset.tteokbokki,
                      rating: '4.9',
                      time: '20min',
                      tags: ['pick up', 'new'],
                    ),
                    SizedBox(width: 14),
                    _StoreCard(
                      storeId: 1,
                      imagePath: 'assets/images/food_jokbal.png',
                      name: 'Simin Jokbal & Bossam',
                      detailName: 'Simin Jokbal Bossam Sillim',
                      storeSubtitle: 'Korean jokbal and bossam',
                      preset: StoreDetailPreset.jokbal,
                      rating: '5.0',
                      time: '40min',
                      tags: ['pick up', 'new'],
                    ),
                    SizedBox(width: 14),
                    _StoreCard(
                      storeId: 1,
                      imagePath: 'assets/images/food_jokbal.png',
                      name: 'Simin Jokbal & Bossam',
                      detailName: 'Simin Jokbal Bossam Sillim',
                      storeSubtitle: 'Korean jokbal and bossam',
                      preset: StoreDetailPreset.jokbal,
                      rating: '5.0',
                      time: '40min',
                      tags: ['pick up', 'new'],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(height: 10, color: AppColors.bgLight),
              // Stores with Free Delivery
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _SectionHeader(
                  title: 'Stores with Free Delivery',
                  subtitle: 'Order now for \$0.00 delivery',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 286,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    _FreeDeliveryCard(),
                    SizedBox(width: 14),
                    _FreeDeliveryCard(),
                    SizedBox(width: 14),
                    _FreeDeliveryCard(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(height: 10, color: AppColors.bgLight),
              // Popular Franchises
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x21FB461F), Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: _SectionHeader(
                        title: 'Popular Franchises',
                        subtitle: 'Discover flavors you can trust',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 165,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: const [
                          _FranchiseCard(
                            category: 'Burger Chains',
                            name: 'Lotteria',
                            bgImage: 'assets/images/franchise_lotteria_bg.png',
                            logoImage:
                                'assets/images/franchise_lotteria_logo.png',
                            preset: StoreDetailPreset.burger,
                            rating: '4.8',
                            time: '25min',
                          ),
                          SizedBox(width: 6),
                          _FranchiseCard(
                            category: 'Chicken Chains',
                            name: 'Nene Chicken',
                            bgImage: 'assets/images/franchise_nene_bg.png',
                            logoImage: 'assets/images/franchise_nene_logo.png',
                            preset: StoreDetailPreset.chicken,
                            rating: '4.9',
                            time: '30min',
                          ),
                          SizedBox(width: 6),
                          _FranchiseCard(
                            category: 'Pizza Chains',
                            name: 'Domino',
                            bgImage: 'assets/images/franchise_domino_bg.png',
                            logoImage:
                                'assets/images/franchise_domino_logo.png',
                            preset: StoreDetailPreset.pizza,
                            rating: '4.7',
                            time: '35min',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Container(height: 10, color: AppColors.bgLight),
              // Cafés Near You
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _SectionHeader(
                  title: 'Cafés Near You',
                  subtitle: 'Grab a refreshing drink on your way home',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    _CafeCard(
                      name: 'Cafe Bombom Sillim',
                      subtitle: 'Fresh coffee and sweet drinks',
                      imagePath: 'assets/images/food_cafe.png',
                      rating: '5.0',
                      time: '15min',
                    ),
                    SizedBox(width: 14),
                    _CafeCard(
                      name: 'Bback Dabang sillim',
                      subtitle: 'Coffee and bakery near you',
                      imagePath: 'assets/images/food_cafe.png',
                      rating: '4.8',
                      time: '18min',
                    ),
                    SizedBox(width: 14),
                    _CafeCard(
                      name: 'Ediya Coffee Sillim',
                      subtitle: 'Coffee for pick up',
                      imagePath: 'assets/images/food_cafe.png',
                      rating: '4.7',
                      time: '16min',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Bottom promo banner
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: _PromoBanner(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 144,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 3,
            child: Image.asset(
              'assets/images/banner_food.png',
              width: 225,
              height: 138,
              fit: BoxFit.contain,
            ),
          ),
          const Positioned(
            left: 24,
            top: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bold, Spicy, and Full of Flavor',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Seoul Bangyidong\nJjukkumi House',
                  style: AppTextStyles.title,
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            top: 95,
            child: Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.circular(61),
              ),
              alignment: Alignment.center,
              child: const Text(
                'View More',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  static const _columns = 5;
  static const _columnGap = 6.0;
  static const _rowGap = 14.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rawItemWidth =
            (constraints.maxWidth - (_columnGap * (_columns - 1))) / _columns;
        final itemWidth = rawItemWidth > 0 ? rawItemWidth : 0.0;
        return Wrap(
          spacing: _columnGap,
          runSpacing: _rowGap,
          children: categoryDummyData
              .map(
                (category) => SizedBox(
                  width: itemWidth,
                  child: _CategoryItem(category: category),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _PickupBrandGrid extends StatelessWidget {
  const _PickupBrandGrid();

  static const _columns = 5;
  static const _columnGap = 10.0;
  static const _rowGap = 16.0;
  static const _items = [
    _PickupBrandData(
      label: 'BHC',
      imagePath: 'assets/images/cat_bhc.png',
      description: 'Pickup-ready BHC chicken stores near your current area.',
      items: [
        CategoryItemModel(
          name: 'BHC Chicken Sillim',
          image: 'assets/images/cat_bhc.png',
          description: 'Crispy chicken sets prepared quickly for pick up.',
        ),
        CategoryItemModel(
          name: 'BHC Hot Chicken',
          image: 'assets/images/cat_bhc.png',
          description: 'Spicy fried chicken and shareable sides.',
        ),
      ],
    ),
    _PickupBrandData(
      label: 'BBQ',
      imagePath: 'assets/images/cat_bbq.png',
      description: 'Golden olive chicken and BBQ favorites for pick up.',
      items: [
        CategoryItemModel(
          name: 'BBQ Chicken Sillim',
          image: 'assets/images/cat_bbq.png',
          description: 'Golden olive chicken packed for easy pickup.',
        ),
        CategoryItemModel(
          name: 'BBQ Spicy Chicken',
          image: 'assets/images/cat_bbq.png',
          description: 'Bold seasoned chicken with crispy texture.',
        ),
      ],
    ),
    _PickupBrandData(
      label: 'Gupne',
      imagePath: 'assets/images/cat_goobne.png',
      description: 'Oven-roasted chicken options available for pick up.',
      items: [
        CategoryItemModel(
          name: 'Goobne Chicken Sillim',
          image: 'assets/images/cat_goobne.png',
          description: 'Oven-roasted chicken with lighter flavor.',
        ),
        CategoryItemModel(
          name: 'Goobne Volcano Chicken',
          image: 'assets/images/cat_goobne.png',
          description: 'A spicy roasted chicken favorite.',
        ),
      ],
    ),
    _PickupBrandData(
      label: 'Bongus',
      imagePath: 'assets/images/cat_bongus.png',
      description: 'Rice burgers and quick meals you can grab nearby.',
      items: [
        CategoryItemModel(
          name: 'Bongus Rice Burger',
          image: 'assets/images/cat_bongus.png',
          description: 'Warm rice burgers for a quick pickup meal.',
        ),
        CategoryItemModel(
          name: 'Bongus Bulgogi Burger',
          image: 'assets/images/cat_bongus.png',
          description: 'Savory rice burger with bulgogi flavor.',
        ),
      ],
    ),
    _PickupBrandData(
      label: 'Bback',
      imagePath: 'assets/images/cat_Bback.png',
      description: 'Coffee and bakery drinks ready on your route.',
      items: [
        CategoryItemModel(
          name: 'Bback Dabang Sillim',
          image: 'assets/images/cat_Bback.png',
          description: 'Large coffees and cafe drinks for pick up.',
        ),
        CategoryItemModel(
          name: 'Bback Dabang Bakery',
          image: 'assets/images/cat_Bback.png',
          description: 'Coffee with simple bakery menus.',
        ),
      ],
    ),
    _PickupBrandData(
      label: 'Bombom',
      imagePath: 'assets/images/cat_bombom.png',
      description: 'Sweet cafe drinks and fruit beverages for pick up.',
      items: [
        CategoryItemModel(
          name: 'Cafe Bombom Sillim',
          image: 'assets/images/cat_bombom.png',
          description: 'Fruit drinks, lattes, and sweet cafe favorites.',
        ),
        CategoryItemModel(
          name: 'Cafe Bombom Dessert',
          image: 'assets/images/cat_bombom.png',
          description: 'Refreshing drinks with easy dessert cups.',
        ),
      ],
    ),
    _PickupBrandData(
      label: 'Puradak',
      imagePath: 'assets/images/cat_puradak.png',
      description: 'Premium chicken menus available for nearby pickup.',
      items: [
        CategoryItemModel(
          name: 'Puradak Chicken Sillim',
          image: 'assets/images/cat_puradak.png',
          description: 'Premium chicken with rich sauces.',
        ),
        CategoryItemModel(
          name: 'Puradak Black Chicken',
          image: 'assets/images/cat_puradak.png',
          description: 'Signature black sauce chicken for pick up.',
        ),
      ],
    ),
    _PickupBrandData(
      label: 'Ediya',
      imagePath: 'assets/images/cat_ediya.png',
      description: 'Reliable coffee and tea from Ediya locations nearby.',
      items: [
        CategoryItemModel(
          name: 'Ediya Coffee Sillim',
          image: 'assets/images/cat_ediya.png',
          description: 'Iced coffee and tea prepared for pick up.',
        ),
        CategoryItemModel(
          name: 'Ediya Coffee Dessert',
          image: 'assets/images/cat_ediya.png',
          description: 'Cafe drinks with simple dessert menus.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rawItemWidth =
            (constraints.maxWidth - (_columnGap * (_columns - 1))) / _columns;
        final itemWidth = rawItemWidth > 0 ? rawItemWidth : 0.0;
        final nearMeWidth = (itemWidth * 2) + _columnGap;

        return Wrap(
          spacing: _columnGap,
          runSpacing: _rowGap,
          children: [
            SizedBox(
              width: nearMeWidth,
              child: _PickupNearMeItem(
                height: itemWidth,
                category: _nearMeCategory,
              ),
            ),
            ..._items.map(
              (item) => SizedBox(
                width: itemWidth,
                child: _PickupBrandItem(
                  category: item.category,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static const _nearMeCategory = CategoryModel(
    id: 'pickup-near-me',
    title: 'Near Me',
    image: 'assets/images/cat_near_me.png',
    description: 'Pickup-friendly stores close to your current location.',
    items: [
      CategoryItemModel(
        name: 'Yupki Ddukbokki Sillim',
        image: 'assets/images/food_tteokbokki.png',
        description: 'Spicy tteokbokki with chewy rice cakes and fish cake.',
      ),
      CategoryItemModel(
        name: 'Simin Jokbal & Bossam',
        image: 'assets/images/food_jokbal.png',
        description: 'Tender jokbal and bossam plates for a filling meal.',
      ),
      CategoryItemModel(
        name: 'Cafe Bombom Sillim',
        image: 'assets/images/food_cafe.png',
        description: 'Sweet drinks, coffee, and refreshing dessert cups.',
      ),
    ],
  );
}

class _PickupBrandData {
  final String label;
  final String imagePath;
  final String description;
  final List<CategoryItemModel> items;

  const _PickupBrandData({
    required this.label,
    required this.imagePath,
    required this.description,
    required this.items,
  });

  CategoryModel get category => CategoryModel(
        id: 'pickup-${label.toLowerCase()}',
        title: label,
        image: imagePath,
        description: description,
        items: items,
      );
}

class _PickupNearMeItem extends StatelessWidget {
  final double height;
  final CategoryModel category;

  const _PickupNearMeItem({
    required this.height,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryDetailPage(category: category),
        ),
      ),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary),
        ),
        clipBehavior: Clip.hardEdge,
        child: Image.asset(
          'assets/images/cat_near_me.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _PickupBrandItem extends StatelessWidget {
  final CategoryModel category;

  const _PickupBrandItem({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryDetailPage(category: category),
        ),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary),
              ),
              clipBehavior: Clip.hardEdge,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  category.image,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.title,
            style: AppTextStyles.title.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryModel category;

  const _CategoryItem({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryDetailPage(category: category),
        ),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primary),
              ),
              clipBehavior: Clip.hardEdge,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  category.image,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category.title,
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        const SizedBox(height: 6),
        Text(subtitle,
            style: AppTextStyles.body.copyWith(color: const Color(0xFF7B7B7B))),
      ],
    );
  }
}

class _StoreCard extends StatelessWidget {
  final int? storeId;
  final String imagePath;
  final String name;
  final String? detailName;
  final String storeSubtitle;
  final StoreDetailPreset preset;
  final String rating;
  final String time;
  final List<String> tags;

  const _StoreCard({
    this.storeId,
    required this.imagePath,
    required this.name,
    this.detailName,
    required this.storeSubtitle,
    required this.preset,
    required this.rating,
    required this.time,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StoreDetailPage(
            storeId: storeId,
            storeName: detailName ?? name,
            storeSubtitle: storeSubtitle,
            heroImagePath: imagePath,
            logoImagePath: imagePath,
            preset: preset,
            rating: rating,
            deliveryTime: time,
            bottomNavIndex: 0,
          ),
        ),
      ),
      child: Container(
        width: 222,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDark),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(imagePath,
                  width: 198, height: 129, fit: BoxFit.cover),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 198,
              child: Text(name,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 198,
              height: 20,
              child: _RatingRow(rating: rating, time: time),
            ),
            const SizedBox(height: 13),
            SizedBox(
              width: 198,
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: tags.map((tag) => _TagChip(label: tag)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FreeDeliveryCard extends StatelessWidget {
  const _FreeDeliveryCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const StoreDetailPage(
            storeId: 1,
            storeName: 'Simin Jokbal Bossam Sillim',
            storeSubtitle: 'Korean jokbal and bossam',
            heroImagePath: 'assets/images/food_jokbal.png',
            logoImagePath: 'assets/images/food_jokbal.png',
            preset: StoreDetailPreset.jokbal,
            rating: '5.0',
            deliveryTime: '40min',
            bottomNavIndex: 0,
          ),
        ),
      ),
      child: Container(
        width: 222,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDark),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/food_jokbal.png',
                    width: 198,
                    height: 129,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  right: 0,
                  child: SizedBox(
                    height: 22,
                    width: 198,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            height: 22,
                            color: AppColors.brandOrange,
                            padding: const EdgeInsets.only(left: 10),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'No fee for delivery',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SvgPicture.asset('assets/images/ic_tag_arrow.svg',
                            height: 22, width: 22),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const SizedBox(
              width: 198,
              child: Text('Simin Jokbal & Bossam',
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 4),
            const SizedBox(
              width: 198,
              height: 20,
              child: _RatingRow(rating: '5.0', time: '40min'),
            ),
            const SizedBox(height: 13),
            SizedBox(
              width: 198,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0x61D9654C),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFD9654C)),
                      ),
                      child: const Text('free delivery',
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const _TagChip(label: 'eco-friendly'),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const SizedBox(
              width: 198,
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  _TagChip(label: 'pick up'),
                  _TagChip(label: 'reservation'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FranchiseCard extends StatelessWidget {
  final String category;
  final String name;
  final String bgImage;
  final String logoImage;
  final StoreDetailPreset preset;
  final String rating;
  final String time;

  const _FranchiseCard({
    required this.category,
    required this.name,
    required this.bgImage,
    required this.logoImage,
    required this.preset,
    required this.rating,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StoreDetailPage(
            storeName: name,
            storeSubtitle: category,
            heroImagePath: bgImage,
            logoImagePath: logoImage,
            preset: preset,
            rating: rating,
            deliveryTime: time,
            bottomNavIndex: 0,
          ),
        ),
      ),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 152,
        height: 165,
        child: Stack(
          children: [
            Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Image.asset(bgImage,
                          width: 152, height: 77, fit: BoxFit.cover),
                      Container(
                          width: 152,
                          height: 77,
                          color: const Color(0x33000000)),
                    ],
                  ),
                ),
                Container(
                  width: 152,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 18,
              left: 10,
              right: 10,
              child: SizedBox(
                width: 132,
                child: Column(
                  children: [
                    Container(
                      width: 49,
                      height: 49,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE4E4E4)),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.asset(logoImage, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 8),
                    Text(category,
                        style: AppTextStyles.caption
                            .copyWith(color: const Color(0xFF7A7B7D)),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(name,
                        style: AppTextStyles.title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CafeCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String imagePath;
  final String rating;
  final String time;

  const _CafeCard({
    required this.name,
    required this.subtitle,
    required this.imagePath,
    required this.rating,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StoreDetailPage(
            storeName: name,
            storeSubtitle: subtitle,
            heroImagePath: imagePath,
            logoImagePath: imagePath,
            preset: StoreDetailPreset.cafe,
            rating: rating,
            deliveryTime: time,
            bottomNavIndex: 0,
          ),
        ),
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 222,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDark),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(imagePath,
                  width: 198, height: 129, fit: BoxFit.cover),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 198,
              child: Text(name,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 198,
              height: 20,
              child: Row(
                children: [
                  SvgPicture.asset('assets/icons/star.svg',
                      width: 14, height: 14),
                  const SizedBox(width: 4),
                  Text(rating,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600)),
                  const Text(' (2,002)', style: AppTextStyles.caption),
                  const SizedBox(width: 7),
                  SvgPicture.asset('assets/icons/clock.svg',
                      width: 16, height: 16),
                  const SizedBox(width: 4),
                  Text(time,
                      style: AppTextStyles.caption.copyWith(
                          color: const Color(0xFF333333),
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 13),
            SizedBox(
              width: 198,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: const Text(
                  'available for pick up',
                  style: AppTextStyles.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderDark),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SvgPicture.asset(
              'assets/images/banner_overlay.svg',
              width: double.infinity,
              height: 115,
              fit: BoxFit.fill,
            ),
          ),
          const Positioned(
            left: 24,
            top: 19,
            right: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bringing Korea's speed to you",
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Discover the benefit\nof \$0.00 delivery',
                  style: AppTextStyles.h2,
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            top: 21,
            child: Image.asset(
              'assets/images/delivery_mascot.png',
              width: 76,
              height: 75,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final String rating;
  final String time;
  const _RatingRow({required this.rating, required this.time});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 198,
      height: 20,
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/icon_star.svg',
            width: 16,
            height: 16,
          ),
          const SizedBox(width: 3),
          Text(rating,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
          const Text(' (2,002)',
              style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
          const SizedBox(width: 7),
          SvgPicture.asset(
            'assets/images/icon_time.svg',
            width: 18,
            height: 18,
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Text(time,
                style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF333333),
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Text(label,
          style:
              AppTextStyles.caption.copyWith(color: const Color(0xFF787E81))),
    );
  }
}
