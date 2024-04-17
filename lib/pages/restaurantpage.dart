import 'package:flutter/material.dart';
import 'package:studfood/components/customappbar.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({super.key});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

String imageUrl =
    'https://scontent-waw2-2.xx.fbcdn.net/v/t39.30808-6/378376023_333530192517570_843982702981722404_n.png?_nc_cat=106&ccb=1-7&_nc_sid=5f2048&_nc_ohc=qk59q76EPbEAb6l0z3f&_nc_ht=scontent-waw2-2.xx&oh=00_AfABRnkMJtD2W1ijpL2rh9GUlcNpX4-xVdv6oSYmyCSVGQ&oe=6625F7D9';

class _RestaurantPageState extends State<RestaurantPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          // --------------------
          //        Title
          const Row(
            children: [
              Spacer(),
              Text("Filthy", style: TextStyle(fontSize: 30)),
              Spacer(),
            ],
          ),
          // --------------------
          //       Divider
          const Divider(
            indent: 30,
            endIndent: 30,
            color: Colors.white,
          ),
          // --------------------
          //       Image
          SizedBox(
            width: 450,
            height: 200,
            child: Image.network(imageUrl),
          ),
          // --------------------
          //       Buttons
          Row(children: [
            const Spacer(),
            //----------
            //Heart
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border),
              iconSize: 80,
              color: Colors.white,
            ),
            //----------
            const Spacer(),
            //----------
            //Menu
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu_book),
              iconSize: 80,
              color: Colors.white,
            ),
            //----------
            const Spacer(),
            //----------
            //Navigation
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.near_me),
              iconSize: 80,
              color: Colors.white,
            ),
            //----------
            const Spacer(),
          ])
        ],
      ),
    );
  }
}
