import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:do_an_da_nganh/api/FirebaseApi.dart';
import 'package:do_an_da_nganh/api/MqttClientApi.dart';
import 'package:do_an_da_nganh/config.dart';
import 'package:do_an_da_nganh/model/DeviceModel.dart';
import 'package:do_an_da_nganh/model/RoomModel.dart';
import 'package:do_an_da_nganh/model/UserModel.dart';
import 'package:do_an_da_nganh/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

class DeviceController extends StatelessWidget {
  DeviceController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RoomModel>>(
      future: FirebaseApi.getRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            body: MyScrollView(
              slivers: [
                MySliverAppBar(
                  title: MySliverAppBar.defaultTitle('Điều Khiển Thiết Bị'),
                  leading: MySliverAppBar.defaultLedding(context),
                ),
                MySliverBody(
                  child: DeviceControllerBody(snapshot.data!),
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

class DeviceControllerBody extends StatefulWidget {
  final List<RoomModel> roomModels;
  DeviceControllerBody(this.roomModels);

  @override
  _DeviceControllerBodyState createState() => _DeviceControllerBodyState();
}

class _DeviceControllerBodyState extends State<DeviceControllerBody> {
  late RoomModel _currentRoom;

  @override
  void initState() {
    super.initState();
    _setRoomById(UserModel.instance!.roomId);
  }

  void _setRoomById(String id) {
    widget.roomModels.forEach((room) {
      if (room.id == id) {
        setState(() {
          this._currentRoom = room;
        });
      }
    });
  }

  Future<Map> _loadRoomData() async {
    MqttClientApi mqtt = MqttClientApi(_currentRoom.isReal);
    await mqtt.subscribe(MeasureDevice.getTopic(_currentRoom.isReal));
    await mqtt.subscribe(CoolDevice.getTopic(_currentRoom.isReal));
    DeviceModel deviceModel = await FirebaseApi.getDeviceControllerByIds(
        _currentRoom.measure, _currentRoom.cools);
    Map data = Map();
    data["mqtt"] = mqtt;
    data["deviceModel"] = deviceModel;
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyDropdown(
          value: _currentRoom.id,
          items: widget.roomModels
              .map<DropdownMenuItem<String>>((RoomModel roomModel) {
            return DropdownMenuItem<String>(
              value: roomModel.id,
              child: Text(roomModel.name),
            );
          }).toList(),
          labelText: "Phòng Ban",
          onChanged: (String? roomId) {
            if (roomId != null) {
              _setRoomById(roomId);
            }
          },
        ),
        FutureBuilder<Map>(
          future: _loadRoomData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              Map data = snapshot.data!;
              return DeviceControllerSubBody(
                  data["mqtt"], _currentRoom, data["deviceModel"]);
            }
            return LinearProgressIndicator();
          },
        ),
      ],
    );
  }
}

class DeviceControllerSubBody extends StatefulWidget {
  final DeviceModel deviceModel;
  final RoomModel currentRoom;
  final MqttClientApi mqtt;

  DeviceControllerSubBody(this.mqtt, this.currentRoom, this.deviceModel);
  @override
  _DeviceControllerSubBodyState createState() =>
      _DeviceControllerSubBodyState();
}

class _DeviceControllerSubBodyState extends State<DeviceControllerSubBody> {
  late int _currentCoolIndex;
  late bool _isClockwise;

  @override
  void initState() {
    super.initState();
    _currentCoolIndex = 0;
    widget.mqtt.addListen(_update);
  }

  @override
  void dispose() {
    widget.mqtt.disconnect();
    super.dispose();
  }

  void setCoolIndexNext() {
    if (_currentCoolIndex < widget.deviceModel.cools.length - 1) {
      setState(() {
        _currentCoolIndex++;
      });
    }
  }

  void setCoolIndexBack() {
    if (_currentCoolIndex > 0) {
      setState(() {
        _currentCoolIndex--;
      });
    }
  }

  Future<void> _publish(String topic, String message) async {
    return widget.mqtt.publish(topic, message);
  }

  Future<void> _update(String topic, String payload) async {
    if (topic == CoolDevice.getTopic(widget.currentRoom.isReal)) {
      try {
        Map<String, dynamic> coolDataJson = jsonDecode(payload);
        if (coolDataJson['name'] == 'DRV_PWM') {
          if (int.parse(coolDataJson['data']) > 0) {
            _isClockwise = true;
          } else if (int.parse(coolDataJson['data']) < 0) {
            _isClockwise = false;
          }
        }
        widget.deviceModel.cools.forEach((cool) {
          if (coolDataJson['id'] == cool.id) {
            if (cool.id == widget.deviceModel.cools[_currentCoolIndex].id) {
              setState(() {
                cool.changeAndUpdateDb(coolDataJson['data']);
              });
            } else {
              cool.changeAndUpdateDb(coolDataJson['data']);
            }
          }
        });
      } catch (e) {
        print(e.toString());
      }
    } else if (topic == MeasureDevice.getTopic(widget.currentRoom.isReal)) {
      try {
        Map<String, dynamic> measureDataJson = jsonDecode(payload);
        MeasureDevice measure = widget.deviceModel.measure!;
        if (measureDataJson['id'] == measure.id) {
          setState(() {
            measure.changeAndUpdateDb(measureDataJson['data']);
          });
        }
      } catch (e) {
        print(e.toString());
      }
    }
  }

  Widget _tempAndHumidView() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffFEB35B),
        border: Border.all(width: 20, color: Color(0xffFEB35B)),
        borderRadius: const BorderRadius.all(const Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Color(0x3A000000),
            spreadRadius: 20, //spread radius
            blurRadius: 43, // blur radius
            offset: Offset(0, 2),
          )
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                  child: Icon(
                    WeatherIcons.thermometer,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
                WidgetSpan(
                  child: Text(
                    "${widget.deviceModel.measure!.temperature}\u00B0C",
                    style: TextStyle(
                      fontSize: 30,
                      height: 1,
                      color: Colors.black,
                    ),
                  ),
                  alignment: PlaceholderAlignment.middle,
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                  child: Icon(
                    WeatherIcons.humidity,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
                WidgetSpan(
                  child: Text(
                    "${widget.deviceModel.measure!.humidity}%",
                    style: TextStyle(
                      height: 1,
                      fontSize: 30,
                      color: Colors.black,
                    ),
                  ),
                  alignment: PlaceholderAlignment.middle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drvController(CoolDevice cool) {
    return Column(
      children: [
        Container(
            decoration: BoxDecoration(
              color: Color(0x2FFDA43C),
              borderRadius: const BorderRadius.all(const Radius.circular(60)),
            ),
            width: 280,
            height: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '~  ${cool.isOn ? cool.level.toString() : 'OFF'}  ~',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: PRIMARY_COLOR, fontSize: 30),
                ),
              ],
            )),
        SizedBox(height: 80),
        Center(
          child: Container(
            width: 140,
            height: 140,
            child: CustomPaint(
              painter: FanControl(0, 3,
                  (cool.level > 0 ? cool.level : -cool.level / 85).ceil()),
              child: InkResponse(
                onTap: () {
                  if (cool.isOn) {
                    this._publish(
                        CoolDevice.getTopic(widget.currentRoom.isReal),
                        cool.getJson(cool.getNext(_isClockwise).toString()));
                  }
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 80),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              color: !_isClockwise ? PRIMARY_COLOR : Colors.white,
              onPressed: () {
                this._publish(CoolDevice.getTopic(widget.currentRoom.isReal),
                    cool.getJson("0"));
                this._isClockwise = false;
              },
              iconSize: 50,
              icon: Icon(Icons.restore),
            ),
            IconButton(
              color: _isClockwise ? PRIMARY_COLOR : Colors.white,
              onPressed: () {
                this._publish(CoolDevice.getTopic(widget.currentRoom.isReal),
                    cool.getJson("0"));
                this._isClockwise = true;
              },
              iconSize: 50,
              icon: Icon(Icons.update),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fanController(CoolDevice cool) {
    return Column(
      children: [
        Container(
            decoration: BoxDecoration(
              color: Color(0x2FFDA43C),
              borderRadius: const BorderRadius.all(const Radius.circular(60)),
            ),
            width: 280,
            height: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '~  ${cool.isOn ? cool.level.toString() : 'OFF'}  ~',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: PRIMARY_COLOR, fontSize: 30),
                ),
              ],
            )),
        SizedBox(height: 80),
        Center(
          child: Container(
            width: 140,
            height: 140,
            child: CustomPaint(
              painter: FanControl(cool.min, cool.max, cool.level),
              child: InkResponse(
                onTap: () {
                  if (cool.isOn) {
                    this._publish(
                        CoolDevice.getTopic(widget.currentRoom.isReal),
                        cool.getJson(cool.getNext().toString()));
                  }
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 80),
        IconButton(
          color: PRIMARY_COLOR,
          onPressed: () {
            String nextState = cool.isOn ? "OFF" : "ON";
            this._publish(CoolDevice.getTopic(widget.currentRoom.isReal),
                cool.getJson(nextState));
          },
          iconSize: 50,
          icon: Icon(Icons.power_settings_new_rounded),
        ),
      ],
    );
  }

  Widget _coolController() {
    Color backColor = Colors.transparent;
    Color nextColor = Colors.transparent;
    if (_currentCoolIndex > 0) {
      backColor = Colors.white;
    }
    if (_currentCoolIndex < widget.deviceModel.cools.length - 1) {
      nextColor = Colors.white;
    }
    CoolDevice cool = widget.deviceModel.cools[_currentCoolIndex];
    Widget control;
    if (cool.name == "DRV_PWM") {
      if (cool.level >= 0) {
        _isClockwise = true;
      } else {
        _isClockwise = false;
      }
      control = _drvController(cool);
    } else if (cool.name == "FAN") {
      control = _fanController(cool);
    } else {
      control = Text("Error");
    }
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: IconButton(
                  iconSize: 40,
                  color: backColor,
                  icon: Icon(Icons.arrow_left),
                  onPressed: setCoolIndexBack,
                ),
                alignment: PlaceholderAlignment.middle,
              ),
              WidgetSpan(
                child: Text(
                  '${cool.name}_${cool.id}',
                  style: TextStyle(fontSize: 20),
                ),
                alignment: PlaceholderAlignment.middle,
              ),
              WidgetSpan(
                child: IconButton(
                  iconSize: 40,
                  color: nextColor,
                  icon: Icon(Icons.arrow_right),
                  onPressed: setCoolIndexNext,
                ),
                alignment: PlaceholderAlignment.middle,
              ),
            ],
          ),
        ),
        Image.asset(
          cool.getImage(),
          width: double.infinity,
        ),
        SizedBox(height: 20),
        control,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        _tempAndHumidView(),
        SizedBox(height: 10),
        _coolController(),
        SizedBox(height: 20),
      ],
    );
  }
}

class FanControl extends CustomPainter {
  final int max;
  final int min;
  final int cur;

  FanControl(this.min, this.max, this.cur);

  Offset getOffsetFromRadians(double radius, double radians, Offset center,
      {double fontSize = 0}) {
    return Offset(
      radius * math.cos(radians) + center.dx - fontSize / 4,
      radius * math.sin(radians) + center.dy - fontSize / 2,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * 1.4;
    final fontSize = 0.2 * radius;

    final bigCircle = Paint()
      ..color = Color(0xff3F3F3F)
      ..style = PaintingStyle.fill;

    final smallCircle = Paint()
      ..shader = ui.Gradient.sweep(
          center,
          [Color(0xffFDA43C), Color(0xff282828)],
          null,
          TileMode.mirror,
          math.pi / 2,
          math.pi)
      ..style = PaintingStyle.fill;

    final controlLine = Paint()
      ..color = Color(0xffFDA43C)
      ..strokeWidth = 0.02 * radius
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, bigCircle);
    canvas.drawCircle(center, 0.8 * radius, smallCircle);
    for (int i = min; i <= max; i++) {
      var tpainter = TextPainter(
        text: TextSpan(
          text: i.toString(),
          style: TextStyle(color: Color(0xffFDA43C), fontSize: fontSize),
        ),
        textDirection: TextDirection.ltr,
      );
      tpainter.layout(
        minWidth: 0,
        maxWidth: 100,
      );
      double radians = 2 * math.pi * (-1 / 4 + (i - min) / (max - min + 1));
      var textOffset = getOffsetFromRadians(
          radius + fontSize * 0.8, radians, center,
          fontSize: fontSize);
      tpainter.paint(canvas, textOffset);
      var fromLineOffset = getOffsetFromRadians(radius * 0.84, radians, center);
      var toLineOffset = getOffsetFromRadians(radius * 0.96, radians, center);
      canvas.drawLine(fromLineOffset, toLineOffset, controlLine);

      // Draw control
      double curRadians =
          2 * math.pi * (-1 / 4 + (cur - min) / (max - min + 1));
      final control = Paint()
        ..shader = ui.Gradient.sweep(
            center,
            [Color(0xff282828), Color(0xff535151), Color(0xff282828)],
            [0, 0.4, 0.8],
            TileMode.repeated,
            0 + curRadians,
            math.pi * 2 / 3 + curRadians)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius / 1.4, control);

      var curToLineOffset =
          getOffsetFromRadians(radius * 0.6, curRadians, center);
      final curCircle = Paint()
        ..shader = ui.Gradient.radial(curToLineOffset, 0.1 * radius, [
          Color(0xffFDA43C),
          Color(0xff282828),
        ])
        ..strokeWidth = 0.05 * radius
        ..style = PaintingStyle.fill;
      canvas.drawCircle(curToLineOffset, 0.1 * radius, curCircle);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
