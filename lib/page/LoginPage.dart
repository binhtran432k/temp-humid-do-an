import 'dart:ui';

import 'package:do_an_da_nganh/api/FirebaseApi.dart';
import 'package:do_an_da_nganh/config.dart';
import 'package:do_an_da_nganh/page/RegisterPage.dart';
import 'package:flutter/material.dart';
import 'package:do_an_da_nganh/utils/utils.dart';

class LoginPage extends StatefulWidget {
  //static const String routeName = '/login';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    _loginUser().then((success) {
      if (success) {
        String description = "Đăng nhập thành công!";
        Color color = Colors.greenAccent;
        ScaffoldMessenger.of(context).showSnackBar(
            snackbarDialog(content: Text(description), color: color));
      } else {
        String description =
            "Đăng nhập thất bại!\nTài khoản hoặc mật khẩu không tồn tại.";
        Color color = Colors.redAccent;
        ScaffoldMessenger.of(context).showSnackBar(
            snackbarDialog(content: Text(description), color: color));
      }
    });
  }

  Future<bool> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String email = _emailController.text;
      String password = _passwordController.text;
      return await FirebaseApi.login(email, password);
    }
    return false;
  }

  Widget _homeSliverAppBar() {
    return SliverAppBar(
      toolbarHeight: 400,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            repeat: ImageRepeat.repeatX,
            scale: 1.4,
            image: AssetImage('images/login_background.jpg'),
            fit: BoxFit.none,
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00F0A073), Color(0xffCC7154)],
                ),
              ),
            ),
          ),
        ),
      ),
      title: SizedBox(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Iot smart building".toUpperCase(),
              maxLines: 2,
              softWrap: true,
              style: TextStyle(color: Color(0xffE5E5E5), fontSize: 40),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: MyScrollView(
        slivers: <Widget>[
          _homeSliverAppBar(),
          MySliverBody(
            child: MyForm(
              key: _formKey,
              children: <Widget>[
                SizedBox(height: 40),
                MyTextFormField(
                  validator: (input) {
                    if (input!.isEmpty) {
                      return 'Vui lòng nhập e-mail';
                    } else if (!isValidMail(input)) {
                      return 'E-mail không hợp lệ';
                    }
                  },
                  labelText: 'Email',
                  suffixIcon: Icon(Icons.email_rounded),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                MyTextFormField(
                  validator: (input) {
                    if (input!.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                  },
                  labelText: 'Mật Khẩu',
                  suffixIcon: Icon(Icons.lock_rounded),
                  controller: _passwordController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submitLogin(),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                MyButton(
                  child: MyButton.defaultText('Đăng nhập'.toUpperCase()),
                  onPressed: _submitLogin,
                ),
                SizedBox(height: 10),
                Text('Bạn chưa có tài khoản?'),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => RegisterPage(),
                    ));
                  },
                  child: Text(
                    'Tạo Tài Khoản',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: PRIMARY_COLOR,
                      decoration: TextDecoration.underline,
                      fontSize: 18,
                    ),
                  ),
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
