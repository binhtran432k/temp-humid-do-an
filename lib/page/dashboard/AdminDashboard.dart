import 'package:do_an_da_nganh/model/UserModel.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends Center {
  AdminDashboard() : super(child: getChild());
  static Text getChild() {
    UserModel userModel = UserModel.instance!;
    return Text('${userModel.role} ${userModel.name}');
  }
}
