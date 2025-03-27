// lib/models/collection_model.dart
import 'card_model.dart';

class CollectionModel {
  final String name;
  final List<CardModel> cards;
  
  CollectionModel({
    required this.name,
    required this.cards,
  });
  
  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    List<CardModel> cardsList = [];
    if (json['cards'] != null) {
      cardsList = (json['cards'] as List)
          .map((card) => CardModel.fromJson(card))
          .toList();
    }
    
    return CollectionModel(
      name: json['name'],
      cards: cardsList,
    );
  }
}