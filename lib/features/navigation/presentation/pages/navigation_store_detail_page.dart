import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../widgets/map_view.dart';

class NavigationStoreDetailPage extends StatefulWidget {
  final MapStorePin pin;

  const NavigationStoreDetailPage({
    super.key,
    required this.pin,
  });

  @override
  State<NavigationStoreDetailPage> createState() =>
      _NavigationStoreDetailPageState();
}

class _NavigationStoreDetailPageState extends State<NavigationStoreDetailPage> {
  int _selectedTab = 0;
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final mapHeight = (media.size.width * 0.88).clamp(300.0, 360.0);

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: mapHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MapView(
                  variant: MapViewVariant.selectedStore,
                  selectedStoreImagePath: widget.pin.imagePath,
                ),
                const SafeArea(
                  bottom: false,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Row(
                        children: [
                          Expanded(child: _MapSearchPill()),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: mapHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: AppColors.bgWhite,
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    28 + media.padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PanelBackButton(
                          onTap: () => Navigator.maybePop(context)),
                      const SizedBox(height: 20),
                      _HeroImage(imagePath: widget.pin.imagePath),
                      const SizedBox(height: 12),
                      _StoreSummary(
                        title: widget.pin.storeName,
                        subtitle: widget.pin.storeSubtitle,
                        rating: widget.pin.rating,
                        liked: _liked,
                        onLikeTap: () => setState(() => _liked = !_liked),
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: AppColors.separator),
                      const SizedBox(height: 18),
                      _DetailTabs(
                        selectedIndex: _selectedTab,
                        onChanged: (index) =>
                            setState(() => _selectedTab = index),
                      ),
                      const SizedBox(height: 14),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _buildTabContent(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 1:
        return const _MenuContent(key: ValueKey('menu'));
      case 2:
        return const _ReviewContent(key: ValueKey('review'));
      case 0:
      default:
        return const _DirectionsContent(key: ValueKey('directions'));
    }
  }
}

class _MapSearchPill extends StatelessWidget {
  const _MapSearchPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AppColors.inactive),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search name of place',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PanelBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const SizedBox(
        width: 32,
        height: 28,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final String imagePath;

  const _HeroImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: AspectRatio(
        aspectRatio: 2.02,
        child: Image.asset(
          imagePath,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _StoreSummary extends StatelessWidget {
  final String title;
  final String subtitle;
  final String rating;
  final bool liked;
  final VoidCallback onLikeTap;

  const _StoreSummary({
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.liked,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10.5,
                  color: AppColors.inactive,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: Color(0xFFFFC107),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$rating(2,456)',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onLikeTap,
          child: Icon(
            liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 24,
            color: liked ? AppColors.accentOrange : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DetailTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _DetailTabs({
    required this.selectedIndex,
    required this.onChanged,
  });

  static const _labels = ['Directions', 'Menu', 'Review'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length, (index) {
        final selected = selectedIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 32,
              margin:
                  EdgeInsets.only(right: index == _labels.length - 1 ? 0 : 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.textPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(
                _labels[index],
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _DirectionsContent extends StatelessWidget {
  const _DirectionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDark, width: 0.8),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notification',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '[April] Discount on wedding invitations\n3 week age',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Seasoning every moment, SZIMPATIKUS\nSeoul-station',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        const _InfoBlock(
            label: 'Location', value: '831 Namdaemunno 5(o)-ga Jung-gu Seoul'),
        const SizedBox(height: 9),
        const _InfoBlock(label: 'Opening soon', value: '11:00 AM'),
        const SizedBox(height: 9),
        const _InfoBlock(label: '', value: '0507-1340-9048'),
        const SizedBox(height: 9),
        const _InfoBlock(
          label: '',
          value: 'Book, Wi-fi, Restroom, Takeout, Delivery, Highchair',
        ),
      ],
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              color: AppColors.textMuted,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            fontSize: 10.5,
            color: AppColors.textPrimary,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _MenuContent extends StatelessWidget {
  const _MenuContent({super.key});

  static const _items = [
    _MenuPreview(
      title: 'Gochu oil myeongran\ncream pasta',
      description:
          'Signature pasta with chili oil, pollack\ncream, and fried green onion',
      imagePath: 'assets/navigation/szimpatikus_hero.png',
    ),
    _MenuPreview(
      title: 'Chadol gosari pasta',
      description:
          'Pasta with the flavor of bracken\nmixed with fire-scented brisket and\nperilla oil cream sauce',
      imagePath: 'assets/navigation/restaurant.png',
    ),
    _MenuPreview(
      title: 'Udae galbi risotto',
      description:
          'A blend of soft, juicy preferential\nribs and creamy risotto with cheese\nflavor',
      imagePath: 'assets/images/food_jokbal.png',
    ),
    _MenuPreview(
      title: 'Salchi-sal steak',
      description:
          'Signature menu with soft flesh and\nunique Korean touch garnish',
      imagePath: 'assets/images/food_tteokbokki.png',
    ),
    _MenuPreview(
      title: 'Deulgireum mayo albaechu\nsalad',
      description:
          'Salad with grilled cabbage with\nsavory perilla oil mayonnaise, soft\nburrata cheese and granola texture',
      imagePath: 'assets/images/food_cafe.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: _MenuRow(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final _MenuPreview item;

  const _MenuRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.description,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10.3,
                    color: AppColors.textMuted,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            item.imagePath,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}

class _ReviewContent extends StatelessWidget {
  const _ReviewContent({super.key});

  static const _reviews = [
    _ReviewPreview(
      name: 'momo',
      time: '03.14',
      title: 'table for 2',
      category: 'Restaurant, Cafe',
      body: 'The view and the atmosphere are so nice!',
      imagePath: 'assets/navigation/restaurant.png',
    ),
    _ReviewPreview(
      name: 'YUYU',
      time: '03.18',
      title: 'table for 3-4',
      category: 'Restaurant',
      body:
          'I could feel the taste of Korea luxurious. Pasta in particular has a crazy taste.',
      imagePath: 'assets/navigation/szimpatikus_hero.png',
    ),
    _ReviewPreview(
      name: 'nana',
      time: '03.17',
      title: 'table for 3-4',
      category: 'Restaurant, Cafe',
      body:
          "I didn't like the dessert, but the signature food and atmosphere are great.",
      imagePath: 'assets/navigation/feed1.png',
    ),
    _ReviewPreview(
      name: 'yttili09',
      time: '04.01',
      title: 'table for 2',
      category: 'Restaurant',
      body:
          'The fun meeting time made me happier. The end-of-year party should be here.',
      imagePath: 'assets/navigation/feed2.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.78,
      ),
      itemCount: _reviews.length,
      itemBuilder: (_, index) => _ReviewTile(review: _reviews[index]),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final _ReviewPreview review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(review.imagePath, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.30),
                  Colors.black.withValues(alpha: 0.86),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF2C8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.face_retouching_natural_rounded,
                        size: 17,
                        color: Color(0xFF6D5525),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (_) => const Icon(
                                  Icons.star_rounded,
                                  size: 8,
                                  color: Color(0xFFFFC107),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                review.time,
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 7.5,
                                  color: Colors.white.withValues(alpha: 0.82),
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  review.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  review.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 8,
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  review.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 8.5,
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.18,
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

class _MenuPreview {
  final String title;
  final String description;
  final String imagePath;

  const _MenuPreview({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class _ReviewPreview {
  final String name;
  final String time;
  final String title;
  final String category;
  final String body;
  final String imagePath;

  const _ReviewPreview({
    required this.name,
    required this.time,
    required this.title,
    required this.category,
    required this.body,
    required this.imagePath,
  });
}
