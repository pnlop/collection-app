// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';

void main() {
  final apiService = ApiService(baseUrl: 'http://localhost:3000');
  runApp(CardCollectionApp(apiService: apiService));
}

class CardCollectionApp extends StatelessWidget {
  final ApiService apiService;
  
  const CardCollectionApp({Key? key, required this.apiService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Collection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(apiService: apiService),
    );
  }
}