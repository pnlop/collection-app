import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/card_model.dart';
import '../models/collection_model.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<CollectionModel>> getCollections() async {
    final response = await http.get(Uri.parse('$baseUrl/api/collections'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CollectionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load collections');
    }
  }

  Future<CollectionModel> getCollection(String collectionName) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/collections/$collectionName')
    );

    if (response.statusCode == 200) {
      return CollectionModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load collection');
    }
  }

  Future<List<CardModel>> searchCards(String query, {String? collectionName}) async {
    final url = '$baseUrl/api/searchCard';

    final Map<String, dynamic> requestBody = {
      'query': query,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CardModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search cards');
    }
  }

  Future<List<CardModel>> searchCollectionCards(String collectionName, Map<String, dynamic> searchCriteria) async {
    final url = '$baseUrl/api/collections/$collectionName/search';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(searchCriteria),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CardModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search cards in collection: $collectionName');
    }
  }

  Future<CardModel> addCard(String collectionName, CardModel card) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/collections/$collectionName/cards'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(card.toJson()),
    );

    if (response.statusCode == 201) {
      return CardModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add card');
    }
  }

  Future<CardModel> updateCard(String collectionName, CardModel card) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/collections/$collectionName/cards/${card.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(card.toJson()),
    );

    if (response.statusCode == 200) {
      return CardModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update card');
    }
  }

  Future<void> deleteCard(String collectionName, String cardId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/collections/$collectionName/cards/$cardId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete card');
    }
  }
}
