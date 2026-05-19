class CategoryModel {
  final String title;
  final String description;
  final String image;
  final List<CategoryItemModel> items;

  const CategoryModel({
    required this.title,
    required this.description,
    required this.image,
    required this.items,
  });
}

class CategoryItemModel {
  final String name;
  final String description;
  final String image;

  const CategoryItemModel({
    required this.name,
    required this.description,
    required this.image,
  });
}
