import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:string_extensions/string_extensions.dart';

import 'package:studfood/services/firestore.dart';

class FoodFilter extends StatefulWidget {
  const FoodFilter({
    super.key,
    required this.selectedFilters,
    required this.onFilterChanged,
  });

  final List<String> selectedFilters;
  final Function(List<String>) onFilterChanged;

  @override
  State<FoodFilter> createState() => _FoodFilterState();
}

class _FoodFilterState extends State<FoodFilter> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: SizedBox(
        height: 60,
        child: FutureBuilder<QuerySnapshot>(
          future: FirestoreService().getFilters(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final filters = snapshot.data!.docs;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final filter = filters[index].id;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FilterChip(
                      side: BorderSide.none,
                      elevation: 3,
                      //shadowColor: const Color.fromARGB(255, 197, 43, 164),
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      selectedColor: const Color.fromARGB(255, 255, 205, 244),
                      selected: widget.selectedFilters.contains(filter),
                      onSelected: (bool value) {
                        List<String> newFilters =
                            List.from(widget.selectedFilters);
                        if (value) {
                          newFilters.add(filter);
                        } else {
                          newFilters.remove(filter);
                        }
                        widget.onFilterChanged(newFilters);
                      },
                      label: Text(
                        filters[index].id.capitalize,
                        style: const TextStyle(
                            fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
