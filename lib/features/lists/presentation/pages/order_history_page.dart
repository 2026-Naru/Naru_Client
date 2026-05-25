import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../likes/presentation/pages/store_detail_page.dart';
import '../widgets/order_card.dart';

class OrderHistoryPage extends StatelessWidget {
  final bool isStandalone;

  const OrderHistoryPage({super.key, this.isStandalone = false});

  static const List<_OrderItem> _orders = [
    _OrderItem(
      title: 'Sinmigwan MALATANG',
      subtitle: 'Custom Mala Xiang Guo',
      price: '₩12,500',
      date: '26.04.01',
      imagePath: 'assets/images/cat_chicken_single.png',
      preset: StoreDetailPreset.chicken,
    ),
    _OrderItem(
      title: 'TangHwa MALATANG',
      subtitle: 'Chef\'s Choice Mala Tang',
      price: '₩28,500',
      date: '26.04.01',
      imagePath: 'assets/images/food_tteokbokki.png',
      preset: StoreDetailPreset.tteokbokki,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (!isStandalone) {
      return const _OrderList(orders: _orders);
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Total Orders',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                ],
              ),
            ),
            const Expanded(child: _OrderList(orders: _orders)),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<_OrderItem> orders;
  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = orders[index];
        return OrderCard(
          title: item.title,
          subtitle: item.subtitle,
          price: item.price,
          date: item.date,
          imagePath: item.imagePath,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StoreDetailPage(
                storeName: item.title,
                storeSubtitle: item.subtitle,
                heroImagePath: item.imagePath,
                logoImagePath: item.imagePath,
                preset: item.preset,
                bottomNavIndex: 3,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OrderItem {
  final String title;
  final String subtitle;
  final String price;
  final String date;
  final String imagePath;
  final StoreDetailPreset preset;

  const _OrderItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.date,
    required this.imagePath,
    required this.preset,
  });
}
