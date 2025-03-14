// lib/models/card_model.dart
class CardModel {
  final String id;
  final String title;
  final String description;
  final Map<String, dynamic> attributes;

  CardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.attributes,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      attributes: Map<String, dynamic>.from(json['attributes'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'attributes': attributes,
    };
  }
}
