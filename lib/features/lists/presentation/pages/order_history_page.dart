import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/order_history_model.dart';
import '../providers/orders_provider.dart';

class OrderHistoryPage extends StatefulWidget {
  final bool isStandalone;

  const OrderHistoryPage({super.key, this.isStandalone = false});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = _OrderHistoryBody(
      onRefresh: () => context.read<OrdersProvider>().fetchAll(),
    );

    if (!widget.isStandalone) return body;

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
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _OrderHistoryBody extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _OrderHistoryBody({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.all.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.all.isEmpty) {
          return _OrdersMessage(
            icon: Icons.wifi_off_outlined,
            title: 'Could not load orders',
            subtitle: 'Please check your network and try again.',
            actionLabel: 'Retry',
            onAction: onRefresh,
          );
        }

        if (provider.all.isEmpty) {
          return const _OrdersMessage(
            icon: Icons.receipt_long_outlined,
            title: 'No delivery orders yet',
            subtitle: 'Your ordered food list will appear here.',
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          color: AppColors.brandOrange,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
            itemCount: provider.all.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = provider.all[index];
              final showDate = index == 0 ||
                  provider.all[index - 1].formattedDate != order.formattedDate;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDate && order.formattedDate.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        4,
                        index == 0 ? 4 : 10,
                        4,
                        8,
                      ),
                      child: Text(
                        order.formattedDate,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  _OrderHistoryRow(order: order),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _OrderHistoryRow extends StatelessWidget {
  final OrderHistoryModel order;

  const _OrderHistoryRow({required this.order});

  static String _formatPrice(int price) => CurrencyFormatter.formatKrw(price);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF747474), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OrderImage(imageUrl: order.displayImageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.itemSummary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11,
                        color: Color(0xFF8D8D8D),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        order.displayStatus,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 11,
                          color: AppColors.brandOrange,
                          height: 1.1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatPrice(order.totalAmount),
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11,
                        color: AppColors.textPrimary,
                        height: 1.1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                order.id > 0 ? '#${order.id}' : 'local',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 9.3,
                  color: Color(0xFFA0A0A0),
                  height: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderImage extends StatelessWidget {
  final String? imageUrl;

  const _OrderImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF8B8B8B), width: 0.9),
        color: AppColors.bgLight,
      ),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return const _OrderImageFallback();

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _OrderImageFallback(),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _OrderImageFallback(),
    );
  }
}

class _OrderImageFallback extends StatelessWidget {
  const _OrderImageFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.restaurant_outlined,
        size: 28,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _OrdersMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _OrdersMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
