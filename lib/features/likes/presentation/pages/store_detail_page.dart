import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'menu_option_page.dart';

class StoreDetailPage extends StatefulWidget {
  final String storeName;
  final String storeSubtitle;
  final String heroImagePath;
  final String logoImagePath;

  const StoreDetailPage({
    super.key,
    required this.storeName,
    required this.storeSubtitle,
    required this.heroImagePath,
    required this.logoImagePath,
  });

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLiked = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
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
                const Divider(height: 1, thickness: 8, color: Color(0xFFF3F5F7)),
                _buildPopularMenu(),
                const Divider(height: 1, thickness: 8, color: Color(0xFFF3F5F7)),
                _buildAllergySection(),
                const Divider(height: 1, thickness: 8, color: Color(0xFFF3F5F7)),
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
        GestureDetector(
          onTap: () => setState(() => _isLiked = !_isLiked),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: _isLiked ? AppColors.accentOrange : AppColors.textSecondary,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Image.asset(
          widget.heroImagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
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
                    const Text(
                      '5.0',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '(272)',
                      style: TextStyle(
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
          _infoRow('Store Delivery', '₩3,000'),
          const SizedBox(height: 6),
          _infoRow('', '25~40min'),
          const SizedBox(height: 8),
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
          value,
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
    const menus = [
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
          Text(
            'This is a highly rated menu item',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ...menus.asMap().entries.map((e) => _MenuItemRow(
                item: e.value,
                isLast: e.key == menus.length - 1,
              )),
        ],
      ),
    );
  }

  Widget _buildAllergySection() {
    const allergens = [
      _Allergen(label: 'Peanut', sublabel: 'For topping', icon: Icons.eco),
      _Allergen(label: 'Tomato', sublabel: 'For tomato', icon: Icons.local_florist),
      _Allergen(label: 'Milk', sublabel: 'For garneing', icon: Icons.water_drop),
      _Allergen(label: 'Meat', sublabel: 'For all menu', icon: Icons.set_meal),
      _Allergen(label: 'Egg', sublabel: 'For bread', icon: Icons.egg_outlined),
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
          Text(
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
            children: allergens.map((a) => _AllergenBadge(allergen: a)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
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
              const Text(
                '5.0',
                style: TextStyle(
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
          _ReviewCard(
            name: 'Jake',
            flag: '🇺🇸',
            timeAgo: 'last week',
            text:
                'I was making fresh kimchi at home, so I ordered jokbal too~ 😄 I ordered the medium size, and the portion was huge. The bossam and jokbal were so tender—they melted in my mouth. So delicious!',
            imagePath: 'assets/images/food_jokbal.png',
          ),
          const SizedBox(height: 20),
          _ReviewCard(
            name: 'Kimana',
            flag: '🇰🇷',
            timeAgo: 'last week',
            text:
                'The portion was generous and everything arrived warm. The meat was tender and flavorful—definitely ordering again!',
            imagePath: 'assets/images/food_jokbal.png',
          ),
        ],
      ),
    );
  }
}

class _MenuItemRow extends StatelessWidget {
  final _MenuItem item;
  final bool isLast;
  const _MenuItemRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MenuOptionPage(
            rank: item.rank,
            menuName: item.name,
            description: item.description,
            imagePath: item.imagePath,
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
                      '• $opt',
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
            child: Image.asset(
              item.imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
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
      width: 72,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0EC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFD5C8), width: 1),
            ),
            child: Icon(allergen.icon, color: AppColors.brandOrange, size: 28),
          ),
          const SizedBox(height: 5),
          Text(
            allergen.label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            allergen.sublabel,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 9,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final String flag;
  final String timeAgo;
  final String text;
  final String imagePath;

  const _ReviewCard({
    required this.name,
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
                    Text(flag, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (_) => const Icon(Icons.star_rounded,
                          color: Color(0xFFFFC107), size: 12),
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
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imagePath,
            height: 130,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final String rank;
  final String name;
  final String description;
  final List<String> options;
  final String imagePath;

  const _MenuItem({
    required this.rank,
    required this.name,
    required this.description,
    required this.options,
    required this.imagePath,
  });
}

class _Allergen {
  final String label;
  final String sublabel;
  final IconData icon;

  const _Allergen({
    required this.label,
    required this.sublabel,
    required this.icon,
  });
}
