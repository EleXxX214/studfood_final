import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        //const DrawerHeader(
        //child: Text("StudFood"),
        //),
        ListTile(
          title: const Text("Strona główna"),
          onTap: () {},
        ),
        ListTile(
          title: const Text("Dodaj restauracje"),
          onTap: () {},
        ),
        ListTile(
          title: const Text("Kontakt"),
          onTap: () {},
        ),
      ],
    ));
  }
}
