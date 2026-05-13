import 'package:flutter/material.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/navigation/presentation/pages/navigation_page.dart';
import '../../features/likes/presentation/pages/favorites_page.dart';
import '../../features/lists/presentation/pages/lists_page.dart';
import '../../features/my_page/presentation/pages/my_page.dart';

/// Allows descendant [NaruBottomNavBar] widgets to switch tabs
/// without pushing a new route.
class MainTabScope extends InheritedWidget {
  final ValueNotifier<int> tabNotifier;

  const MainTabScope({
    super.key,
    required this.tabNotifier,
    required super.child,
  });

  static ValueNotifier<int>? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MainTabScope>()
        ?.tabNotifier;
  }

  @override
  bool updateShouldNotify(MainTabScope old) => tabNotifier != old.tabNotifier;
}

class MainTabPage extends StatefulWidget {
  final int initialIndex;
  const MainTabPage({super.key, this.initialIndex = 0});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  late final ValueNotifier<int> _tabNotifier;

  static const _pages = <Widget>[
    HomePage(),
    NavigationPage(),
    FavoritesPage(),
    ListsPage(),
    MyPage(),
  ];

  @override
  void initState() {
    super.initState();
    _tabNotifier = ValueNotifier(widget.initialIndex);
    _tabNotifier.addListener(_onTabChanged);
  }

  void _onTabChanged() => setState(() {});

  @override
  void dispose() {
    _tabNotifier.removeListener(_onTabChanged);
    _tabNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainTabScope(
      tabNotifier: _tabNotifier,
      child: IndexedStack(
        index: _tabNotifier.value,
        children: _pages,
      ),
    );
  }
}
