import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PendingOrdersPage extends StatefulWidget {
  const PendingOrdersPage({super.key});

  @override
  State<PendingOrdersPage> createState() => _PendingOrdersPageState();
}

class _PendingOrdersPageState extends State<PendingOrdersPage> {
  String _selectedCategory = 'ALL';

  static const _categories = ['ALL', 'Korean', 'Street', 'BBQ', 'Chicken', 'Asian'];

  static const _orders = [
    _PendingOrder(
      date: '4.5 SUN',
      status: 'Pending',
      category: 'Chicken',
      title: 'BHC Chicken Myeongdong',
      statusText: 'Order Being Prepared',
      imagePath: 'assets/images/cat_bhc.png',
    ),
    _PendingOrder(
      date: '4.5 SUN',
      status: 'Pending',
      category: 'Chicken',
      title: 'Kyochon Chicken Jongno 1st Store',
      statusText: 'Order Being Prepared',
      imagePath: 'assets/images/franchise_nene_bg.png',
    ),
    _PendingOrder(
      date: '4.5 SUN',
      status: 'Pending',
      category: 'Korean',
      title: 'East Village Seoul',
      statusText: 'Order Being Prepared',
      imagePath: 'assets/images/cat_korean.png',
    ),
  ];

  List<_PendingOrder> get _filtered {
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
                    'No pending orders',
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
                  itemBuilder: (_, i) {
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
                        _PendingOrderRow(order: order),
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

class _PendingOrderRow extends StatelessWidget {
  final _PendingOrder order;
  const _PendingOrderRow({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.status}  |  ${order.category}',
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
                  order.statusText,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.brandOrange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingOrder {
  final String date;
  final String status;
  final String category;
  final String title;
  final String statusText;
  final String imagePath;

  const _PendingOrder({
    required this.date,
    required this.status,
    required this.category,
    required this.title,
    required this.statusText,
    required this.imagePath,
  });
}
