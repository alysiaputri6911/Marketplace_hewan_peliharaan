
class Product {
  final int id;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String image;
  final String status;
  final String categoryName;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.image,
    required this.status,
    required this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse('${json['id']}') ?? 0,
      categoryId: int.tryParse('${json['category_id']}') ?? 0,
      name: '${json['name'] ?? ''}',
      description: '${json['description'] ?? ''}',
      price: double.tryParse('${json['price']}') ?? 0,
      stock: int.tryParse('${json['stock']}') ?? 0,
      image: '${json['image'] ?? ''}',
      status: '${json['status'] ?? ''}',
      categoryName: '${json['category_name'] ?? ''}',
    );
  }
}
