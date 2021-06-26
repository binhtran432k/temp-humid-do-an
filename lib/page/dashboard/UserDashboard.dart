import 'package:do_an_da_nganh/api/FirebaseApi.dart';
import 'package:do_an_da_nganh/config.dart';
import 'package:do_an_da_nganh/page/dashboard/user/DeviceLogViewer.dart';
import 'package:do_an_da_nganh/page/dashboard/user/DeviceController.dart';
import 'package:do_an_da_nganh/page/dashboard/user/LogDateSelection.dart';
import 'package:do_an_da_nganh/page/dashboard/user/InformationUpdation.dart';
import 'package:do_an_da_nganh/utils/utils.dart';
import 'package:flutter/material.dart';

class UserDashboard extends StatelessWidget {
  UserDashboard();

  Future<void> _logout() async {
    FirebaseApi.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40),
        MyButton(
          child: MyButton.defaultText('Chỉnh sửa thông tin cá nhân'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => InformationUpdation(),
              ),
            );
          },
        ),
        MyButton(
          child: MyButton.defaultText('Điều khiển thiết bị phòng'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeviceController(),
              ),
            );
          },
        ),
        MyButton(
          child: MyButton.defaultText('Xem hoạt động thiết bị'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    LogDateSelection((DateTime fromTime, DateTime toTime) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeviceLogViewer(fromTime, toTime),
                    ),
                  );
                }),
              ),
            );
          },
        ),
        SizedBox(height: 80),
        TextButton(
          child: Column(
            children: [
              Icon(
                Icons.logout,
                size: 40,
                color: PRIMARY_COLOR,
              ),
              Text(
                'Đăng Xuất',
                style: TextStyle(color: PRIMARY_COLOR),
              )
            ],
          ),
          onPressed: _logout,
        ),
        SizedBox(height: 40),
      ],
    );
  }
}
