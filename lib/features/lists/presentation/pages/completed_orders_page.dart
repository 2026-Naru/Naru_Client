import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../likes/presentation/pages/store_detail_page.dart';

class CompletedOrdersPage extends StatefulWidget {
  const CompletedOrdersPage({super.key});

  @override
  State<CompletedOrdersPage> createState() => _CompletedOrdersPageState();
}

class _CompletedOrdersPageState extends State<CompletedOrdersPage> {
  String _selectedCategory = 'ALL';

  static const _categories = ['ALL', 'Korean', 'Street', 'BBQ', 'Chicken', 'Asian'];

  static const _orders = [
    _CompletedOrder(
      date: '4.1 WED',
      status: 'Purchase Confirmed',
      title: 'Hongik University Rice Noodles',
      detail: 'Queue Number 317  |  2 guests',
      category: 'Korean',
      imagePath: 'assets/images/cat_korean.png',
      preset: StoreDetailPreset.jokbal,
    ),
    _CompletedOrder(
      date: '4.1 WED',
      status: 'Purchase Confirmed',
      title: 'Hongik University Rice Noodles',
      detail: 'Queue Number 317  |  2 guests',
      category: 'Korean',
      imagePath: 'assets/images/cat_korean.png',
      preset: StoreDetailPreset.jokbal,
    ),
  ];

  List<_CompletedOrder> get _filtered {
    if (_selectedCategory == 'ALL') return _orders;
    return _orders.where((o) => o.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final selected = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.brandOrange : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.brandOrange : const Color(0xFFD0D0D0),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'No completed orders',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final order = filtered[i];
                    final showDate = i == 0 || filtered[i - 1].date != order.date;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDate)
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, i == 0 ? 16 : 20, 20, 8),
                            child: Text(
                              order.date,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        _CompletedOrderRow(
                          order: order,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoreDetailPage(
                                storeName: order.title,
                                storeSubtitle: order.detail,
                                heroImagePath: order.imagePath,
                                logoImagePath: order.imagePath,
                                preset: order.preset,
                                bottomNavIndex: 3,
                              ),
                            ),
                          ),
                        ),
                        if (i < filtered.length - 1)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFEEEEEE),
                            indent: 20,
                            endIndent: 20,
                          ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CompletedOrderRow extends StatelessWidget {
  final _CompletedOrder order;
  final VoidCallback? onTap;
  const _CompletedOrderRow({required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Image and text are tappable — navigates to store detail
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 80,
              height: 80,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
                color: const Color(0xFFF3F5F7),
              ),
              child: Image.asset(order.imagePath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.status,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.detail,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Reorder button — separate tap area, does not trigger navigation
          GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.brandOrange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Reorder',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedOrder {
  final String date;
  final String status;
  final String title;
  final String detail;
  final String category;
  final String imagePath;
  final StoreDetailPreset preset;

  const _CompletedOrder({
    required this.date,
    required this.status,
    required this.title,
    required this.detail,
    required this.category,
    required this.imagePath,
    required this.preset,
  });
}
