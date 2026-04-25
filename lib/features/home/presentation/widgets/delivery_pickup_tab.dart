import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';

class DeliveryPickupTab extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _menuTopRadius = Radius.circular(14);
  static const _horizontalPadding = 16.0;
  static const _topPadding = 14.0;
  static const _tabGap = 24.0;
  static const _tabHorizontalPadding = 8.0;
  static const _indicatorTopGap = 8.0;
  static const _indicatorHeight = 6.0;
  static const _indicatorWidth = 84.0;
  static const _labelFontSize = 16.0;
  static const _dividerThickness = 1.0;
  static const _animationDuration = Duration(milliseconds: 260);

  const DeliveryPickupTab({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final activeIndex = selectedIndex == 1 ? 1 : 0;
    final baseTextStyle = AppTextStyles.title.copyWith(
      fontSize: _labelFontSize,
      color: AppColors.primary,
    );
    final deliveryTabWidth =
        _measureTextWidth(context, AppStrings.delivery, baseTextStyle) +
            (_tabHorizontalPadding * 2);
    final pickupTabWidth =
        _measureTextWidth(context, AppStrings.pickup, baseTextStyle) +
            (_tabHorizontalPadding * 2);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.only(
          topLeft: _menuTopRadius,
          topRight: _menuTopRadius,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        _topPadding,
        _horizontalPadding,
        0,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final deliveryIndicatorLeft =
              (deliveryTabWidth / 2) - (_indicatorWidth / 2);
          final pickupIndicatorLeft = deliveryTabWidth +
              _tabGap +
              (pickupTabWidth / 2) -
              (_indicatorWidth / 2);
          final rawIndicatorLeft =
              activeIndex == 0 ? deliveryIndicatorLeft : pickupIndicatorLeft;
          final maxIndicatorLeft = (constraints.maxWidth - _indicatorWidth)
              .clamp(0.0, double.infinity)
              .toDouble();
          final indicatorLeft =
              rawIndicatorLeft.clamp(0.0, maxIndicatorLeft).toDouble();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Tab(
                    width: deliveryTabWidth,
                    label: AppStrings.delivery,
                    active: activeIndex == 0,
                    onTap: () => onChanged(0),
                  ),
                  const SizedBox(width: _tabGap),
                  _Tab(
                    width: pickupTabWidth,
                    label: AppStrings.pickup,
                    active: activeIndex == 1,
                    onTap: () => onChanged(1),
                  ),
                ],
              ),
              const SizedBox(height: _indicatorTopGap),
              SizedBox(
                height: _indicatorHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: Divider(
                        height: _dividerThickness,
                        thickness: _dividerThickness,
                        color: AppColors.border,
                      ),
                    ),
                    AnimatedPositioned(
                      duration: _animationDuration,
                      curve: Curves.easeInOutCubic,
                      left: indicatorLeft,
                      bottom: 0,
                      child: Container(
                        height: _indicatorHeight,
                        width: _indicatorWidth,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _measureTextWidth(
    BuildContext context,
    String text,
    TextStyle style,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();
    return textPainter.width;
  }
}

class _Tab extends StatelessWidget {
  final double width;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({
    required this.width,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: DeliveryPickupTab._animationDuration,
            curve: Curves.easeInOutCubic,
            style: AppTextStyles.title.copyWith(
              fontSize: DeliveryPickupTab._labelFontSize,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: AppColors.primary,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
