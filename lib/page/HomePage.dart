import 'package:do_an_da_nganh/page/Dashboard.dart';
import 'package:do_an_da_nganh/page/LoginPage.dart';
import 'package:do_an_da_nganh/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  //static const String routeName = '/';
  const HomePage() : super();
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              // Go to dashboard if user has loggedin
              return Dashboard();
            } else {
              // Go to Login if user has not loggedin
              return LoginPage();
            }
          }
          return MySplashScreen();
        },
      ),
    );
  }
}
