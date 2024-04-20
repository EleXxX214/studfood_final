import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[850],
      centerTitle: true,
      title: const Text("StudFooD"),
      actions: [
        Row(
          children: [
            cityPickerButton(context),
          ],
        ),
      ],
    );
  }

  TextButton cityPickerButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Zamknij"),
              ),
            ],
            title: const Text("Wybierz miasto:"),
            content: const Text("[] Kraków"),
          ),
        );
      },
      child: const Row(children: [
        Icon(Icons.location_city, color: Colors.white),
        Text(
          "Kraków",
          style: TextStyle(color: Colors.white, fontSize: 15),
        )
      ]),
    );
  }
}
