import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class NavigationSearchPage extends StatefulWidget {
  const NavigationSearchPage({super.key});

  @override
  State<NavigationSearchPage> createState() => _NavigationSearchPageState();
}

class _NavigationSearchPageState extends State<NavigationSearchPage> {
  final TextEditingController _controller = TextEditingController();

  static const List<String> _recents = [
    'Sillim Station Exit 2',
    'Hongdae',
    'Sinchon Station',
    'Hongik University',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.bgWhite,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            size: 16,
                            color: AppColors.inactive,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search name of place',
                                hintStyle: AppTextStyles.body.copyWith(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                                border: InputBorder.none,
                                isCollapsed: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.separator),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Row(
                children: [
                  Text(
                    'Recent searches',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: _recents.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: AppColors.separator, height: 1),
                itemBuilder: (_, i) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  minLeadingWidth: 24,
                  leading: const Icon(
                    Icons.history_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  title: Text(
                    _recents[i],
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13,
                      color: AppColors.textPrimary,
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
