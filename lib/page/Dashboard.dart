import 'package:do_an_da_nganh/api/FirebaseApi.dart';
import 'package:do_an_da_nganh/model/UserModel.dart';
import 'package:do_an_da_nganh/page/dashboard/AdminDashboard.dart';
import 'package:do_an_da_nganh/page/dashboard/UserDashboard.dart';
import 'package:do_an_da_nganh/utils/utils.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  //static const String routeName = '/dashboard';
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Widget _checkRole() {
    UserModel userModel = UserModel.instance!;
    if (userModel.role == 'admin') {
      return AdminDashboard();
    } else {
      return UserDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: FirebaseApi.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          UserModel.instance = snapshot.data;
          UserModel.callback = setState;
          return Scaffold(
            body: MyScrollView(
              slivers: [
                MySliverAppBar(
                  title: MySliverAppBar.defaultTitle(
                      'Xin chào, ' + snapshot.data!.name),
                  automaticallyImplyLeading: false,
                ),
                MySliverBody(
                  child: _checkRole(),
                ),
              ],
            ),
          );
        }
        return MySplashScreen();
      },
    );
  }
}
