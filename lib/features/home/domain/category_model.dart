class CategoryModel {
  final String id;
  final String title;
  final String image;
  final String description;
  final List<CategoryItemModel> items;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.image,
    required this.description,
    required this.items,
  });
}

class CategoryItemModel {
  final String name;
  final String image;
  final String description;

  const CategoryItemModel({
    required this.name,
    required this.image,
    required this.description,
  });
}
