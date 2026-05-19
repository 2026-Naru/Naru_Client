import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/main_tab_page.dart';
import '../widgets/map_view.dart';

class NavigationRouteResultsPage extends StatefulWidget {
  final String from;
  final String to;

  const NavigationRouteResultsPage({
    super.key,
    required this.from,
    required this.to,
  });

  @override
  State<NavigationRouteResultsPage> createState() =>
      _NavigationRouteResultsPageState();
}

class _NavigationRouteResultsPageState
    extends State<NavigationRouteResultsPage> {
  bool _liked = false;

  static const _duration = '1hr 9min';
  static const _timeRange = '4:38 PM ~ 5:47 PM';
  static const _fare = '₩1,750';

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    final tabNotifier = MainTabScope.of(context);
    if (tabNotifier != null) {
      tabNotifier.value = 1;
      return;
    }
    Navigator.pushReplacementNamed(context, AppRouter.main, arguments: 1);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topInset = media.padding.top;
    final mapHeight = media.size.height * 0.46;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Map layer ──
          SizedBox(
            height: mapHeight,
            width: double.infinity,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: MapView(variant: MapViewVariant.navigation),
                ),
                // Back + search pill
                Positioned(
                  top: topInset + 14,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      _MapBackButton(onTap: _handleBack),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _RouteSearchPill(
                          from: widget.from,
                          to: widget.to,
                        ),
                      ),
                    ],
                  ),
                ),
                // Gyeongbokgung marker (top-right)
                Positioned(
                  top: mapHeight * 0.28,
                  right: 28,
                  child: _MapPlaceMarker(
                    imagePath: 'assets/images/gyeongbokgungplace.png',
                    label: widget.to,
                  ),
                ),
                // Signiel Seoul marker (bottom-left)
                Positioned(
                  top: mapHeight * 0.60,
                  left: 28,
                  child: _MapPlaceMarker(
                    imagePath: 'assets/images/sinielseoul.png',
                    label: widget.from,
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom sheet ──
          Positioned(
            top: mapHeight - 16,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "Best  1hr 9min"
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'Best',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            _duration,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // From / To image cards
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _TripSpotCard(
                              imagePath: 'assets/images/sinielseoul.png',
                              label: 'From',
                              timeText: '4:38 PM ~',
                              placeName: widget.from,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Padding(
                            padding: EdgeInsets.only(top: 68),
                            child: Text(
                              '...',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _TripSpotCard(
                              imagePath: 'assets/images/gyeongbokgungplace.png',
                              label: 'To',
                              timeText: '~ 5:47 PM',
                              placeName: widget.to,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // "We found it" + heart
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'We found it',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => setState(() => _liked = !_liked),
                            child: Icon(
                              _liked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: _liked
                                  ? const Color(0xFFEA3F3F)
                                  : AppColors.textPrimary,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "We've found the best route for you if you have a child and use a stroller.",
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Divider(color: Color(0xFFEEEEEE), height: 1),
                      const SizedBox(height: 18),

                      // Total Time
                      const Text(
                        'Total Time',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        _timeRange,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Text(
                        _fare,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _RouteProgressBar(from: widget.from, to: widget.to),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFEEEEEE), height: 1),
                      const SizedBox(height: 18),

                      // Specification
                      const Text(
                        'Specification',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _SpecCard(
                              label: 'Number of\npeople in your\nfamily',
                              value: '3',
                              dark: true,
                            ),
                            SizedBox(width: 10),
                            _SpecCard(
                              label: 'Price per\nperson',
                              value: '₩1,750',
                              dark: false,
                            ),
                            SizedBox(width: 10),
                            _SpecCard(
                              label: 'Total',
                              value: '₩5,250',
                              dark: true,
                            ),
                          ],
                        ),
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
}

class _MapBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MapBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ── Search pill on map ──────────────────────────────────────────────────────

class _RouteSearchPill extends StatelessWidget {
  final String from;
  final String to;

  const _RouteSearchPill({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/pin.svg',
            width: 20,
            height: 20,
            colorFilter:
                const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$from  →  $to',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Map place marker (circle image + label) ─────────────────────────────────

class _MapPlaceMarker extends StatelessWidget {
  final String imagePath;
  final String label;

  const _MapPlaceMarker({required this.imagePath, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _MapPin(imagePath: imagePath),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black38,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MapPin extends StatelessWidget {
  final String imagePath;
  const _MapPin({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: AppColors.accentOrange, width: 2.5),
          ),
          clipBehavior: Clip.hardEdge,
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),
        const CustomPaint(
          size: Size(12, 8),
          painter: _TrianglePainter(AppColors.accentOrange),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}

// ── From / To image card ────────────────────────────────────────────────────

class _TripSpotCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final String timeText;
  final String placeName;

  const _TripSpotCard({
    required this.imagePath,
    required this.label,
    required this.timeText,
    required this.placeName,
  });

  @override
  Widget build(BuildContext context) {
    const double outerRadius = 23;
    const double borderWidth = 1.5;

    return AspectRatio(
      aspectRatio: 0.72,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(outerRadius),
          border:
              Border.all(color: const Color(0xFFDDDDDD), width: borderWidth),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(outerRadius - borderWidth),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(imagePath, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      timeText,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      placeName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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
    );
  }
}

// ── Progress bar ────────────────────────────────────────────────────────────

class _RouteProgressBar extends StatelessWidget {
  final String from;
  final String to;

  const _RouteProgressBar({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'From $from',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 16,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF888888), AppColors.accentOrange],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Color(0xFF888888),
                  shape: BoxShape.circle,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppColors.accentOrange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'To $to',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Spec card ───────────────────────────────────────────────────────────────

class _SpecCard extends StatelessWidget {
  final String label;
  final String value;
  final bool dark;

  const _SpecCard({
    required this.label,
    required this.value,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 150,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF3A3A3A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark ? const Color(0xFF3A3A3A) : const Color(0xFFDDDDDD),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: dark ? Colors.white70 : AppColors.textSecondary,
              height: 1.3,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: dark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
