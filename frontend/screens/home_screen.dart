// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/collection_model.dart';
import '../services/api_service.dart';
import '../widgets/search_bar.dart';
import 'collection_screen.dart';

class HomeScreen extends StatefulWidget {
  final ApiService apiService;
  
  const HomeScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<CollectionModel>> _collectionsFuture;
  
  @override
  void initState() {
    super.initState();
    _collectionsFuture = widget.apiService.getCollections();
  }
  
  void _handleSearch(String query) async {
    if (query.isEmpty) return;
    
    try {
      final results = await widget.apiService.searchCards(query);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Found ${results.length} cards'))
      );
      // You could navigate to a search results screen here
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Collections'),
      ),
      body: Column(
        children: [
          CustomSearchBar(onSearch: _handleSearch),
          Expanded(
            child: FutureBuilder<List<CollectionModel>>(
              future: _collectionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No collections found'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final collection = snapshot.data![index];
                      return ListTile(
                        title: Text(collection.name),
                        subtitle: Text('${collection.cards.length} cards'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CollectionScreen(
                                apiService: widget.apiService,
                                collectionName: collection.name,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add functionality to create a new collection
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Collection',
      ),
    );
  }
}