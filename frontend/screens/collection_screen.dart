// lib/screens/collection_screen.dart
import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../models/collection_model.dart';
import '../services/api_service.dart';
import '../widgets/card_list_item.dart';
import '../widgets/search_bar.dart';
import 'card_detail_screen.dart';
import 'edit_card_screen.dart';

class CollectionScreen extends StatefulWidget {
  final ApiService apiService;
  final String collectionName;
  
  const CollectionScreen({
    Key? key, 
    required this.apiService, 
    required this.collectionName
  }) : super(key: key);

  @override
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  late Future<CollectionModel> _collectionFuture;
  List<CardModel> _filteredCards = [];
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _refreshCollection();
  }
  
  void _refreshCollection() {
    setState(() {
      _collectionFuture = widget.apiService.getCollection(widget.collectionName);
      _isSearching = false;
    });
  }
  
  void _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      return;
    }
    
    try {
      final results = await widget.apiService.searchCards(
        query, 
        collectionName: widget.collectionName
      );
      setState(() {
        _filteredCards = results;
        _isSearching = true;
      });
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
        title: Text(widget.collectionName),
      ),
      body: Column(
        children: [
          CustomSearchBar(onSearch: _handleSearch),
          Expanded(
            child: _isSearching
                ? _buildCardList(_filteredCards)
                : FutureBuilder<CollectionModel>(
                    future: _collectionFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData) {
                        return const Center(child: Text('Collection not found'));
                      } else {
                        return _buildCardList(snapshot.data!.cards);
                      }
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditCardScreen(
                apiService: widget.apiService,
                collectionName: widget.collectionName,
              ),
            ),
          );
          
          if (result == true) {
            _refreshCollection();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Card',
      ),
    );
  }
  
  Widget _buildCardList(List<CardModel> cards) {
    if (cards.isEmpty) {
      return const Center(child: Text('No cards found'));
    }
    
    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return CardListItem(
          card: card,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CardDetailScreen(
                  apiService: widget.apiService,
                  collectionName: widget.collectionName,
                  card: card,
                ),
              ),
            );
            
            if (result == true) {
              _refreshCollection();
            }
          },
        );
      },
    );
  }
}