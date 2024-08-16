import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final ValueChanged<String> onSearchChanged;

  const CustomSearchBar({
    super.key,
    required this.searchController,
    required this.searchFocus,
    required this.onSearchChanged,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: widget.searchController,
        focusNode: widget.searchFocus,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Wyszukaj restauracje...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              widget.searchController.clear();
              setState(() {
                widget.onSearchChanged("");
              });
            },
          ),
        ),
        onChanged: (value) {
          widget.onSearchChanged(value.toLowerCase());
        },
      ),
    );
  }
}
