import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  const Bubble({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FilterChip(
        onSelected: (_) {},
        avatar: const CircleAvatar(
          child: Icon(Icons.fastfood),
        ),
        label: const Text('Burgery'),
      ),
    );
  }
}
