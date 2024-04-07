import 'package:flutter/material.dart';

import 'package:studfood/components/myappbar.dart';
import 'package:studfood/components/mydrawer.dart';

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
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[350]?.withOpacity(0.1),
                ),
                child: const Stack(children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Filthy", style: TextStyle(fontSize: 20)),
                          SizedBox(height: 31),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined),
                              Text("Ul.Węgłowa 10")
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [Text("data")],
                      )
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ));
  }
}
