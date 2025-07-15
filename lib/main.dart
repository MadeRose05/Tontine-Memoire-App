import 'package:flutter/material.dart';
import 'package:tontine_memoire_app/presentation/screens/auth/phone_login.dart';
import 'presentation/screens/home.dart';


void main() {
  runApp(const TontineApp());
}

class TontineApp extends StatelessWidget {
  const TontineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tontine OMG',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PhoneLogin(),
      routes: {
        '/home': (context) => Home(),
        '/login': (context) => PhoneLogin(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}