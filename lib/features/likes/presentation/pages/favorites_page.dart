import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import 'store_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  static const List<_LikedShopSection> _shops = [
    _LikedShopSection(
      name: 'Yupki Ddukbokki',
      subtitle: 'Deliciously spicy Korean snack',
      logoPath: 'assets/images/yupki_profile.png',
      products: [
        _ProductCardData(
          title: 'Yeopgi Menu',
          description: 'Tteokbokki+rice+fries',
          price: '₩14,000',
          imagePath: 'assets/images/YeopgiMenu.png',
        ),
        _ProductCardData(
          title: 'Rosé Menu',
          description: 'Tteokbokki+rice+fries',
          price: '₩16,000',
          imagePath: 'assets/images/rose_menu.png',
        ),
        _ProductCardData(
          title: 'Mala Tteokbokki',
          description: 'Tteokbokki+rice+fries',
          price: '₩13,000',
          imagePath: 'assets/images/Mala_Tteokbokki.png',
        ),
      ],
    ),
    _LikedShopSection(
      name: 'Jangchungdong King Jokbal',
      subtitle: 'The original jokbal franchise',
      logoPath: 'assets/images/jockbal_profile.png',
      products: [
        _ProductCardData(
          title: 'Spicyseasoned...',
          description: 'Signature spicy dish',
          price: '₩43,000',
          imagePath: 'assets/images/Spicyseasoned.png',
        ),
        _ProductCardData(
          title: 'Jokbal Mix',
          description: 'Jokbal and Golb...',
          price: '₩35,000',
          imagePath: 'assets/images/Jokbal_Mix.png',
        ),
        _ProductCardData(
          title: 'Jangchungdong...',
          description: 'Pork neck',
          price: '₩37,900',
          imagePath: 'assets/images/Jangchungdong.png',
        ),
      ],
    ),
  ];

  static const List<_TrendingCardData> _trending = [
    _TrendingCardData(
      shopName: 'nomorepizza',
      subShopName: 'Beyond ordinary pizza',
      title: 'White Seafood Pizza',
      subtitle: 'A combination of crab lang..',
      logoPath: 'assets/images/nomore_profile.png',
      imagePath: 'assets/images/WhiteSeafoodPizza.png',
    ),
    _TrendingCardData(
      shopName: 'Yookhoe Barun...',
      subShopName: 'Pure freshness',
      title: 'Spicy-Marinated Sa...',
      subtitle: 'deep satisfaction in every bite',
      logoPath: 'assets/images/Yookhoe Barun_profile.png',
      imagePath: 'assets/images/Spicy-MarinatedSa.png',
    ),
    _TrendingCardData(
      shopName: 'Seobu Cheon...',
      subShopName: 'Tradition in every bite',
      title: 'hepatic bone inju...',
      subtitle: 'Soy-braised pork bones,',
      logoPath: 'assets/images/SeobuCheongg_profile.png',
      imagePath: 'assets/images/hepaticboneinjury.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Row(
                children: [
                  Text(
                    'Likes',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.08,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.search, size: 21, color: AppColors.textPrimary),
                  SizedBox(width: 10),
                  Icon(Icons.shopping_cart_outlined,
                      size: 21, color: AppColors.textPrimary),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total 5 Shop',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ShopSection(section: _shops[0]),
                    const SizedBox(height: 22),
                    _ShopSection(section: _shops[1]),
                    const SizedBox(height: 26),
                    const Text(
                      'Trending Food Picks',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'For Baegopa',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 138,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _trending.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, index) {
                          return _TrendingCard(item: _trending[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    const _LikesPromoBanner(),
                    const SizedBox(height: 12),
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
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StoreDetailPage(
                storeName: section.name,
                storeSubtitle: section.subtitle,
                heroImagePath: section.logoPath,
                logoImagePath: section.logoPath,
              ),
            ),
          ),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE4E6E8), width: 1),
                ),
                child: Image.asset(section.logoPath, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      section.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8D8D8D),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.favorite,
                  color: AppColors.accentOrange, size: 22),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 202,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: section.products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
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
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF686868), width: 1.2),
            ),
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              item.imagePath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6F6F6F),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.price,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.1,
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
      width: 144,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.asset(item.logoPath, fit: BoxFit.cover),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.shopName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      item.subShopName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8C8F94),
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
                          Colors.black.withValues(alpha: 0.66),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.15,
                          ),
                        ),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
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

class _LikesPromoBanner extends StatelessWidget {
  const _LikesPromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106,
      decoration: BoxDecoration(
        color: const Color(0xFFCC6E55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFAE5D48), width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery with NARU',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Check your food easily\non the map',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 114,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                'assets/images/checkmap.png',
                width: 210,
                height: 194,
                fit: BoxFit.contain,
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
  final String subShopName;
  final String title;
  final String subtitle;
  final String logoPath;
  final String imagePath;

  const _TrendingCardData({
    required this.shopName,
    required this.subShopName,
    required this.title,
    required this.subtitle,
    required this.logoPath,
    required this.imagePath,
  });
}
