class ViewedStoreModel {
  final int storeId;
  final String name;
  final String? description;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final String? categoryName;
  final String viewedAt;
  final bool isLocal;

  const ViewedStoreModel({
    required this.storeId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.rating,
    required this.reviewCount,
    this.categoryName,
    required this.viewedAt,
    this.isLocal = false,
  });

  factory ViewedStoreModel.fromJson(Map<String, dynamic> json) {
    final store = json['stores'] as Map<String, dynamic>? ?? json;
    final category = store['categories'] as Map<String, dynamic>?;
    return ViewedStoreModel(
      storeId: (json['store_id'] as num?)?.toInt() ??
          (store['id'] as num?)?.toInt() ??
          0,
      name: store['name'] as String? ?? 'Unknown Store',
      description:
          store['description'] as String? ?? store['subtitle'] as String?,
      imageUrl: store['image_url'] as String? ??
          store['image'] as String? ??
          store['hero_image'] as String?,
      rating: (store['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (store['review_count'] as num?)?.toInt() ?? 0,
      categoryName:
          category?['name'] as String? ?? store['category'] as String?,
      viewedAt: json['viewed_at'] as String? ??
          json['viewedAt'] as String? ??
          DateTime.now().toIso8601String(),
    );
  }

  factory ViewedStoreModel.fromLocalJson(Map<String, dynamic> json) {
    return ViewedStoreModel(
      storeId: (json['storeId'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Unknown Store',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      categoryName: json['categoryName'] as String?,
      viewedAt: json['viewedAt'] as String? ?? DateTime.now().toIso8601String(),
      isLocal: true,
    );
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'storeId': storeId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'categoryName': categoryName,
      'viewedAt': viewedAt,
    };
  }

  String get displayImage => imageUrl ?? 'assets/images/food_jokbal.png';

  String get formattedViewedAt {
    final date = DateTime.tryParse(viewedAt);
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.month}.${date.day}';
  }
}
