// lib/screens/card_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../services/api_service.dart';
import 'edit_card_screen.dart';

class CardDetailScreen extends StatefulWidget {
  final ApiService apiService;
  final String collectionName;
  final CardModel card;

  const CardDetailScreen({
    Key? key,
    required this.apiService,
    required this.collectionName,
    required this.card,
  }) : super(key: key);

  @override
  _CardDetailScreenState createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  late CardModel _card;

  @override
  void initState() {
    super.initState();
    _card = widget.card;
  }

  Future<void> _deleteCard() async {
    try {
      await widget.apiService.deleteCard(widget.collectionName, _card.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card deleted successfully'))
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting card: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_card.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCardScreen(
                    apiService: widget.apiService,
                    collectionName: widget.collectionName,
                    card: _card,
                  ),
                ),
              );

              if (result is CardModel) {
                setState(() {
                  _card = result;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Card'),
                  content: const Text('Are you sure you want to delete this card?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteCard();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _card.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              _card.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            const Text(
              'Attributes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._card.attributes.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key}:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(entry.value.toString()),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
