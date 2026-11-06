
class Kategory {
  final int id;
  final String name;
  final String description;
  final String image;

  Kategory({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  factory Kategory.fromJson(Map<String, dynamic> json) {
    return Kategory(
      id: int.tryParse('${json['id']}') ?? 0,
      name: '${json['name'] ?? ''}',
      description: '${json['description'] ?? ''}',
      image: '${json['image'] ?? ''}',
    );
  }
}
