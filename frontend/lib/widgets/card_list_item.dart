// lib/widgets/card_list_item.dart
import 'package:flutter/material.dart';
import '../../models/card_model.dart';

class CardListItem extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;
  
  const CardListItem({
    Key? key,
    required this.card,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(card.title),
        subtitle: Text(
          card.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text('${card.attributes.length} attributes'),
        onTap: onTap,
      ),
    );
  }
}