import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String hintText;

  const CustomSearchBar({
    Key? key,
    required this.onSearch,
    this.hintText = 'Search...'
  }) : super(key: key);

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SearchBar(
      controller: _controller,
        hintText: widget.hintText,
        hintStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(color: Colors.grey),
          ),
        backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
        elevation: WidgetStateProperty.all<double>(1.0),
        padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        leading: const Icon(Icons.search, color: Colors.grey),
        trailing: [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _controller.clear();
              widget.onSearch(''); // Optionally notify that search has been cleared
            },
          ),
        ],
      onSubmitted: widget.onSearch,
        // Shape for the search bar
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}