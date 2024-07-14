import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  const Bubble({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: const Padding(
          padding: EdgeInsets.only(top: 5.0),
          child: Column(
            children: [
              Icon(Icons.map),
              Text("Burgery"),
            ],
          ),
        ),
      ),
    );
  }
}
