// lib/models/card_model.dart
class CardModel {
  final String name;
  final String title;
  final String description;
  final Map<String, dynamic> attributes;
  final String defaultImage;

  CardModel({
    required this.name,
    required this.title,
    required this.description,
    required this.attributes, 
    required this.defaultImage,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      attributes: Map<String, dynamic>.from(json['attributes'] ?? {}),
      defaultImage: json['defaultImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
      'description': description,
      'attributes': attributes,
      'defaultImage': defaultImage,
    };
  }
}
