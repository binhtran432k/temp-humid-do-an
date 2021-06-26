import 'package:flutter/material.dart';
import 'package:do_an_da_nganh/config.dart';

MaterialColor customMaterialColor(int hexColor) {
  int validHex(int hex, int extra) {
    if ((hex % 0xff000000) + extra > 0xffffff)
      return 0xffffff;
    else if ((hex % 0xff000000) + extra < 0x000000) return 0xff000000;
    return hex + extra;
  }

  return MaterialColor(
    hexColor,
    <int, Color>{
      50: Color(validHex(hexColor, 450)),
      100: Color(validHex(hexColor, 400)),
      200: Color(validHex(hexColor, 300)),
      300: Color(validHex(hexColor, 200)),
      400: Color(validHex(hexColor, 100)),
      500: Color(hexColor),
      600: Color(validHex(hexColor, -100)),
      700: Color(validHex(hexColor, -200)),
      800: Color(validHex(hexColor, -300)),
      900: Color(validHex(hexColor, -400)),
    },
  );
}

dynamic alertWidget(final String title, final String description) {
  Widget alert(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    );
  }

  return alert;
}

SnackBar snackbarDialog({required Widget content, Color? color}) {
  return SnackBar(
    backgroundColor: color,
    content: content,
    action: SnackBarAction(
      label: 'OK',
      onPressed: () => null,
    ),
  );
}

bool isValidMail(String mail) {
  final RegExp mailCheck = RegExp(
    r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)' +
        r'|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' +
        r'\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)' +
        r'+[a-zA-Z]{2,}))$',
    caseSensitive: false,
  );
  return mailCheck.hasMatch(mail);
}

class MyScrollView extends Container {
  MyScrollView({
    List<Widget> slivers = const <Widget>[],
  }) : super(
          decoration: BACKGROUND_DECORATION,
          child: CustomScrollView(
            slivers: slivers,
          ),
        );
}

class MySliverAppBar extends SliverAppBar {
  MySliverAppBar({
    Widget? leading,
    Widget? title,
    bool automaticallyImplyLeading = true,
  }) : super(
          automaticallyImplyLeading: automaticallyImplyLeading,
          toolbarHeight: 160,
          flexibleSpace: Container(
            margin: EdgeInsets.fromLTRB(60, 0, 60, 0),
            child: title,
          ),
          leading: leading,
          backgroundColor: Colors.transparent,
        );

  static Widget defaultTitle(String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 3,
          softWrap: true,
          style: TextStyle(
            color: Color(0xffE5E5E5),
            fontSize: 36,
          ),
        ),
      ],
    );
  }

  static Widget defaultLedding(BuildContext context) {
    return IconButton(
      iconSize: 40,
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}

class MySliverBody extends SliverFillRemaining {
  MySliverBody({bool hasScrollBody = false, Widget? child})
      : super(
          hasScrollBody: hasScrollBody,
          child: Center(
            child: Container(
              margin: EdgeInsets.all(20),
              constraints: BoxConstraints(
                minWidth: 320,
                maxWidth: 480,
              ),
              child: child,
            ),
          ),
        );
}

class MyForm extends Form {
  MyForm({
    Key? key,
    List<Widget> children = const <Widget>[],
  }) : super(
          key: key,
          child: Column(
            children: children,
          ),
        );
}

class MyDropdown extends Padding {
  MyDropdown({
    EdgeInsetsGeometry padding = DEFAULT_PADDING,
    String? Function(String?)? validator,
    String? value,
    required List<DropdownMenuItem<String>>? items,
    String? labelText,
    void Function(String?)? onChanged,
  }) : super(
          padding: padding,
          child: DropdownButtonHideUnderline(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xffFDA43C),
                    Color(0xffFFFFFF),
                  ],
                ),
              ),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                validator: validator,
                value: value,
                items: items,
                onChanged: onChanged,
                decoration: InputDecoration(
                  labelText: labelText,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorStyle: TextStyle(
                    //backgroundColor: Colors.orange[50],
                    color: Color(0xff8b0000),
                  ),
                  labelStyle: TextStyle(color: Colors.black),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 28, vertical: 4),
                ),
                iconEnabledColor: Colors.black,
                dropdownColor: PRIMARY_COLOR,
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ),
        );
}

class MyTextFormField extends Padding {
  MyTextFormField({
    EdgeInsetsGeometry padding = DEFAULT_PADDING,
    String? Function(String?)? validator,
    String? labelText,
    Widget? suffixIcon,
    TextEditingController? controller,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    bool readOnly = false,
    Function(String)? onFieldSubmitted,
    Function()? onTap,
  }) : super(
          padding: padding,
          child: TextFormField(
            showCursor: false,
            readOnly: readOnly,
            onFieldSubmitted: onFieldSubmitted,
            onTap: onTap,
            validator: validator,
            decoration: InputDecoration(
              labelText: labelText,
              suffixIcon: suffixIcon,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: PRIMARY_COLOR),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
          ),
        );
}

class MyButton extends Padding {
  MyButton({
    required Widget? child,
    EdgeInsetsGeometry padding = DEFAULT_PADDING,
    required void Function()? onPressed,
  }) : super(
          padding: padding,
          child: SizedBox(
            width: double.infinity,
            height: BUTTON_HEIGHT,
            child: ElevatedButton(
              onPressed: onPressed,
              child: child,
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
            ),
          ),
        );

  static Widget defaultText(String text, {Widget? icon}) {
    List<InlineSpan> children = [
      WidgetSpan(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ];
    if (icon != null) {
      children.add(WidgetSpan(child: icon));
    }
    return RichText(
      text: TextSpan(
        children: children,
      ),
    );
  }
}

class MySplashScreen extends Scaffold {
  MySplashScreen()
      : super(
          body: Container(
            width: double.infinity,
            decoration: BACKGROUND_DECORATION,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Hãy chờ trong giây lát...',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                Text('Nếu lâu quá thì hãy khởi động lại chương trình!'),
              ],
            ),
          ),
        );
}

String getDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

String getTime(TimeOfDay time) {
  int hour = time.hour % 12;
  hour = hour == 0 ? 12 : hour;
  int minute = time.minute;
  String hourStr = hour.toString();
  String minuteStr = minute < 10 ? '0' + minute.toString() : minute.toString();
  String ampm = time.hour < 12 ? 'AM' : 'PM';
  return '$hourStr:$minuteStr $ampm';
}

String getTimeFromDate(DateTime time) {
  int hour = time.hour % 12;
  hour = hour == 0 ? 12 : hour;
  int minute = time.minute;
  int second = time.second;
  String hourStr = hour.toString();
  String minuteStr = minute < 10 ? '0' + minute.toString() : minute.toString();
  String secondStr = second < 10 ? '0' + second.toString() : second.toString();
  String ampm = time.hour < 12 ? 'AM' : 'PM';
  return '$hourStr:$minuteStr:$secondStr $ampm';
}
