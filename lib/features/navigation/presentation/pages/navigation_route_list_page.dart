import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/main_tab_page.dart';
import 'navigation_route_results_page.dart';

class NavigationRouteListPage extends StatelessWidget {
  final String from;
  final String to;

  const NavigationRouteListPage({
    super.key,
    required this.from,
    required this.to,
  });

  void _handleBack(BuildContext context) {
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

  static const _routes = <_RouteData>[
    _RouteData(
      isBest: true,
      timeRange: '4:38 PM ~ 5:47 PM',
      transport: '2 Public transport',
      duration: '1hr 9min',
    ),
    _RouteData(
      timeRange: '4:38 PM ~ 5:54 PM',
      transport: '2 bus Public transport',
      duration: '1hr 16min',
    ),
    _RouteData(
      timeRange: '4:38 PM ~ 5:54 PM',
      transport: '2 bus Public transport',
      duration: '1hr 12min',
    ),
    _RouteData(
      timeRange: '4:38 PM ~ 5:55 PM',
      transport: '2 Public transport',
      duration: '1hr 13min',
    ),
    _RouteData(
      timeRange: '4:38 PM ~ 5:53 PM',
      transport: '3 bus Public transport',
      duration: '1hr 8min',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _RoundBackButton(onTap: () => _handleBack(context)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SearchPill(from: from, to: to),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_routes.length} result',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.94,
                ),
                itemCount: _routes.length,
                itemBuilder: (_, i) => _RouteCard(
                  data: _routes[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NavigationRouteResultsPage(
                        from: from,
                        to: to,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RoundBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE6E6E6)),
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

class _SearchPill extends StatelessWidget {
  final String from;
  final String to;

  const _SearchPill({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Color(0xFF888888),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, size: 15, color: Colors.white),
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

class _RouteCard extends StatelessWidget {
  final _RouteData data;
  final VoidCallback onTap;

  const _RouteCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF3C3C3E),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.isBest)
              const Text(
                'Best',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white54,
                ),
              ),
            Text(
              data.timeRange,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11,
                color: Colors.white54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data.transport,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11,
                color: Colors.white54,
                height: 1.4,
              ),
            ),
            const Spacer(),
            Text(
              data.duration,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteData {
  final bool isBest;
  final String timeRange;
  final String transport;
  final String duration;

  const _RouteData({
    this.isBest = false,
    required this.timeRange,
    required this.transport,
    required this.duration,
  });
}
