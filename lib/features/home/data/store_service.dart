import '../../../core/services/api_client.dart';

class StoreService {
  final ApiClient _api;

  StoreService(this._api);

  Future<List<NaruStore>> fetchNearbyStores() async {
    final res = await _api.get('/stores/nearby');
    final list = res['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => NaruStore.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<NaruStore?> fetchStore(int storeId) async {
    final res = await _api.get('/stores/$storeId');
    final data = res['data'] as Map<String, dynamic>?;
    if (data == null) return null;
    return NaruStore.fromJson(data);
  }

  Future<List<NaruStore>> searchStores(String query) async {
    final res = await _api.get(
      '/stores/search',
      queryParameters: {'query': query},
    );
    final list = res['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => NaruStore.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<NaruMenu>> fetchMenus(int storeId) async {
    final res = await _api.get('/stores/$storeId/menus');
    final list = res['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => NaruMenu.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<NaruReview>> fetchReviews(int storeId) async {
    final res = await _api.get('/stores/$storeId/reviews');
    final list = res['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => NaruReview.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class NaruStore {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final String? address;
  final String? categoryName;
  final String deliveryTime;

  const NaruStore({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.rating,
    required this.reviewCount,
    this.address,
    this.categoryName,
    required this.deliveryTime,
  });

  factory NaruStore.fromJson(Map<String, dynamic> json) {
    final category = json['categories'] as Map<String, dynamic>?;
    return NaruStore(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Unknown Store',
      description: json['description'] as String? ??
          json['subtitle'] as String? ??
          'Fresh menus ready to order.',
      imageUrl: json['image_url'] as String? ??
          json['image'] as String? ??
          json['hero_image'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      address: json['address'] as String?,
      categoryName: category?['name'] as String? ?? json['category'] as String?,
      deliveryTime: json['delivery_time'] as String? ?? '25~40min',
    );
  }

  String get displayImage => imageUrl ?? fallbackImage;

  String get fallbackImage {
    final lower = name.toLowerCase();
    if (lower.contains('tteok') || lower.contains('ddukbokki')) {
      return 'assets/images/food_tteokbokki.png';
    }
    if (lower.contains('chicken')) return 'assets/images/franchise_nene_bg.png';
    if (lower.contains('coffee') || lower.contains('cafe')) {
      return 'assets/images/food_cafe.png';
    }
    return 'assets/images/food_jokbal.png';
  }
}

class NaruMenu {
  final int id;
  final int storeId;
  final String name;
  final String description;
  final int price;
  final String? imageUrl;
  final String? allergyNotice;

  const NaruMenu({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.allergyNotice,
  });

  factory NaruMenu.fromJson(Map<String, dynamic> json) {
    return NaruMenu(
      id: (json['id'] as num?)?.toInt() ?? 0,
      storeId: (json['store_id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Menu',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url'] as String? ?? json['image'] as String?,
      allergyNotice:
          json['allergy_notice'] as String? ?? json['allergy_tags'] as String?,
    );
  }

  String get displayImage => imageUrl ?? 'assets/images/food_jokbal.png';
}

class NaruReview {
  final int id;
  final int rating;
  final String content;
  final String? country;
  final String? imageUrl;
  final String createdAt;
  final String userName;

  const NaruReview({
    required this.id,
    required this.rating,
    required this.content,
    this.country,
    this.imageUrl,
    required this.createdAt,
    required this.userName,
  });

  factory NaruReview.fromJson(Map<String, dynamic> json) {
    final user = json['users'] as Map<String, dynamic>?;
    return NaruReview(
      id: (json['id'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      content: json['content'] as String? ?? '',
      country: json['country'] as String?,
      imageUrl: json['image_url'] as String? ??
          json['imageUrl'] as String? ??
          json['review_image_url'] as String? ??
          json['reviewImageUrl'] as String? ??
          json['photo_url'] as String? ??
          json['photoUrl'] as String? ??
          json['image'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      userName: user?['name'] as String? ?? 'Naru User',
    );
  }

  String get timeAgo {
    final date = DateTime.tryParse(createdAt);
    if (date == null) return 'recently';
    final days = DateTime.now().difference(date).inDays;
    if (days <= 0) return 'today';
    if (days < 7) return '$days days ago';
    if (days < 30) return '${days ~/ 7} weeks ago';
    return '${days ~/ 30} months ago';
  }
}
