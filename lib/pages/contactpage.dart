import 'package:flutter/material.dart';
import 'package:studfood/components/custom_appbar.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: "Kontakt"),
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Text(
                      "Thank you for using our application! If you have any questions, feedback, or suggestions, please don't hesitate to reach out. Your input is invaluable to us as we strive to improve our services and provide the best experience possible.Feel free to contact me via email, and I will get back to you as soon as possible.Thank you for your support!"),
                  Text("Piotr Karaś"),
                  Text("Email: elexxx214@interia.pl")
                ],
              )),
        ],
      ),
    );
  }
}
