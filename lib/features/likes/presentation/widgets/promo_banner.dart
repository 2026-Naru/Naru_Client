import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_styles.dart';

class PromoBanner extends StatelessWidget {
  final String promoText;
  final String title;

  const PromoBanner({
    super.key,
    this.promoText = 'Delivery with NARU',
    this.title = 'Check your food easily\non the map',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFD47459), Color(0xFFC8664F)],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promoText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontSize: 5.4,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontSize: 7.8,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // TODO: Replace with exact Figma delivery illustration asset when available.
          SizedBox(
            width: 44,
            height: 30,
            child: ClipRect(
              child: Align(
                alignment: Alignment.centerRight,
                widthFactor: 0.74,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF97B7F2),
                    BlendMode.modulate,
                  ),
                  child: Image.asset(
                    'assets/images/delivery_mascot.png',
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
