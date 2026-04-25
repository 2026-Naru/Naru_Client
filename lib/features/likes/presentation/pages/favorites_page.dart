import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../widgets/promo_banner.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  static const List<_LikedShopSection> _shops = [
    _LikedShopSection(
      name: 'Yupki Ddukbokki',
      subtitle: 'Deliciously spicy Korean snack',
      logoPath: 'assets/images/food_tteokbokki.png',
      products: [
        _ProductCardData(
          title: 'Yeopgi Menu',
          description: 'Tteokbokki+rice+fries',
          price: '₩14,000',
          imagePath: 'assets/images/food_tteokbokki.png',
        ),
        _ProductCardData(
          title: 'Rosé Menu',
          description: 'Tteokbokki+rice+fries',
          price: '₩16,000',
          imagePath: 'assets/images/food_tteokbokki.png',
        ),
        _ProductCardData(
          title: 'Mala Tteokbokki',
          description: 'Tteokbokki+rice+fries',
          price: '₩18,000',
          imagePath: 'assets/images/banner_food.png',
        ),
      ],
    ),
    _LikedShopSection(
      name: 'Jangchungdong King Jokbal',
      subtitle: 'The original jokbal franchise',
      logoPath: 'assets/images/food_jokbal.png',
      products: [
        _ProductCardData(
          title: 'Spicyseasoned...',
          description: 'Signature spicy dish',
          price: '₩43,000',
          imagePath: 'assets/images/food_jokbal.png',
        ),
        _ProductCardData(
          title: 'Jokbal Mix',
          description: 'Jokbal and Bossam',
          price: '₩35,000',
          imagePath: 'assets/images/food_jokbal.png',
        ),
        _ProductCardData(
          title: 'Jangchungdong...',
          description: 'Pork neck mixed set',
          price: '₩37,000',
          imagePath: 'assets/images/food_jokbal.png',
        ),
      ],
    ),
  ];

  static const List<_TrendingCardData> _trending = [
    _TrendingCardData(
      shopName: 'monoprezza',
      title: 'White Seafood Pizza',
      subtitle: 'A combination of cheese and seafood',
      logoPath: 'assets/images/franchise_domino_logo.png',
      imagePath: 'assets/images/food_cafe.png',
    ),
    _TrendingCardData(
      shopName: 'Yookhoe Barun...',
      title: 'Spicy-Marinated Yookhoe',
      subtitle: 'Fresh Korean beef with special sauce',
      logoPath: 'assets/images/franchise_lotteria_logo.png',
      imagePath: 'assets/images/banner_bg.png',
    ),
    _TrendingCardData(
      shopName: 'Seobu Cheon...',
      title: 'Heptic bone ring jig',
      subtitle: 'Spicy and rich broth menu',
      logoPath: 'assets/images/franchise_nene_logo.png',
      imagePath: 'assets/images/food_jokbal.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 1, 20, 2),
              child: Row(
                children: [
                  Text(
                    'Likes',
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.search,
                    size: 12,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 12,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total 5 Shop',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 8.2,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _ShopSection(section: _shops[0]),
                    const SizedBox(height: 8),
                    _ShopSection(section: _shops[1]),
                    const SizedBox(height: 8),
                    Text(
                      'Trending Food Picks',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 8.6,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      'For Baegopa',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 7.2,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 82,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _trending.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, index) {
                          return _TrendingCard(item: _trending[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 7),
                    const PromoBanner(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NaruBottomNavBar(currentIndex: 2),
    );
  }
}

class _ShopSection extends StatelessWidget {
  final _LikedShopSection section;
  const _ShopSection({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E6E8), width: 1),
              ),
              child: Image.asset(section.logoPath, fit: BoxFit.cover),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 7.4,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    section.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 5,
                      color: const Color(0xFF8D8D8D),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.favorite,
              color: AppColors.accentOrange,
              size: 8,
            ),
          ],
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 98,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: section.products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) =>
                _ProductCard(item: section.products[index]),
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final _ProductCardData item;
  const _ProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFD5D7DB), width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.asset(
              item.imagePath,
              width: double.infinity,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontSize: 6.9,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          Text(
            item.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontSize: 5.3,
              color: const Color(0xFF9B9EA2),
              height: 1.2,
            ),
          ),
          const Spacer(),
          Text(
            item.price,
            style: AppTextStyles.caption.copyWith(
              fontSize: 7.1,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final _TrendingCardData item;
  const _TrendingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.asset(item.logoPath, fit: BoxFit.cover),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  item.shopName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 5.1,
                    color: const Color(0xFF676A6D),
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
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
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 5.6,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 4.3,
                            color: Colors.white.withValues(alpha: 0.92),
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
        ],
      ),
    );
  }
}

class _LikedShopSection {
  final String name;
  final String subtitle;
  final String logoPath;
  final List<_ProductCardData> products;

  const _LikedShopSection({
    required this.name,
    required this.subtitle,
    required this.logoPath,
    required this.products,
  });
}

class _ProductCardData {
  final String title;
  final String description;
  final String price;
  final String imagePath;

  const _ProductCardData({
    required this.title,
    required this.description,
    required this.price,
    required this.imagePath,
  });
}

class _TrendingCardData {
  final String shopName;
  final String title;
  final String subtitle;
  final String logoPath;
  final String imagePath;

  const _TrendingCardData({
    required this.shopName,
    required this.title,
    required this.subtitle,
    required this.logoPath,
    required this.imagePath,
  });
}
