// lib/screens/edit_card_screen.dart
import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../services/api_service.dart';

class EditCardScreen extends StatefulWidget {
  final ApiService apiService;
  final String collectionName;
  final CardModel? card; // Null for new cards
  
  const EditCardScreen({
    Key? key,
    required this.apiService,
    required this.collectionName,
    this.card,
  }) : super(key: key);

  @override
  _EditCardScreenState createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Map<String, TextEditingController> _attributeControllers = {};
  final List<String> _attributeKeys = [];
  
  bool get _isEditing => widget.card != null;
  
  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.card!.title;
      _descriptionController.text = widget.card!.description;
      
      widget.card!.attributes.forEach((key, value) {
        _attributeKeys.add(key);
        _attributeControllers[key] = TextEditingController(text: value.toString());
      });
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _attributeControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
  
  void _addAttribute() {
    setState(() {
      final newKey = 'attribute${_attributeKeys.length + 1}';
      _attributeKeys.add(newKey);
      _attributeControllers[newKey] = TextEditingController();
    });
  }
  
  void _removeAttribute(int index) {
    setState(() {
      final key = _attributeKeys[index];
      _attributeControllers[key]?.dispose();
      _attributeControllers.remove(key);
      _attributeKeys.removeAt(index);
    });
  }
  
  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      // Collect attributes from the controllers
      final attributes = <String, dynamic>{};
      for (final key in _attributeKeys) {
        if (_attributeControllers[key]!.text.isNotEmpty) {
          attributes[key] = _attributeControllers[key]!.text;
        }
      }
      
      CardModel cardData = CardModel(
        name: _isEditing ? widget.card!.name : '', // ID will be assigned by backend for new cards
        title: _titleController.text,
        description: _descriptionController.text,
        attributes: attributes,
        defaultImage: widget.card?.defaultImage ?? '', // Use existing image if editing
      );
      
      CardModel savedCard;
      if (_isEditing) {
        savedCard = await widget.apiService.updateCard(
          widget.collectionName, 
          cardData
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card updated successfully'))
        );
      } else {
        savedCard = await widget.apiService.addCard(
          widget.collectionName, 
          cardData
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card added successfully'))
        );
      }
      
      Navigator.pop(context, _isEditing ? savedCard : true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving card: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Card' : 'Add Card'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attributes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addAttribute,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._attributeKeys.asMap().entries.map((entry) {
              final index = entry.key;
              final attributeKey = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: attributeKey,
                        decoration: InputDecoration(
                          labelText: 'Key ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && value != attributeKey) {
                            final oldController = _attributeControllers[attributeKey];
                            setState(() {
                              _attributeControllers[value] = oldController!;
                              _attributeControllers.remove(attributeKey);
                              _attributeKeys[index] = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _attributeControllers[attributeKey],
                        decoration: InputDecoration(
                          labelText: 'Value ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeAttribute(index),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: _saveCard,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(_isEditing ? 'Update Card' : 'Add Card'),
            ),
          ),
        ),
      ),
    );
  }
}