import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, "RestaurantPage");
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[350]?.withOpacity(0.1),
          ),
          child: const Stack(children: [
            Positioned(
              top: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_pizza, size: 30),
                      Icon(Icons.ramen_dining, size: 30),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [Icon(Icons.access_time), Text("8:00 - 20:00")],
                  ),
                  Row(
                    children: [Icon(Icons.navigation_rounded), Text("300m")],
                  )
                ],
              ),
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(" "),
                        Text("Ministerstwo śledzia i wódki",
                            style: TextStyle(fontSize: 23)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded),
                        Text("5"),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined),
                        Text("Ul.Węgłowa 10")
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
