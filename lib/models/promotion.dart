class Promotion {
  final String id;
  final String title;
  final String description;
  final String image;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
    );
  }
}