import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import 'navigation_route_results_page.dart';

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
  bool _toActive = false;

  static const _suggestions = [
    'Hongdae',
    'Hongdaesterrt',
    'HongJjimdak',
    'Sinchon Station',
    'Sillim Station Exit 2',
  ];

  List<String> get _filtered {
    final query = _fromActive
        ? _fromController.text
        : _toController.text;
    if (query.isEmpty) return _suggestions;
    return _suggestions
        .where((s) => s.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fromFocus.addListener(() => setState(() => _fromActive = _fromFocus.hasFocus));
    _toFocus.addListener(() => setState(() => _toActive = _toFocus.hasFocus));
    _fromController.addListener(() => setState(() {}));
    _toController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _fromFocus.requestFocus());
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
      Future.delayed(const Duration(milliseconds: 100), () => _toFocus.requestFocus());
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
          builder: (_) => NavigationRouteResultsPage(from: from, to: to),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showSuggestions = _fromActive || _toActive;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5F7),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/pin.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        AppColors.textPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InlineField(
                            controller: _fromController,
                            focusNode: _fromFocus,
                            hint: 'From',
                            onSubmitted: (_) => _toFocus.requestFocus(),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Divider(height: 1, color: Color(0xFFDDDDDD)),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _InlineField(
                                  controller: _toController,
                                  focusNode: _toFocus,
                                  hint: 'To',
                                  onSubmitted: (_) => _tryNavigate(),
                                ),
                              ),
                              SvgPicture.asset(
                                'assets/icons/arrow.svg',
                                width: 18,
                                height: 18,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.textSecondary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (showSuggestions)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) {
                    final s = _filtered[i];
                    return InkWell(
                      onTap: () => _fillSuggestion(s),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.north_west_rounded,
                              size: 16,
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
              )
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

class _InlineField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final ValueChanged<String>? onSubmitted;

  const _InlineField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.next,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 15,
          color: Color(0xFFBBBBBB),
        ),
        border: InputBorder.none,
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
