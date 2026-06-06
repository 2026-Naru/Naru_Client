import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_client.dart';
import '../../../cart/domain/cart_item.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../lists/data/models/order_history_model.dart';
import '../../../lists/presentation/providers/orders_provider.dart';
import '../../../order/data/order_service.dart';
import 'payment_success_page.dart';

class OrderPage extends StatefulWidget {
  final String menuName;
  final String selectedSize;
  final String selectedJokbal;
  final String selectedDrink;
  final int totalPrice;
  final String menuImagePath;
  final bool isPickup;
  final List<CartItem>? cartItems;

  const OrderPage({
    super.key,
    required this.menuName,
    required this.selectedSize,
    required this.selectedJokbal,
    required this.selectedDrink,
    required this.totalPrice,
    required this.menuImagePath,
    required this.isPickup,
    this.cartItems,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPayment = 0;
  int _selectedRequirement = 0;
  bool _noUtensils = true;
  bool _isOrdering = false;
  OrderService? _orderService;

  static const _paymentMethods = [
    'Credit',
    'Apple Pay',
    'Kakao Pay',
    'Global Payments',
  ];

  static const _storeRequirements = [
    'No requirement',
    'Please make it less spicy',
    'Please keep sauce on the side',
    'Please avoid pork',
    'Please avoid seafood',
    'Please avoid nuts',
    'Please label spicy items',
    'Please call if an item is unavailable',
  ];

  String _formatPrice(int price) => price
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.isPickup ? 1 : 0,
    );
    _initOrderService();
  }

  Future<void> _initOrderService() async {
    final api = await ApiClient.getInstance();
    if (mounted) {
      setState(() => _orderService = OrderService(api));
    }
  }

  Future<void> _placeOrder() async {
    if (_isOrdering) return;
    setState(() => _isOrdering = true);

    final orderItems = _orderHistoryItems;
    final ordersProvider = context.read<OrdersProvider>();
    final cartProvider = context.read<CartProvider>();
    int? remoteOrderId;

    try {
      final type = _tabController.index == 0 ? 'DELIVERY' : 'PICKUP';
      final remoteOrder = await _orderService?.createOrder(
        type: type,
        totalAmount: widget.totalPrice,
        items: orderItems
            .map((item) => {
                  'quantity': item.quantity,
                  'price': item.unitPrice,
                })
            .toList(),
      );
      remoteOrderId = (remoteOrder?['id'] as num?)?.toInt();
    } catch (_) {
      // 실기기 테스트 중 서버 연결/장바구니 상태가 불안정해도 로컬 주문 내역은 유지한다.
    } finally {
      if (mounted) setState(() => _isOrdering = false);
    }

    if (!mounted) return;
    await ordersProvider.recordLocalOrder(
      remoteOrderId: remoteOrderId,
      storeName: 'Simin Jokbal Bossam Sillim',
      storeImageUrl: widget.menuImagePath,
      totalAmount: widget.totalPrice,
      items: orderItems,
    );
    if (widget.cartItems != null) {
      cartProvider.clear();
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessPage(totalPrice: widget.totalPrice),
      ),
    );
  }

  List<OrderHistoryItemModel> get _orderHistoryItems {
    final cartItems = widget.cartItems;
    if (cartItems != null && cartItems.isNotEmpty) {
      return cartItems
          .map((item) => OrderHistoryItemModel(
                name: item.menuName,
                imageUrl: item.imagePath,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
              ))
          .toList();
    }

    return [
      OrderHistoryItemModel(
        name: widget.menuName,
        imageUrl: widget.menuImagePath,
        quantity: 1,
        unitPrice: widget.totalPrice,
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonLabel = widget.isPickup ? 'Pick Up Order' : 'Delivery Order';

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            _buildTabs(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMenuCard(),
                    const SizedBox(height: 12),
                    _buildStoreCard(),
                    const SizedBox(height: 12),
                    _buildRequirementCard(),
                    const SizedBox(height: 12),
                    _buildPaymentCard(),
                    const SizedBox(height: 12),
                    _buildCouponCard(),
                    const SizedBox(height: 20),
                    _buildPaymentSummary(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomBar(buttonLabel),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: AppColors.textPrimary),
          ),
          const Expanded(
            child: Text(
              'Order',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.textPrimary,
      unselectedLabelColor: AppColors.inactive,
      indicatorColor: AppColors.textPrimary,
      indicatorWeight: 2,
      labelStyle: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      tabs: const [Tab(text: 'Delivery'), Tab(text: 'Pickup')],
    );
  }

  Widget _buildMenuCard() {
    final items = widget.cartItems;
    if (items != null && items.isNotEmpty) {
      return _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map((item) => Padding(
                    padding:
                        EdgeInsets.only(bottom: items.last == item ? 0 : 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(item.imagePath,
                              width: 64, height: 64, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.menuName,
                                  style: const TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  )),
                              const SizedBox(height: 2),
                              Text(item.optionsSummary, style: _subtitleStyle),
                              const SizedBox(height: 4),
                              Text(
                                '₩${_formatPrice(item.totalPrice)}  ×${item.quantity}',
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
    }

    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              widget.menuImagePath,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.menuName,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(widget.selectedSize, style: _subtitleStyle),
                Text(widget.selectedJokbal, style: _subtitleStyle),
                Text(widget.selectedDrink, style: _subtitleStyle),
                const SizedBox(height: 8),
                Text(
                  '₩${_formatPrice(widget.totalPrice)}',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard() {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE4E6E8), width: 1),
            ),
            child: Image.asset(widget.menuImagePath, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simin Jokbal Bossam Sillim',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Sillim-dong, Gwanak-gu, Seoul',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDDDDDD)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'copy',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Store requirement',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedRequirement,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    size: 20, color: AppColors.textSecondary),
                borderRadius: BorderRadius.circular(12),
                menuMaxHeight: 320,
                selectedItemBuilder: (context) {
                  return _storeRequirements.map((label) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList();
                },
                items: _storeRequirements.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedRequirement = value);
                },
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                dropdownColor: AppColors.bgWhite,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: _selectedRequirement == 0
                ? const SizedBox.shrink()
                : Text(
                    _storeRequirements[_selectedRequirement],
                    key: ValueKey(_selectedRequirement),
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.25,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _noUtensils = !_noUtensils),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _noUtensils
                        ? AppColors.textPrimary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _noUtensils
                          ? AppColors.textPrimary
                          : const Color(0xFFCCCCCC),
                      width: 1.5,
                    ),
                  ),
                  child: _noUtensils
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                const Text(
                  'No utensils needed',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ..._paymentMethods.asMap().entries.map((e) {
            final selected = e.key == _selectedPayment;
            return GestureDetector(
              onTap: () => setState(() => _selectedPayment = e.key),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? AppColors.brandOrange
                              : const Color(0xFFCCCCCC),
                          width: selected ? 6 : 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      e.value,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.w500 : FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCouponCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Discount coupon',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'No coupon is available',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right,
                    size: 20, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          const Row(
            children: [
              Text(
                'Ponits',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Spacer(),
              Text(
                '0',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.chevron_right,
                  size: 18, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return _Card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '₩${_formatPrice(widget.totalPrice)}',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Payment',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '₩${_formatPrice(widget.totalPrice)}',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(String label) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: AppColors.bgWhite,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: GestureDetector(
          onTap: _isOrdering ? null : _placeOrder,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.brandOrange,
              borderRadius: BorderRadius.circular(28),
            ),
            alignment: Alignment.center,
            child: _isOrdering
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  static const _subtitleStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 13,
    color: AppColors.textSecondary,
    height: 1.4,
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
      ),
      child: child,
    );
  }
}
