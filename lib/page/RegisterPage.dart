import 'package:do_an_da_nganh/api/FirebaseApi.dart';
import 'package:do_an_da_nganh/model/RoomModel.dart';
import 'package:do_an_da_nganh/utils/utils.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  //static const String routeName = '/register';

  Future<List<RoomModel>> _loadData() async {
    return await FirebaseApi.getRooms();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RoomModel>>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return RegisterBody(snapshot.data!);
        }
        return MySplashScreen();
      },
    );
  }
}

class RegisterBody extends StatefulWidget {
  final List<RoomModel> roomModels;
  RegisterBody(this.roomModels);

  @override
  _RegisterBodyState createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<RegisterBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  List<String> _sexs = ['Nam', 'Nữ'];
  String? _sex;
  String? _roomId;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submitRegister() async {
    _registerUser().then((errNum) {
      if (errNum == 0) {
        String description = "Tạo tài khoản thành công!";
        Color color = Colors.greenAccent;
        ScaffoldMessenger.of(context).showSnackBar(
            snackbarDialog(content: Text(description), color: color));
        Navigator.of(context).pop();
      } else if (errNum == 1) {
        String description =
            "Tạo tài khoản thất bại!\nTài khoản này đã tồn tại.";
        Color color = Colors.redAccent;
        ScaffoldMessenger.of(context).showSnackBar(
            snackbarDialog(content: Text(description), color: color));
      }
    });
  }

  Future<int> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        String name = _nameController.text;
        String email = _emailController.text;
        String password = _passwordController.text;

        return await FirebaseApi.register(
                email, password, name, 'user', _roomId!, _sex!)
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: MyScrollView(
        slivers: <Widget>[
          MySliverAppBar(
            title: MySliverAppBar.defaultTitle('Tạo tài khoản'),
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
                    if (input!.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                  },
                  labelText: 'Mật khẩu',
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
                  labelText: 'Xác nhận mật khẩu',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 20),
                MyButton(
                  child: MyButton.defaultText('Tạo tài khoản'.toUpperCase()),
                  onPressed: _submitRegister,
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
