import 'package:flutter/material.dart';
import 'package:do_an_da_nganh/utils/utils.dart';

const double CHILD_PADDING = 10;
const double BUTTON_HEIGHT = 50;
const EdgeInsetsGeometry DEFAULT_PADDING =
    const EdgeInsets.symmetric(vertical: 5);

const COOL_FEED = "bk-iot-cool";
const TEMP_HUMID_FEED = "bk-iot-temp-humid";
const REAL_FAN_FEED = "bk-iot-drv";

// ignore: non_constant_identifier_names
final MaterialColor PRIMARY_COLOR = customMaterialColor(0xffFDA43C);
// ignore: non_constant_identifier_names
final BoxDecoration BACKGROUND_DECORATION = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xffCB9191),
      Color(0xff000000),
    ],
  ),
);
// ignore: non_constant_identifier_names
final ThemeData THEME = ThemeData(
  // Define the default brightness and colors.
  brightness: Brightness.dark,
  primaryColor: PRIMARY_COLOR,
  accentColor: PRIMARY_COLOR,
  hintColor: Colors.white,
  errorColor: Color(0xffff3322),
  primarySwatch: PRIMARY_COLOR,
  // Define the default font family.
  //fontFamily: 'Georgia',

  // Define the default TextTheme. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: TextTheme(
    headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
    headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
    // bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
    bodyText2: TextStyle(fontSize: 14.0),
  ),
);
