import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String GOOGLE_MAPS_API_KEY = 'AIzaSyDRvIZbdBfQDK5bKEYRrNZUiaqDLPYJXBA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Google Maps Api Key ${GOOGLE_MAPS_API_KEY}'),
        ],
      ),
    );
  }
}
