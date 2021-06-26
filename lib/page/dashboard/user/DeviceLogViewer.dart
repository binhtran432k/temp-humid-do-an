import 'package:do_an_da_nganh/api/FirebaseApi.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:do_an_da_nganh/model/DeviceModel.dart';
import 'package:do_an_da_nganh/model/RoomModel.dart';
import 'package:do_an_da_nganh/model/UserModel.dart';
import 'package:do_an_da_nganh/utils/utils.dart';
import 'package:flutter/material.dart';

class DeviceLogViewer extends StatelessWidget {
  final DateTime fromTime;
  final DateTime toTime;
  DeviceLogViewer(this.fromTime, this.toTime);

  Future<List<RoomModel>> _loadData() async {
    return await FirebaseApi.getRooms();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RoomModel>>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            body: MyScrollView(
              slivers: [
                MySliverAppBar(
                  title: MySliverAppBar.defaultTitle('Nhật ký điều khiển'),
                  leading: MySliverAppBar.defaultLedding(context),
                ),
                MySliverBody(
                  child: DeviceLogViewerBody(fromTime, toTime, snapshot.data!),
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

class DeviceLogViewerBody extends StatefulWidget {
  final DateTime fromTime;
  final DateTime toTime;
  final List<RoomModel> rooms;
  DeviceLogViewerBody(this.fromTime, this.toTime, this.rooms);

  @override
  _DeviceLogViewerBodyState createState() => _DeviceLogViewerBodyState();
}

class _DeviceLogViewerBodyState extends State<DeviceLogViewerBody> {
  late RoomModel _currentRoom;
  @override
  void initState() {
    super.initState();
    _setRoomById(UserModel.instance!.roomId);
  }

  Future<DeviceModel> _loadRoomData() async {
    DeviceModel deviceModel = await FirebaseApi.getDeviceControllerByIds(
        _currentRoom.measure, _currentRoom.cools);
    return deviceModel;
  }

  void _setRoomById(String id) {
    widget.rooms.forEach((room) {
      if (room.id == id) {
        setState(() {
          this._currentRoom = room;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyDropdown(
          value: _currentRoom.id,
          items: widget.rooms.map<DropdownMenuItem<String>>((RoomModel room) {
            return DropdownMenuItem<String>(
              value: room.id,
              child: Text(room.name),
            );
          }).toList(),
          labelText: "Phòng Ban",
          onChanged: (String? roomId) {
            if (roomId != null) {
              _setRoomById(roomId);
            }
          },
        ),
        SizedBox(height: 10),
        FutureBuilder<DeviceModel>(
          future: _loadRoomData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return DeviceLogViewerSubBody(
                  snapshot.data!, widget.fromTime, widget.toTime);
            }
            return LinearProgressIndicator();
          },
        ),
      ],
    );
  }
}

class DeviceLogViewerSubBody extends StatefulWidget {
  final DeviceModel deviceModel;
  final DateTime fromTime;
  final DateTime toTime;
  DeviceLogViewerSubBody(this.deviceModel, this.fromTime, this.toTime);

  @override
  _DeviceLogViewerSubBodyState createState() => _DeviceLogViewerSubBodyState();
}

class _DeviceLogViewerSubBodyState extends State<DeviceLogViewerSubBody> {
  late int _currentIndex;
  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
  }

  void setIndexNext() {
    if (_currentIndex < widget.deviceModel.cools.length) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void setIndexBack() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  LineChartData _zeroData(double minY, double maxY) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff67727d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff67727d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
              color: Color(0xffFFFDFB),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            if (value == 0) {
              return getTimeFromDate(widget.fromTime);
            } else {
              return getTimeFromDate(widget.toTime);
            }
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xffFFFDFB),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            return value.toInt().toString();
          },
          interval: (maxY - minY) <= 5 ? 1 : (maxY - minY) / 4,
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff67727d), width: 1)),
      minX: 0,
      maxX: 1,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: [],
          isCurved: true,
          colors: _gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                _gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  LineChartData _mainData(
      double minY, double maxY, String unit, List<Map<String, dynamic>> data) {
    if (data.length == 0) {
      return _zeroData(minY, maxY);
    }
    double minX = 0;
    double maxX = data.length.toDouble() - 1;
    List<FlSpot> spots = [];
    for (int i = 0; i <= maxX; i++) {
      spots.add(FlSpot(
        i.toDouble(),
        (data[i]['data'] as int).toDouble(),
      ));
    }
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff67727d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff67727d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
              color: Color(0xffFFFDFB),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            return getTimeFromDate(data[value.toInt()]['time']);
          },
          interval: (maxX - minX) < 3 ? 1 : (maxX - minX) / 2,
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xffFFFDFB),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            return value.toInt().toString();
          },
          interval: (maxY - minY) <= 5 ? 1 : (maxY - minY) / 4,
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff67727d), width: 1)),
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          colors: _gradientColors,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                _gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                  '${getTimeFromDate(data[spot.x.toInt()]['time'])}' +
                      '\n${spot.y}$unit',
                  TextStyle());
            }).toList();
          },
        ),
      ),
    );
  }

  List<Color> _gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  Widget _logChart(String title, double min, double max, String unit,
      List<Map<String, dynamic>> data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title),
        SizedBox(height: 10),
        SizedBox(
          width: 480,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: LineChart(
              _mainData(min, max, unit, data.reversed.toList()),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Device device = _currentIndex > 0
        ? widget.deviceModel.cools[_currentIndex - 1]
        : widget.deviceModel.measure!;
    String type = _currentIndex > 0 ? 'cool' : 'measure';
    Color backColor = Colors.transparent;
    Color nextColor = Colors.transparent;
    if (_currentIndex > 0) {
      backColor = Colors.white;
    }
    if (_currentIndex < widget.deviceModel.cools.length) {
      nextColor = Colors.white;
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
                  onPressed: setIndexBack,
                ),
                alignment: PlaceholderAlignment.middle,
              ),
              WidgetSpan(
                child: Text(
                  '${device.name}_${device.id}',
                  style: TextStyle(fontSize: 20),
                ),
                alignment: PlaceholderAlignment.middle,
              ),
              WidgetSpan(
                child: IconButton(
                  iconSize: 40,
                  color: nextColor,
                  icon: Icon(Icons.arrow_right),
                  onPressed: setIndexNext,
                ),
                alignment: PlaceholderAlignment.middle,
              ),
            ],
          ),
        ),
        FutureBuilder<List<Map>>(
          future: FirebaseApi.queryLogs(
              device.id, type, widget.fromTime, widget.toTime),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (type == 'cool') {
                return _logChart(
                    "Mức Độ",
                    (device as CoolDevice).min.toDouble(),
                    device.max.toDouble(),
                    "",
                    snapshot.data!
                        .map((e) => {
                              'time': e['timestamp'],
                              'data': e['data'],
                            })
                        .toList());
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _logChart(
                        "Nhiệt Độ",
                        0,
                        100,
                        "\u00B0C",
                        snapshot.data!
                            .map((e) => {
                                  'time': e['timestamp'],
                                  'data': (e["data"] as String)
                                      .split("-")
                                      .map((e) => int.parse(e))
                                      .toList()[0]
                                })
                            .toList()),
                    SizedBox(height: 10),
                    _logChart(
                        "Độ Ẩm",
                        0,
                        100,
                        "%",
                        snapshot.data!
                            .map((e) => {
                                  'time': e['timestamp'],
                                  'data': (e["data"] as String)
                                      .split("-")
                                      .map((e) => int.parse(e))
                                      .toList()[1]
                                })
                            .toList()),
                  ],
                );
              }
            }
            return LinearProgressIndicator();
          },
        ),
      ],
    );
  }
}
