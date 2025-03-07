import 'package:flutter/material.dart';
import 'package:flight_search_app/screens/busca_voos.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Busca Passagens',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SearchFlightScreen(), // Tela inicial
    );
  }
}
