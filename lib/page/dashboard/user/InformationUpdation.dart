import 'package:do_an_da_nganh/api/FirebaseApi.dart';
import 'package:do_an_da_nganh/model/RoomModel.dart';
import 'package:do_an_da_nganh/model/UserModel.dart';
import 'package:do_an_da_nganh/utils/utils.dart';
import 'package:flutter/material.dart';

class InformationUpdation extends StatelessWidget {
  //static const String routeName = '/register';
  final UserModel userModel;

  InformationUpdation(this.userModel);

  Future<List<RoomModel>> _loadData() async {
    return await FirebaseApi.getRooms();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RoomModel>>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return UpdateInformationBody(snapshot.data!, userModel);
        }
        return MySplashScreen();
      },
    );
  }
}

class UpdateInformationBody extends StatefulWidget {
  final List<RoomModel> roomModels;
  final UserModel userModel;
  UpdateInformationBody(this.roomModels, this.userModel);

  @override
  _UpdateInformationBodyState createState() => _UpdateInformationBodyState();
}

class _UpdateInformationBodyState extends State<UpdateInformationBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  List<String> _sexs = ['Nam', 'Nữ'];
  String? _sex;
  String? _roomId;
  late bool _isWaiting;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.userModel.email;
    _nameController.text = widget.userModel.name;
    _sex = widget.userModel.sex;
    _roomId = widget.userModel.roomId;
    _isWaiting = false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    setState(() {
      _isWaiting = true;
      _updateUser().then((errNum) {
        if (errNum == 0) {
          String description = "Chỉnh sửa tài khoản thành công!";
          Color color = Colors.greenAccent;
          ScaffoldMessenger.of(context).showSnackBar(
              snackbarDialog(content: Text(description), color: color));
          Navigator.of(context).pop();
        } else if (errNum == 1) {
          String description = "Chỉnh sửa tài khoản thất bại!" +
              "\nHãy thử đăng xuất và chỉnh sửa lại.";
          Color color = Colors.redAccent;
          ScaffoldMessenger.of(context).showSnackBar(
              snackbarDialog(content: Text(description), color: color));
        }
      });
    });
  }

  Future<int> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        String? email;
        String? password;
        String? roomId;
        String? sex;
        String name = _nameController.text;
        if (_emailController.text != widget.userModel.email) {
          email = _emailController.text;
        }
        if (_passwordController.text != '') {
          password = _passwordController.text;
        }
        if (_roomId != widget.userModel.roomId) {
          roomId = _roomId;
        }
        if (_sex != widget.userModel.sex) {
          sex = _sex;
        }
        return await FirebaseApi.updateUser(
                email, password, name, null, roomId, sex)
            ? 0
            : 1;
      } catch (e) {
        print(e.toString());
      }
    }
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    if (_isWaiting) {
      return MySplashScreen();
    } else {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: MyScrollView(
          slivers: <Widget>[
            MySliverAppBar(
              title: MySliverAppBar.defaultTitle('Chỉnh sửa thông tin'),
              leading: MySliverAppBar.defaultLedding(context),
            ),
            MySliverBody(
              child: MyForm(
                key: _formKey,
                children: <Widget>[
                  SizedBox(height: 40),
                  MyTextFormField(
                    validator: (input) {
                      if (input!.isEmpty) {
                        return 'Vui lòng nhập họ tên';
                      }
                    },
                    labelText: 'Họ tên',
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                  ),
                  MyDropdown(
                    validator: (value) {
                      if (value == null) {
                        return "Vui lòng chọn phòng ban";
                      }
                    },
                    value: _roomId,
                    items: widget.roomModels
                        .map<DropdownMenuItem<String>>((RoomModel roomModel) {
                      return DropdownMenuItem<String>(
                        value: roomModel.id,
                        child: Text(roomModel.name),
                      );
                    }).toList(),
                    labelText: "Phòng Ban",
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _roomId = newValue;
                        });
                      }
                    },
                  ),
                  MyDropdown(
                    validator: (value) {
                      if (value == null) {
                        return "Vui lòng chọn giới tính";
                      }
                    },
                    value: _sex,
                    items: _sexs.map<DropdownMenuItem<String>>((String sex) {
                      return DropdownMenuItem<String>(
                        value: sex,
                        child: Text(sex),
                      );
                    }).toList(),
                    labelText: "Giới Tính",
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _sex = newValue;
                        });
                      }
                    },
                  ),
                  MyTextFormField(
                    validator: (input) {
                      if (input!.isEmpty) {
                        return 'Vui lòng nhập e-mail';
                      } else if (!isValidMail(input)) {
                        return 'E-mail không hợp lệ';
                      }
                    },
                    labelText: 'E-mail',
                    controller: _emailController,
                    textInputAction: TextInputAction.next,
                  ),
                  MyTextFormField(
                    validator: (input) {
                      if (input!.length > 0 && input.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                    },
                    labelText: 'Mật khẩu mới',
                    obscureText: true,
                    controller: _passwordController,
                    textInputAction: TextInputAction.next,
                  ),
                  MyTextFormField(
                    validator: (input) {
                      if (input! != _passwordController.text) {
                        return 'Mật khẩu không trùng khớp';
                      }
                    },
                    labelText: 'Xác nhận mật khẩu mới',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 20),
                  MyButton(
                    child: Text(
                      'Cập nhật'.toUpperCase(),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: _submitUpdate,
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
