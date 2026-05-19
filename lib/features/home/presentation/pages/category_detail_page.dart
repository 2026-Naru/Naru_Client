import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/category_model.dart';

// Derives the transparent-background version of a cat_*.png asset path.
// Falls back to the original path if the image is not a cat_ image.
String _transparentAsset(String assetPath) {
  final uri = Uri.parse(assetPath);
  final filename = uri.pathSegments.last;
  if (!filename.startsWith('cat_') || !filename.endsWith('.png')) {
    return assetPath;
  }
  final stem = filename.substring(0, filename.length - 4); // strip .png
  return 'assets/images/category_transparent/${stem}_transparent.png';
}

class CategoryDetailPage extends StatelessWidget {
  final CategoryModel category;

  const CategoryDetailPage({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.bgWhite,
            foregroundColor: AppColors.textPrimary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              category.title,
              style: AppTextStyles.title,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroBanner(category: category),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.bgWhite,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.title,
                              style: AppTextStyles.h1.copyWith(fontSize: 28),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.description,
                              style: AppTextStyles.body.copyWith(
                                height: 1.45,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _CategoryBadge(image: category.image),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _FilterChip(
                            label: 'Basic order', icon: Icons.swap_vert),
                        _FilterChip(
                            label: 'Naru Club', icon: Icons.card_giftcard),
                        _FilterChip(label: 'Coupons', icon: Icons.bolt),
                        _FilterChip(
                            label: 'Delivery', icon: Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(height: 10, color: AppColors.bgLight),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
              child: Row(
                children: [
                  Text(
                    'Recommended ${category.title}',
                    style: AppTextStyles.h2,
                  ),
                  const Spacer(),
                  Text(
                    '${category.items.length} places',
                    style: AppTextStyles.captionMedium,
                  ),
                ],
              ),
            ),
          ),
          SliverList.separated(
            itemCount: category.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = category.items[index];
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  index == 0 ? 4 : 0,
                  20,
                  index == category.items.length - 1 ? 28 : 0,
                ),
                child: _CategoryPlaceCard(item: item),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final CategoryModel category;

  const _HeroBanner({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accentOrange,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -24,
            bottom: -12,
            child: Opacity(
              opacity: 0.35,
              child: Image.asset(
                _transparentAsset(category.image),
                width: 210,
                height: 210,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Image.asset(
                  category.image,
                  width: 210,
                  height: 210,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Food delivery',
                    style: AppTextStyles.captionMedium.copyWith(
                      color: AppColors.brandOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  category.title,
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
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

class _CategoryBadge extends StatelessWidget {
  final String image;

  const _CategoryBadge({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(9),
      child: Image.asset(
        _transparentAsset(image),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Image.asset(image, fit: BoxFit.contain),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FilterChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.textPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _CategoryPlaceCard extends StatelessWidget {
  final CategoryItemModel item;

  const _CategoryPlaceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          SizedBox(
            width: 116,
            height: 116,
            child: Image.asset(
              item.image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.bgInput,
                alignment: Alignment.center,
                child: const Icon(Icons.restaurant, color: AppColors.textMuted),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: AppColors.brandOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '4.${item.name.length % 4 + 6}',
                        style: AppTextStyles.captionMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '20-35 min',
                        style: AppTextStyles.captionMedium,
                      ),
                    ],
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
