class FavoriteStoreModel {
  final int storeId;
  final String name;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final String? categoryName;
  final bool syncRemote;

  const FavoriteStoreModel({
    required this.storeId,
    required this.name,
    this.imageUrl,
    required this.rating,
    required this.reviewCount,
    this.categoryName,
    this.syncRemote = true,
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
      syncRemote: true,
    );
  }

  factory FavoriteStoreModel.fromLocalJson(Map<String, dynamic> json) {
    return FavoriteStoreModel(
      storeId: json['storeId'] as int? ?? 0,
      name: json['name'] as String? ?? '알 수 없는 가게',
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      categoryName: json['categoryName'] as String?,
      syncRemote: json['syncRemote'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'storeId': storeId,
      'name': name,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'categoryName': categoryName,
      'syncRemote': syncRemote,
    };
  }
}
