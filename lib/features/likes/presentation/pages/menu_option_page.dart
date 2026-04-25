import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'cart_page.dart';

class MenuOptionPage extends StatefulWidget {
  final String rank;
  final String menuName;
  final String description;
  final String imagePath;

  const MenuOptionPage({
    super.key,
    required this.rank,
    required this.menuName,
    required this.description,
    required this.imagePath,
  });

  @override
  State<MenuOptionPage> createState() => _MenuOptionPageState();
}

class _MenuOptionPageState extends State<MenuOptionPage> {
  int _selectedSize = 0;
  int _selectedJokbal = 0;
  int _selectedDrink = 0;
  int _quantity = 1;

  static const _sizes = [
    _Option('Small (2–3 servings)', '₩38,000', 38000),
    _Option('Medium (3–4 servings)', '₩48,000', 48000),
    _Option('Large (4–5 servings)', '₩58,000', 58000),
  ];

  static const _jokbals = [
    _Option('Jokbal', '+ ₩0', 0),
    _Option('Medium (3–4 servings)', '+ ₩3,000', 3000),
    _Option('Large (4–5 servings)', '+ ₩3,000', 3000),
  ];

  static const _drinks = [
    _Option('CokaCola 500ml', '+ ₩0', 0),
    _Option('Sprite 500ml', '+ ₩0', 0),
    _Option('Fanta', '+ ₩1,000', 1000),
  ];

  int get _totalPrice {
    final base = _sizes[_selectedSize].price;
    final jokbalAdd = _jokbals[_selectedJokbal].price;
    final drinkAdd = _drinks[_selectedDrink].price;
    return (base + jokbalAdd + drinkAdd) * _quantity;
  }

  String get _orderLabel {
    final formatted = _totalPrice.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]},',
        );
    return 'Order ₩$formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RankBadge(label: widget.rank),
                        const SizedBox(height: 8),
                        Text(
                          widget.menuName,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFFFC107), size: 15),
                            const SizedBox(width: 3),
                            const Text(
                              '3.2',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '(132)',
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.chevron_right,
                                size: 16, color: AppColors.textSecondary),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.description,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 20),
                        _OptionSection(
                          title: 'Price',
                          options: _sizes,
                          selectedIndex: _selectedSize,
                          onChanged: (i) => setState(() => _selectedSize = i),
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 20),
                        _OptionSection(
                          title: 'Choose Jokbal',
                          options: _jokbals,
                          selectedIndex: _selectedJokbal,
                          onChanged: (i) => setState(() => _selectedJokbal = i),
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 20),
                        _OptionSection(
                          title: 'Choose Drink',
                          options: _drinks,
                          selectedIndex: _selectedDrink,
                          onChanged: (i) => setState(() => _selectedDrink = i),
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 20),
                        _QuantityRow(
                          quantity: _quantity,
                          onDecrement: () {
                            if (_quantity > 1) setState(() => _quantity--);
                          },
                          onIncrement: () => setState(() => _quantity++),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _BottomBar(
            orderLabel: _orderLabel,
            onOrder: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CartPage(
                  menuName: widget.menuName,
                  selectedSize: _sizes[_selectedSize].label,
                  selectedJokbal: _jokbals[_selectedJokbal].label,
                  selectedDrink: 'Drink Choice 500ml',
                  totalPrice: _totalPrice,
                  quantity: _quantity,
                  menuImagePath: widget.imagePath,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.bgWhite,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              size: 16, color: AppColors.textPrimary),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Image.asset(widget.imagePath, fit: BoxFit.cover),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final String label;
  const _RankBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _OptionSection extends StatelessWidget {
  final String title;
  final List<_Option> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _OptionSection({
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...options.asMap().entries.map((e) {
          final i = e.key;
          final opt = e.value;
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(i),
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
                  Expanded(
                    child: Text(
                      opt.label,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.w500 : FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    opt.priceLabel,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _QuantityRow extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityRow({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'quantity',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFDDDDDD), width: 1.2),
          ),
          child: Row(
            children: [
              _QtyButton(icon: Icons.remove, onTap: onDecrement),
              SizedBox(
                width: 36,
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _QtyButton(icon: Icons.add, onTap: onIncrement),
            ],
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String orderLabel;
  final VoidCallback onOrder;
  const _BottomBar({required this.orderLabel, required this.onOrder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.bgWhite,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Minimum Order',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '₩ 15,000',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: onOrder,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.brandOrange,
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: Text(
                  orderLabel,
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
        ],
      ),
    );
  }
}

class _Option {
  final String label;
  final String priceLabel;
  final int price;

  const _Option(this.label, this.priceLabel, this.price);
}
