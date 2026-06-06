class FavoriteStoreModel {
  final int storeId;
  final String name;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final String? categoryName;

  const FavoriteStoreModel({
    required this.storeId,
    required this.name,
    this.imageUrl,
    required this.rating,
    required this.reviewCount,
    this.categoryName,
  });

  factory FavoriteStoreModel.fromJson(Map<String, dynamic> json) {
    final store = json['stores'] as Map<String, dynamic>?;
    final category = store?['categories'] as Map<String, dynamic>?;
    return FavoriteStoreModel(
      storeId: json['store_id'] as int? ?? (store?['id'] as int? ?? 0),
      name: store?['name'] as String? ?? '알 수 없는 가게',
      imageUrl: store?['image_url'] as String?,
      rating: (store?['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: store?['review_count'] as int? ?? 0,
      categoryName: category?['name'] as String?,
    );
  }
}
