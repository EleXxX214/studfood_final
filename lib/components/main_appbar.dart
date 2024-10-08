import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();

    var weekday = today.weekday;

    List<String> weekdays = [
      'Poniedziałek',
      'Wtorek',
      'Środa',
      'Czwartek',
      'Piątek',
      'Sobota',
      'Niedziela'
    ];

    return AppBar(
      backgroundColor: const Color.fromRGBO(245, 235, 223, 1),
      centerTitle: true,
      scrolledUnderElevation: 0,
      elevation: 0,
      title: const Text("StudFooD"),
      actions: [
        Row(
          children: [
            Text(weekdays[weekday - 1]),
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
        Icon(Icons.location_city, color: Colors.black),
        Text(
          "Kraków",
          style: TextStyle(color: Colors.black, fontSize: 15),
        )
      ]),
    );
  }
}
