import 'package:flutter/material.dart';

import 'package:studfood/components/mainappbar.dart';
import 'package:studfood/components/mydrawer.dart';
import 'package:studfood/components/customlisttile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const MyAppBar(),
        drawer: const MyDrawer(),
        body: ListView(
          children: const [
            CustomListTile(),
            CustomListTile(),
            CustomListTile(),
            CustomListTile(),
            CustomListTile(),
            CustomListTile(),
            CustomListTile(),
            CustomListTile(),
            CustomListTile(),
            CustomListTile(),
          ],
        ));
  }
}
