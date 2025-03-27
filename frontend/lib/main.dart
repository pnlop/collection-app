// lib/main.dart
import 'package:card_collection_app/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../services/api_service.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light grey
        // Make cards and other surfaces a softer white
        cardColor: const Color(0xFFFAFAFA),
        // Update the app bar color to match the theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          elevation: 2,
        ),
        searchBarTheme: SearchBarThemeData(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
          elevation: WidgetStateProperty.all<double>(2.0),
          overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
          shadowColor: WidgetStateProperty.all<Color>(Colors.grey.shade300),
          surfaceTintColor: WidgetStateProperty.all<Color>(Colors.transparent),
          // Add styling for the text field within the search bar
          textStyle: WidgetStateProperty.all<TextStyle>(
            const TextStyle(color: Colors.black87, fontSize: 16),
          ),
          hintStyle: WidgetStateProperty.all<TextStyle>(
            TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ),
        // Make all backgrounds use the light grey color
        canvasColor: const Color(0xFFF5F5F5),
        // Set a consistent color scheme
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          backgroundColor: const Color(0xFFF5F5F5),
          brightness: Brightness.light,
        ), dialogTheme: const DialogThemeData(backgroundColor: Color(0xFFF5F5F5)),
      ),
      home: HomeScreen(apiService: apiService),
    );
  }
}