import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:do_an_da_nganh/config.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Iot smart building".toUpperCase(),
      theme: THEME,
      home: Scaffold(body: Text('Hello World')),
    );
  }
}
