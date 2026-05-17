import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/main_tab_page.dart';
import 'navigation_route_list_page.dart';

class NavigationSearchPage extends StatefulWidget {
  const NavigationSearchPage({super.key});

  @override
  State<NavigationSearchPage> createState() => _NavigationSearchPageState();
}

class _NavigationSearchPageState extends State<NavigationSearchPage> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _fromFocus = FocusNode();
  final _toFocus = FocusNode();

  bool _fromActive = false;

  static const _suggestions = [
    'Hongdae',
    'Hongdaesterrt',
    'HongJjimdak',
    'Sinchon Station',
    'Sillim Station Exit 2',
  ];

  List<String> get _filtered {
    final query = _fromActive ? _fromController.text : _toController.text;
    // _fromActive tracks From focus; otherwise filter by To field
    if (query.isEmpty) return _suggestions;
    return _suggestions
        .where((s) => s.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fromFocus
        .addListener(() => setState(() => _fromActive = _fromFocus.hasFocus));
    _toFocus.addListener(() => setState(() {}));
    _fromController.addListener(() => setState(() {}));
    _toController.addListener(() => setState(() {}));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _fromFocus.requestFocus());
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _fromFocus.dispose();
    _toFocus.dispose();
    super.dispose();
  }

  void _fillSuggestion(String val) {
    if (_fromActive) {
      _fromController.text = val;
      _fromFocus.unfocus();
      Future.delayed(
        const Duration(milliseconds: 100),
        () => _toFocus.requestFocus(),
      );
    } else {
      _toController.text = val;
      _toFocus.unfocus();
      _tryNavigate();
    }
  }

  void _tryNavigate() {
    final from = _fromController.text.trim();
    final to = _toController.text.trim();
    if (from.isNotEmpty && to.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NavigationRouteListPage(from: from, to: to),
        ),
      );
    }
  }

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _RoundBackButton(onTap: _handleBack),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SearchPill(
                      fromController: _fromController,
                      toController: _toController,
                      fromFocus: _fromFocus,
                      toFocus: _toFocus,
                      onFromSubmitted: (_) => _toFocus.requestFocus(),
                      onToSubmitted: (_) => _tryNavigate(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final s = _filtered[i];
                  return InkWell(
                    onTap: () => _fillSuggestion(s),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 11, horizontal: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.north_west_rounded,
                            size: 15,
                            color: Color(0xFFBBBBBB),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            s,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
  final TextEditingController fromController;
  final TextEditingController toController;
  final FocusNode fromFocus;
  final FocusNode toFocus;
  final ValueChanged<String>? onFromSubmitted;
  final ValueChanged<String>? onToSubmitted;

  const _SearchPill({
    required this.fromController,
    required this.toController,
    required this.fromFocus,
    required this.toFocus,
    this.onFromSubmitted,
    this.onToSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Color(0xFF888888),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              size: 15,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: fromController,
              focusNode: fromFocus,
              onSubmitted: onFromSubmitted,
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'From',
                hintStyle: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  color: Color(0xFFAAAAAA),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '→',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF888888),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: toController,
              focusNode: toFocus,
              onSubmitted: onToSubmitted,
              textInputAction: TextInputAction.done,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'To',
                hintStyle: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  color: Color(0xFFAAAAAA),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
