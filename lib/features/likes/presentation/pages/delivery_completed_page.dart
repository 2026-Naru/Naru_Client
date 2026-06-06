import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class DeliveryCompletedPage extends StatefulWidget {
  const DeliveryCompletedPage({super.key});

  @override
  State<DeliveryCompletedPage> createState() => _DeliveryCompletedPageState();
}

class _DeliveryCompletedPageState extends State<DeliveryCompletedPage> {
  Timer? _homeTimer;

  @override
  void initState() {
    super.initState();
    _homeTimer = Timer(const Duration(milliseconds: 3500), _goHome);
  }

  @override
  void dispose() {
    _homeTimer?.cancel();
    super.dispose();
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.main,
      (route) => false,
      arguments: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  'Order',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const Spacer(flex: 2),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
                children: [
                  TextSpan(text: 'Delivery '),
                  TextSpan(
                    text: 'completed',
                    style: TextStyle(color: AppColors.brandOrange),
                  ),
                  TextSpan(text: '!'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your delivery has arrived',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 36),
            Image.asset(
              'assets/images/delivery_mascot.png',
              width: 190,
              fit: BoxFit.contain,
            ),
            const Spacer(flex: 5),
          ],
        ),
      ),
    );
  }
}
