import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearchButtonPressed;

  const MyAppBar({super.key, required this.onSearchButtonPressed});

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      centerTitle: true,
      scrolledUnderElevation: 0,
      elevation: 0,
      title: Text(
        "StudFooD",
        style: TextStyle(
            fontFamily: GoogleFonts.kirangHaerang().fontFamily, fontSize: 35),
      ),
      actions: [
        IconButton(
          onPressed: onSearchButtonPressed,
          icon: const Icon(Icons.search),
        ),
        cityPickerButton(context),
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
        Icon(Icons.location_city, color: Colors.black),
        Text(
          "Kraków",
          style: TextStyle(color: Colors.black, fontSize: 15),
        )
      ]),
    );
  }
}
