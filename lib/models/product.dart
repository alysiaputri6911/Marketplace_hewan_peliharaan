
class Product {
  final int id;
  final int categoryId;
  final String categoryName;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String status;
  final String image;


  const Product({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.status,
    required this.image,

  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      categoryId:
      int.tryParse('${json['category_id'] ?? 0}') ?? 0,
      categoryName: json['category_name']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: double.tryParse('${json['price'] ?? 0}') ?? 0,
      stock: int.tryParse('${json['stock'] ?? 0}') ?? 0,
      status: json['status']?.toString() ?? '',
      image: json['image']?.toString() ?? '',

    );
  }
}
