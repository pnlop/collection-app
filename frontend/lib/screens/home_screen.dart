import 'package:flutter/material.dart';
import '../models/collection_model.dart';
import '../models/card_model.dart';
import '../services/api_service.dart';
import '../widgets/search_bar.dart';
import 'collection_screen.dart';

class HomeScreen extends StatefulWidget {
  final ApiService apiService;

  const HomeScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late Future<List<CollectionModel>> _collectionsFuture;
  late TabController _tabController;
  List<CardModel>? _searchResults;
  List<CardModel>? _collectionSearchResults;
  bool _isSearching = false;
  String _collectionSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _collectionsFuture = widget.apiService.getCollections();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Refresh collections list
  Future<void> _refreshCollections() async {
    setState(() {
      _collectionsFuture = widget.apiService.getCollections();
      _collectionSearchResults = null;
      _isSearching = false;
    });
  }

  void _handleCollectionSearch(String query) async {
    setState(() {
      _collectionSearchQuery = query;
    });
    
    if (query.isEmpty) {
      setState(() {
        _collectionSearchResults = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });


    try {
      final results = await widget.apiService.searchCollectionCards(
        query,
        {'collectionName': query, 'collectionFilter': true}
      );

      if (!mounted) return;


      setState(() {
        _collectionSearchResults = results;
        _isSearching = false;
      });

      if (results.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Found ${results.length} cards in collection'))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No matching cards found in collection'))
        );
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching collection: $e'))
      );
    }
  }

  void _handleAllCardsSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await widget.apiService.searchCards(query);

      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      if (results.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Found ${results.length} cards across all collections'))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No matching cards found'))
        );
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching all cards: $e'))
      );
    }
  }

  Widget _buildCardGrid(List<CardModel> cards) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 0.675,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final imageUrl = 'https://prod-content.fabrary.io/cards/${card.defaultImage}.webp';

        return Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, size: 30),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  card.name,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCollectionsList(List<CollectionModel> collections) {
    // Filter collections based on search query if one exists
    final filteredCollections = _collectionSearchQuery.isEmpty 
        ? collections 
        : collections.where((c) => c.name.toLowerCase().contains(_collectionSearchQuery.toLowerCase())).toList();
    
    if (filteredCollections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _collectionSearchQuery.isEmpty 
                  ? 'No collections found' 
                  : 'No collections matching "$_collectionSearchQuery"',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshCollections,
              child: const Text('Refresh'),
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshCollections,
      child: ListView.builder(
        itemCount: filteredCollections.length,
        itemBuilder: (context, index) {
          final collection = filteredCollections[index];
          return ListTile(
            leading: collection.cards.isNotEmpty
              ? Hero(
                  tag: 'collection_${collection.name}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      'https://prod-content.fabrary.io/cards/${collection.cards.first.defaultImage}.webp',
                      width: 40,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 56,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 20),
                        );
                      },
                    ),
                  ),
                )
              : Container(
                  width: 40,
                  height: 56,
                  color: Colors.grey[300],
                  child: const Icon(Icons.folder, size: 20),
                ),
            title: Text(collection.name),
            subtitle: Text('${collection.cards.length} cards'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CollectionScreen(
                    apiService: widget.apiService,
                    collectionName: collection.name,
                  ),
                ),
              ).then((_) => _refreshCollections());
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Card Collections'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.redAccent,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            indicatorWeight: 3.0,
            indicator: const BoxDecoration(
              color: Color.fromARGB(25, 0, 0, 0),
              border: Border(
                bottom: BorderSide(
                  color: Colors.redAccent,
                  width: 3.0,
                ),
              ),
            ),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
              color: Colors.black,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14.0,
              color: Colors.black54,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.folder, color: Colors.black),
                text: 'Collections',
              ),
              Tab(
                icon: Icon(Icons.search, color: Colors.black),
                text: 'All Cards',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomSearchBar(
                    onSearch: _handleCollectionSearch,
                    hintText: 'Search collections by name...',
                  ),
                ),
                Expanded(
                  child: _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _collectionSearchResults != null
                      ? _buildCardGrid(_collectionSearchResults!)
                      : FutureBuilder<List<CollectionModel>>(
                          future: _collectionsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                    const SizedBox(height: 16),
                                    Text('Error: ${snapshot.error}'),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _refreshCollections,
                                      child: const Text('Try Again'),
                                    )
                                  ],
                                ),
                              );
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.folder_off, size: 64, color: Colors.grey),
                                    const SizedBox(height: 16),
                                    const Text('No collections found'),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _refreshCollections,
                                      child: const Text('Refresh'),
                                    )
                                  ],
                                ),
                              );
                            } else {
                              return _buildCollectionsList(snapshot.data!);
                            }
                          },
                        ),
                ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomSearchBar(
                    onSearch: _handleAllCardsSearch,
                    hintText: 'Search all cards...',
                  ),
                ),
                Expanded(
                  child: _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults != null
                      ? _buildCardGrid(_searchResults!)
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'Enter a search term above to find cards across all collections',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Implement adding a collection
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add Collection functionality coming soon!'))
            );
          },
          tooltip: 'Add Collection',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}