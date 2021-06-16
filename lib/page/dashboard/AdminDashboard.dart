import 'package:do_an_da_nganh/model/UserModel.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends Center {
  final UserModel userModel;
  AdminDashboard(this.userModel) : super(child: getChild(userModel));
  static Text getChild(UserModel userModel) {
    return Text('${userModel.role} ${userModel.name}');
  }
}
