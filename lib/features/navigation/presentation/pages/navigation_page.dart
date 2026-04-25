import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import 'navigation_search_page.dart';
import 'select_location_page.dart';
import '../widgets/map_view.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  static const List<_TrendingItem> _trending = [
    _TrendingItem(
      rank: 1,
      title: 'SIMZPATI KUSSEOUL STATION',
      subtitle: '#Hot place\n#Korage-free',
      imagePath: 'assets/images/food_cafe.png',
    ),
    _TrendingItem(
      rank: 2,
      title: 'TEXAS BBQ GHOST BLACK YE...',
      subtitle: '@sxmI away',
      imagePath: 'assets/images/food_jokbal.png',
    ),
    _TrendingItem(
      rank: 3,
      title: 'FAMOUS HONGDAE TTEOKBOKKI',
      subtitle: 'Taste picked by locals',
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
      imagePath: 'assets/images/banner_food.png',
    ),
  ];

  static const List<_SharingSpotItem> _sharingSpots = [
    _SharingSpotItem(
      title: 'EMON N M',
      subtitle: 'Cafe/Dessert',
      imagePath: 'assets/images/food_tteokbokki.png',
    ),
    _SharingSpotItem(
      title: 'KOMU',
      subtitle: 'Cafe Dessert',
      imagePath: 'assets/images/food_cafe.png',
    ),
    _SharingSpotItem(
      title: 'FOODSEOUL',
      subtitle: 'Cafe Dessert',
      imagePath: 'assets/images/banner_bg.png',
    ),
    _SharingSpotItem(
      title: 'PandaExpress IFC Mall',
      subtitle: 'Chinese Food',
      imagePath: 'assets/images/food_jokbal.png',
    ),
    _SharingSpotItem(
      title: 'HAPPY?',
      subtitle: 'Restaurant',
      imagePath: 'assets/images/franchise_nene_bg.png',
    ),
    _SharingSpotItem(
      title: 'Humming Bella',
      subtitle: 'Cafe Dessert',
      imagePath: 'assets/images/franchise_domino_bg.png',
    ),
  ];

  static const List<_FriendTourCardItem> _friendTours = [
    _FriendTourCardItem(
      name: 'Jake',
      timeAgo: '1 hr ago',
      comment:
          'This place is really the best.\nBeautiful cafes and desserts made me happy!',
      imagePath: 'assets/images/food_cafe.png',
    ),
    _FriendTourCardItem(
      name: 'JOY',
      timeAgo: '1 hr ago',
      comment:
          'The cozy interior is beautiful.\nI want to come back in the summer.',
      imagePath: 'assets/images/franchise_domino_bg.png',
    ),
  ];

  static const List<_FriendAvatarItem> _friendAvatars = [
    _FriendAvatarItem(
        name: 'Hongdae', imagePath: 'assets/images/food_cafe.png'),
    _FriendAvatarItem(
        name: 'Jongno', imagePath: 'assets/images/food_jokbal.png'),
    _FriendAvatarItem(
        name: 'Hannam', imagePath: 'assets/images/food_tteokbokki.png'),
    _FriendAvatarItem(
        name: 'Suwon', imagePath: 'assets/images/banner_food.png'),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final mapHeight = screenWidth * 1.03;

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
                    child: const MapView(variant: MapViewVariant.navigation),
                  ),
                  Positioned(
                    top: 12,
                    left: 18,
                    right: 18,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NavigationSearchPage(),
                              ),
                            ),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F1F1),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2.5),
                                  ),
                                ],
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.search,
                                    color: AppColors.inactive,
                                    size: 26,
                                  ),
                                  const SizedBox(width: 8.5),
                                  Text(
                                    'Search name of place',
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 14,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w400,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SelectLocationPage(),
                            ),
                          ),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: AppColors.accentOrange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.turn_right_rounded,
                              size: 26,
                              color: Colors.white,
                            ),
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
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeading(
                        leading: const Text(
                          'Trending in ',
                          style: AppTextStyles.title,
                        ),
                        highlighted: const Text(
                          'Hongdae',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentOrange,
                          ),
                        ),
                        subtitle: 'Updated 9 min ago',
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 168,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _trending.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, index) => _TrendingCard(
                            item: _trending[index],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionHeading(
                        leading: const Text(
                          'Hongdae ',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentOrange,
                          ),
                        ),
                        highlighted: const Text(
                          'Restaurant Picks',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: 'For Baegopa',
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 146,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _picks.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, index) =>
                              _PickCard(item: _picks[index]),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const _FriendPromoBanner(),
                      const SizedBox(height: 16),
                      const Text(
                        'Find new spots in the sharing list',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _sharingSpots.map((item) {
                          final itemWidth = (screenWidth - (14 * 2) - 8) / 2;
                          return SizedBox(
                            width: itemWidth,
                            child: _SharingSpotCard(item: item),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Restaurant tour with friends',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 126,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _friendTours.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, index) => _FriendTourCard(
                            item: _friendTours[index],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Restaurant tour with friends',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 72,
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

  const _SectionHeading({
    required this.leading,
    required this.highlighted,
    required this.subtitle,
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
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
            color: AppColors.textMuted,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final _TrendingItem item;
  const _TrendingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 146,
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
                    Colors.black.withValues(alpha: 0.68),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.rank}',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
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
                    style: AppTextStyles.captionMedium.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 9,
                      height: 1.2,
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

class _PickCard extends StatelessWidget {
  final _PickItem item;
  const _PickCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 122,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Container(
          color: const Color(0xFFF4F5F6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                item.imagePath,
                width: double.infinity,
                height: 88,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.captionMedium.copyWith(
                    fontSize: 10,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                child: Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 9,
                    color: AppColors.textMuted,
                    height: 1.2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                child: Text(
                  item.price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.captionMedium.copyWith(
                    fontSize: 9,
                    color: AppColors.textPrimary,
                    height: 1.2,
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

class _FriendPromoBanner extends StatelessWidget {
  const _FriendPromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // TODO: Replace with exact Figma blue character asset when available.
          Image.asset(
            'assets/images/delivery_mascot.png',
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            color: const Color(0xFFCCE0FF),
            colorBlendMode: BlendMode.modulate,
          ),
        ],
      ),
    );
  }
}

class _SharingSpotCard extends StatelessWidget {
  final _SharingSpotItem item;
  const _SharingSpotCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: Stack(
        children: [
          SizedBox(
            height: 74,
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
            left: 8,
            right: 8,
            bottom: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.captionMedium.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                    height: 1.2,
                  ),
                ),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 8,
                    height: 1.2,
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

class _FriendTourCard extends StatelessWidget {
  final _FriendTourCardItem item;
  const _FriendTourCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 166,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            Positioned.fill(
                child: Image.asset(item.imagePath, fit: BoxFit.cover)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.76),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 17,
                        height: 17,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFECECEC),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.name,
                        style: AppTextStyles.captionMedium.copyWith(
                          color: Colors.white,
                          fontSize: 8.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        item.timeAgo,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 7.2,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    item.comment,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontSize: 8.3,
                      height: 1.2,
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

class _FriendAvatar extends StatelessWidget {
  final _FriendAvatarItem item;
  const _FriendAvatar({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEBEBEB),
            ),
            child: Image.asset(item.imagePath, fit: BoxFit.cover),
          ),
          const SizedBox(height: 4),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontSize: 9,
              color: AppColors.textPrimary,
              height: 1.2,
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
  final String subtitle;
  final String imagePath;
  const _TrendingItem({
    required this.rank,
    required this.title,
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
  final String comment;
  final String imagePath;
  const _FriendTourCardItem({
    required this.name,
    required this.timeAgo,
    required this.comment,
    required this.imagePath,
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
