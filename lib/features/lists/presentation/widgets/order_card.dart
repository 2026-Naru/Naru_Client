import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class OrderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String date;
  final String imagePath;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.date,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
      height: 96,
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF747474), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 72,
            height: 72,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF8B8B8B), width: 0.9),
              color: AppColors.bgLight,
            ),
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
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
                        fontSize: 10,
                        color: const Color(0xFF8D8D8D),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                Text(
                  price,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10.8,
                    color: AppColors.textPrimary,
                    height: 1.1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                date,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 9.3,
                  color: const Color(0xFFA0A0A0),
                  height: 1.1,
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
