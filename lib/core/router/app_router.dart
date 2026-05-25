import 'package:flutter/material.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/terms_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/order/presentation/pages/order_flow_page.dart';
import '../../features/cart/presentation/pages/cart_list_page.dart';
import '../../shared/widgets/main_tab_page.dart';

class AppRouter {
  static const String onboarding = '/';
  static const String terms = '/terms';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String main = '/main';
  // Legacy routes kept for backward compat — all resolve to /main
  static const String home = '/main';
  static const String navigation = '/main';
  static const String favorites = '/main';
  static const String lists = '/main';
  static const String myPage = '/main';
  static const String search = '/search';
  static const String order = '/order';
  static const String cart = '/cart';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case terms:
        return MaterialPageRoute(builder: (_) => const TermsPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case main:
        final args = settings.arguments;
        final initialIndex = args is int ? args : 0;
        return MaterialPageRoute(
          builder: (_) => MainTabPage(initialIndex: initialIndex),
        );
      case search:
        return MaterialPageRoute(builder: (_) => const SearchPage());
      case order:
        return MaterialPageRoute(builder: (_) => const OrderFlowPage());
      case cart:
        return MaterialPageRoute(builder: (_) => const CartListPage());
      default:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
    }
  }
}
