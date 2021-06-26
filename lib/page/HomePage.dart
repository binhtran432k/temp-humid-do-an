import 'package:do_an_da_nganh/page/Dashboard.dart';
import 'package:do_an_da_nganh/page/LoginPage.dart';
import 'package:do_an_da_nganh/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  //static const String routeName = '/';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
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
