import 'package:do_an_da_nganh/api/FirebaseApi.dart';
import 'package:do_an_da_nganh/config.dart';

class DeviceModel {
  MeasureDevice? measure;
  List<CoolDevice> cools;

  DeviceModel(this.measure, this.cools);
}

class Device {
  String id;
  String name;
  String unit;
  Device(this.id, this.name, this.unit);
}

class MeasureDevice extends Device {
  int temperature;
  int humidity;
  bool isReal;

  static String getTopic(bool isReal) {
    if (isReal) {
      return REAL_PRE_FEED + TEMP_HUMID_FEED;
    } else {
      return PRE_FEED + TEMP_HUMID_FEED;
    }
  }

  MeasureDevice(String id, this.temperature, this.humidity)
      : isReal = true,
        super(id, "TEMP-HUMID", "C-%");

  int change(String data) {
    List<int> tempHumid = data.split("-").map((e) => int.parse(e)).toList();
    if (tempHumid[0] >= 0 &&
        tempHumid[0] <= 100 &&
        tempHumid[1] >= 0 &&
        tempHumid[1] <= 100) {
      this.temperature = tempHumid[0];
      this.humidity = tempHumid[1];
    }
    return 0;
  }

  void changeAndUpdateDb(String data) {
    int oldTemperature = temperature;
    int oldHumidity = humidity;
    try {
      change(data);
      if (oldTemperature != temperature || oldHumidity != humidity) {
        FirebaseApi.updateMeasureDevice(this);
      }
    } catch (e) {
      print('$e');
    }
  }

  String getJson() {
    if (isReal) {
      return '{"id":"7","name":"TEMP-HUMID",' +
          '"data":"$temperature-$humidity","unit":"C-%"}';
    } else {
      return '{"id":"$id","name":"$name",' +
          '"data":"$temperature-$humidity","unit":"$unit"}';
    }
  }
}

class CoolDevice extends Device {
  int level;
  int min;
  int max;
  bool isOn;
  bool isReal;

  static String getTopic(bool isReal) {
    if (isReal) {
      return REAL_PRE_FEED + REAL_FAN_FEED;
    } else {
      return PRE_FEED + COOL_FEED;
    }
  }

  CoolDevice(String id, this.level, String name, this.min, this.max, this.isOn)
      : isReal = id == "10" ? true : false,
        super(id, name, "");

  void change(String data) {
    if (data == "ON" && name != "DRV_PWM") {
      this.isOn = true;
    } else if (data == "OFF" && name != "DRV_PWM") {
      this.isOn = false;
    } else {
      int newLevel = int.parse(data);
      if (newLevel >= min && newLevel <= max) {
        this.level = newLevel;
      }
    }
  }

  void changeAndUpdateDb(String data) {
    bool oldIsOn = isOn;
    int oldLevel = level;
    try {
      change(data);
      if (oldIsOn != isOn || oldLevel != level) {
        FirebaseApi.updateLevelCoolDevice(this);
      }
    } catch (e) {
      print('$e');
    }
  }

  String getImage() {
    if (name == "FAN") {
      return "images/fan.png";
    } else if (name == "DRV_PWM") {
      return "images/drv.png";
    } else if (name == "AIR_CONDITIONER") {
      return "images/air_conditioner.png";
    }
    return "";
  }

  int getNext([bool isClockwise = true]) {
    int nextLevel = level;
    if (this.name == 'DRV_PWM') {
      if (nextLevel == 0) {
        nextLevel = isClockwise ? 85 : -85;
      } else {
        bool isPositive = nextLevel > 0;
        int x = isPositive ? nextLevel : -nextLevel;
        x += 85;
        if (x >= 255 + 85)
          return 0;
        else if (x > 255) x = 255;
        nextLevel = isPositive && x > 0 ? x : -x;
      }
    } else {
      if (nextLevel >= max) {
        if (name == "FAN") {
          nextLevel = min;
        } else {
          if (nextLevel != max) {
            nextLevel = max;
          }
        }
      } else {
        nextLevel++;
      }
    }
    return nextLevel;
  }

  int getBack() {
    int nextLevel = level;
    if (nextLevel >= max) {
      if (name == "FAN") {
        nextLevel = max;
      } else {
        if (nextLevel != min) {
          nextLevel = min;
        }
      }
    } else {
      if (this.name == 'DRV_PWM') {
        int x = nextLevel - 85;
        x = x < -255 ? -255 : x;
        nextLevel = x;
      } else {
        nextLevel--;
      }
    }
    return nextLevel;
  }

  String getJson(String data) {
    if (isReal) {
      return '{"id":"10","name":"DRV_PWM","data":"$data","unit":""}';
    } else {
      return '{"id":"$id","name":"$name","data":"$data","unit":"$unit"}';
    }
  }
}
