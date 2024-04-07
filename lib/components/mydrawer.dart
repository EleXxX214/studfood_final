import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        width: 200,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            //const DrawerHeader(
            //child: Text("StudFood"),
            //),
            ListTile(
              title: const Text("Strona główna"),
              onTap: () {
                Navigator.pushNamed(context, 'HomePage');
              },
            ),
            ListTile(
              title: const Text("Zgłoś restauracje"),
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
