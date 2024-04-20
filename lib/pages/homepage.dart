import 'package:flutter/material.dart';
import 'package:studfood/components/main_appbar.dart';
import 'package:studfood/components/my_drawer.dart';
import 'package:studfood/components/custom_list_tile.dart';

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
