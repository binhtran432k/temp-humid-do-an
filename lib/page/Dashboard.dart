import 'package:do_an_da_nganh/api/FirebaseApi.dart';
import 'package:do_an_da_nganh/model/UserModel.dart';
import 'package:do_an_da_nganh/page/dashboard/AdminDashboard.dart';
import 'package:do_an_da_nganh/page/dashboard/UserDashboard.dart';
import 'package:do_an_da_nganh/utils/utils.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  //static const String routeName = '/dashboard';

  Widget _checkRole(UserModel userModel) {
    if (userModel.role == 'admin') {
      return AdminDashboard(userModel);
    } else {
      return UserDashboard(userModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: FirebaseApi.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            body: MyScrollView(
              slivers: [
                MySliverAppBar(
                  title: MySliverAppBar.defaultTitle(
                      'Xin chào, ' + snapshot.data!.name),
                  automaticallyImplyLeading: false,
                ),
                MySliverBody(
                  child: _checkRole(snapshot.data!),
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
