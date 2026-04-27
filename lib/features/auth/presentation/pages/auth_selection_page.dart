import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'login_page.dart';
import 'signup_page.dart';

class AuthSelectionPage extends StatelessWidget {
  const AuthSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 115),
          _AuthHero(),
          const SizedBox(height: 55),

          // Apple / Google 소셜 로그인
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialBtn(
                image: 'assets/images/social_apple.png',
                label: 'Apple',
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _SocialBtn(
                image: 'assets/images/social_google.png',
                label: 'Google',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Login with E-mail 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
              child: Container(
                height: 51,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(9000),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Login with E-mail',
                  style: AppTextStyles.body.copyWith(
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Sign up 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignupPage()),
              ),
              child: Container(
                height: 51,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.dark,
                  borderRadius: BorderRadius.circular(9000),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Sign up',
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/logo.svg',
            height: 15,
            colorFilter: const ColorFilter.mode(
              Color(0xFF696969),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.h1.copyWith(height: 1.32),
              children: const [
                TextSpan(text: 'Find your food\natmosphere here '),
                TextSpan(
                  text: 'now.',
                  style: TextStyle(color: AppColors.accent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          _FoodImageWithGlow(),
        ],
      ),
    );
  }
}

class _FoodImageWithGlow extends StatelessWidget {
  const _FoodImageWithGlow();

  @override
  Widget build(BuildContext context) {
    final foodWidth = 150.0;
    final foodHeight = 130.0;
    final glowSize = 178.0;

    return SizedBox(
      width: glowSize,
      height: glowSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: glowSize,
            height: glowSize,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.brandOrange.withValues(alpha: 0.26),
                  AppColors.brandOrange.withValues(alpha: 0.12),
                  AppColors.brandOrange.withValues(alpha: 0.03),
                  Colors.transparent,
                ],
                stops: const [0, 0.5, 0.75, 1],
              ),
            ),
          ),
          Center(
            child: Image.asset(
              'assets/images/auth_food.png',
              width: foodWidth,
              height: foodHeight,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String image;
  final String label;
  final VoidCallback onTap;

  const _SocialBtn({
    required this.image,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(image, width: 56, height: 56),
          const SizedBox(height: 9),
          Text(
            label,
            style: AppTextStyles.body.copyWith(color: const Color(0xFF333333)),
          ),
        ],
      ),
    );
  }
}
