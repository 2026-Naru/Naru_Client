import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/main_tab_page.dart';
import '../../../likes/data/models/favorite_store_model.dart';
import '../../../likes/presentation/pages/favorites_page.dart';
import '../../../likes/presentation/providers/favorites_provider.dart';
import '../../../lists/presentation/pages/order_history_page.dart';
import '../../../lists/presentation/providers/orders_provider.dart';
import '../providers/user_provider.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with WidgetsBindingObserver {
  static const _fallbackAddress = _MyPageAddress(
    title: 'Sillim-dong, Gwanak-gu, Seoul',
    subtitle: 'South Korea',
  );

  _MyPageAddress _address = _fallbackAddress;
  ValueNotifier<int>? _mainTabNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAddress();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetch();
      context.read<FavoritesProvider>().fetch();
      context.read<OrdersProvider>().fetchAll();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = MainTabScope.of(context);
    if (_mainTabNotifier == notifier) return;

    _mainTabNotifier?.removeListener(_handleMainTabChanged);
    _mainTabNotifier = notifier;
    _mainTabNotifier?.addListener(_handleMainTabChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mainTabNotifier?.removeListener(_handleMainTabChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAddress();
    }
  }

  void _handleMainTabChanged() {
    if (_mainTabNotifier?.value == 4) {
      _loadAddress();
      context.read<OrdersProvider>().fetchAll();
    }
  }

  void _showExchangeCurrencyDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => const _ExchangeCurrencyDialog(),
    );
  }

  Future<void> _loadAddress() async {
    final address = await _MyPageAddressResolver.resolve();
    if (!mounted) return;
    setState(() => _address = address);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final favoritesProvider = context.watch<FavoritesProvider>();
    final ordersProvider = context.watch<OrdersProvider>();
    final favCount = favoritesProvider.count;
    final orderCount = ordersProvider.all.length;
    final favoritePreviewStores = favoritesProvider.favorites.take(3).toList();
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'MY Naru',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEAB2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF9D8752),
                                width: 1.6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Image.asset(
                                'assets/images/mypage_profile.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user?.name ?? 'Baegopa',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(user?.email ?? '',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 11,
                                color: AppColors.textGray,
                                height: 1.2,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _InfoCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: Icon(
                              Icons.location_on_outlined,
                              size: 17,
                              color: AppColors.brandOrange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _address.title,
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _address.subtitle,
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 10.5,
                                    color: AppColors.textSecondary,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _InfoCard(
                      child: Column(
                        children: [
                          _InfoRow(label: 'Coupon Box', value: '0'),
                          Divider(
                            color: AppColors.border,
                            height: 14,
                            thickness: 1,
                          ),
                          _InfoRow(label: 'Point', value: '0'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ExchangeAmountCard(
                      balanceKrw: user?.balanceKrw ?? 0,
                      onTap: _showExchangeCurrencyDialog,
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      child: SizedBox(
                        height: 34,
                        child: _InfoRow(
                          label: 'Total Orders',
                          value: '$orderCount',
                          showArrow: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const OrderHistoryPage(isStandalone: true),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            label: 'Stores you liked',
                            value: '$favCount',
                            showArrow: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FavoritesPage(),
                              ),
                            ),
                          ),
                          if (favoritePreviewStores.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _LikedStoresPreview(stores: favoritePreviewStores),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 94,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2B2B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1A1A1A)),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Get on the promo',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontSize: 9,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Order Right Now and',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                  ),
                                ),
                                Text(
                                  'Get 20% Off',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Image.asset(
                            'assets/images/delivery_mascot.png',
                            width: 74,
                            height: 74,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NaruBottomNavBar(currentIndex: 4),
    );
  }
}

class _MyPageAddress {
  final String title;
  final String subtitle;

  const _MyPageAddress({
    required this.title,
    required this.subtitle,
  });
}

class _MyPageAddressResolver {
  static Future<_MyPageAddress> resolve() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return _MyPageState._fallbackAddress;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _MyPageState._fallbackAddress;
      }

      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      final position = lastKnownPosition ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 8),
            ),
          );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) return _MyPageState._fallbackAddress;

      return _fromPlacemark(placemarks.first);
    } catch (_) {
      return _MyPageState._fallbackAddress;
    }
  }

  static _MyPageAddress _fromPlacemark(Placemark placemark) {
    final title = _joinUnique([
      placemark.subLocality,
      placemark.locality,
      placemark.subAdministrativeArea,
      placemark.administrativeArea,
    ]);

    final subtitle = _joinUnique([
      placemark.street,
      placemark.country,
    ]);

    return _MyPageAddress(
      title: title.isEmpty ? _MyPageState._fallbackAddress.title : title,
      subtitle:
          subtitle.isEmpty ? _MyPageState._fallbackAddress.subtitle : subtitle,
    );
  }

  static String _joinUnique(List<String?> values) {
    final normalized = <String>[];
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) continue;
      if (normalized.contains(trimmed)) continue;
      normalized.add(trimmed);
    }
    return normalized.join(', ');
  }
}

class _ExchangeCurrencyDialog extends StatefulWidget {
  const _ExchangeCurrencyDialog();

  @override
  State<_ExchangeCurrencyDialog> createState() =>
      _ExchangeCurrencyDialogState();
}

class _ExchangeCurrencyDialogState extends State<_ExchangeCurrencyDialog> {
  static const double _krwPerUsd = 1350;

  final TextEditingController _amountController = TextEditingController();
  String _inputValue = '';
  bool _isUsdToKrw = true;

  String get _sourceCode => _isUsdToKrw ? 'USD' : 'KRW';
  String get _sourceName => _isUsdToKrw ? 'US Dollar' : 'Korean Won';
  String get _targetCode => _isUsdToKrw ? 'KRW' : 'USD';
  String get _targetName => _isUsdToKrw ? 'Korean Won' : 'US Dollar';

  double get _convertedValue {
    final amount = double.tryParse(_inputValue) ?? 0;
    return _isUsdToKrw ? amount * _krwPerUsd : amount / _krwPerUsd;
  }

  String get _convertedText {
    if (_isUsdToKrw) {
      return _formatKrw(_convertedValue.round());
    }
    return '\$${_convertedValue.toStringAsFixed(2)} USD';
  }

  String _formatKrw(int value) {
    final raw = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(raw[i]);
    }
    final sign = value < 0 ? '-' : '';
    return '${sign}KRW ${buffer.toString()}';
  }

  void _swapDirection() {
    setState(() {
      _isUsdToKrw = !_isUsdToKrw;
      _amountController.clear();
      _inputValue = '';
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bgWhite,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exchange Currency',
                  style: AppTextStyles.h2.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _CurrencyInfo(
                        code: _sourceCode,
                        name: _sourceName,
                      ),
                    ),
                    const SizedBox(width: 58),
                    Expanded(
                      child: _CurrencyInfo(
                        code: _targetCode,
                        name: _targetName,
                      ),
                    ),
                  ],
                ),
                Transform.translate(
                  offset: const Offset(0, -42),
                  child: Center(
                    child: IconButton.filled(
                      onPressed: _swapDirection,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.brandOrange,
                        foregroundColor: Colors.white,
                        fixedSize: const Size(44, 44),
                      ),
                      icon: Icon(
                        _isUsdToKrw
                            ? Icons.arrow_forward_rounded
                            : Icons.arrow_back_rounded,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Enter $_sourceCode amount',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: (value) => setState(() => _inputValue = value),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    prefixText: '$_sourceCode ',
                    hintText: 'Enter $_sourceCode amount',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                    filled: true,
                    fillColor: AppColors.bgInput,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.brandOrange,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4EF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.brandOrange.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Converted Amount ($_targetCode)',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _convertedText,
                        style: AppTextStyles.h2.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.brandOrange,
                      textStyle: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrencyInfo extends StatelessWidget {
  final String code;
  final String name;

  const _CurrencyInfo({
    required this.code,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          code,
          style: AppTextStyles.h2.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _ExchangeAmountCard extends StatelessWidget {
  static const double _cardHeight = 114.5;

  final int balanceKrw;
  final VoidCallback? onTap;

  const _ExchangeAmountCard({
    required this.balanceKrw,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: _cardHeight,
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 1.1),
        ),
        padding: const EdgeInsets.fromLTRB(17, 10, 17, 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 17,
              child: Text(
                'Exchanged amount',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: -10,
              child: Image.asset(
                'assets/images/mypage_lang.png',
                width: 95,
                height: 95,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 46,
              child: Container(height: 1, color: const Color(0xFF1F1F1F)),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    CurrencyFormatter.formatKrw(balanceKrw),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 26,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF6E6E6E), width: 0.95),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showArrow;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.label,
    required this.value,
    this.showArrow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              if (showArrow)
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LikedStoresPreview extends StatelessWidget {
  static const double _gap = 8;

  final List<FavoriteStoreModel> stores;

  const _LikedStoresPreview({required this.stores});

  @override
  Widget build(BuildContext context) {
    final previewStores = stores.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            ((constraints.maxWidth - (_gap * 2)) / 3).clamp(76.0, 110.0);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < previewStores.length; i++) ...[
              if (i > 0) const SizedBox(width: _gap),
              _StoreThumb(
                width: itemWidth.toDouble(),
                label: previewStores[i].name,
                imageUrl: previewStores[i].imageUrl,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _StoreThumb extends StatelessWidget {
  final double width;
  final String label;
  final String? imageUrl;

  const _StoreThumb({
    required this.width,
    required this.label,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          width: width,
          height: width * 0.86,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: const Color(0xFF7B7B7B), width: 0.8),
            color: AppColors.bgLight,
          ),
          child: _buildImage(),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: width,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10.5,
              color: AppColors.textSecondary,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return const _StoreThumbFallback();

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _StoreThumbFallback(),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _StoreThumbFallback(),
    );
  }
}

class _StoreThumbFallback extends StatelessWidget {
  const _StoreThumbFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.storefront_outlined,
        size: 28,
        color: AppColors.textMuted,
      ),
    );
  }
}
