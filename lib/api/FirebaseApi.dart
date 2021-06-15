import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_da_nganh/model/DeviceModel.dart';
import 'package:do_an_da_nganh/model/RoomModel.dart';
import 'package:do_an_da_nganh/model/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseApi {
  static Future<bool> register(String email, String password, String name,
      String role, String room, String sex) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      user!.updateProfile(displayName: name);
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      users.doc(user.uid).set({
        'role': role,
        'room': room,
        'sex': sex,
      });
      return true;
    } catch (e) {
      print('$e');
    }
    return false;
  }

  static Future<bool> login(String email, String password) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print('$e');
    }
    return false;
  }

  static Future<bool> logout() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      await auth.signOut();
      return true;
    } catch (e) {
      print('$e');
    }
    return false;
  }

  static Future<UserModel?> getUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get()
          .then((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          Map data = snapshot.data() as Map;
          data["id"] = user.uid;
          data["name"] = user.displayName;
          data["email"] = user.email;
          print('Document data: $data');
          String name = user.displayName != null ? user.displayName! : '';
          String email = user.email != null ? user.email! : '';
          String role = data["role"];
          String sex = data["sex"];
          String room = data["room"];
          return UserModel(user.uid, email, name, role, sex, room);
        } else {
          print('Document does not exist on the database');
        }
      });
    }
    return null;
  }

  static Future<RoomModel?> getRoomById(String id) async {
    return FirebaseFirestore.instance
        .collection("rooms")
        .doc(id)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        Map data = snapshot.data() as Map;
        print('Document data: ${data.toString()}');
        String name = data["name"];
        String measure = data["measure"];
        List<dynamic> cools = data["cools"];
        return RoomModel(id, name, measure, cools);
      } else {
        print('Document does not exist on the database');
        return null;
      }
    });
  }

  static Future<List<RoomModel>> getRooms() async {
    return FirebaseFirestore.instance
        .collection("rooms")
        .get()
        .then((querySnapshot) {
      List<RoomModel> roomModels = [];
      querySnapshot.docs.forEach((snapshot) {
        if (snapshot.exists) {
          Map data = snapshot.data();
          data["id"] = snapshot.id;
          print('Document data: ${data.toString()}');
          String id = data["id"];
          String name = data["name"];
          String measure = data["measure"];
          List<dynamic> cools = data["cools"];
          roomModels.add(RoomModel(id, name, measure, cools));
        } else {
          print('Document does not exist on the database');
        }
      });
      return roomModels;
    });
  }

  static Future<MeasureDevice?> getMeasureById(String id) async {
    return FirebaseFirestore.instance
        .collection("measures")
        .doc(id)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        Map data = snapshot.data() as Map;
        data["id"] = id;
        print('Document data: $data');
        List<int> tempHumid = (data["data"] as String)
            .split("-")
            .map((e) => int.parse(e))
            .toList();
        int temperature = tempHumid[0];
        int humidity = tempHumid[1];
        return MeasureDevice(id, temperature, humidity);
      } else {
        print('Document does not exist on the database');
        return null;
      }
    });
  }

  static Future<List<CoolDevice>> getCoolsByIds(List<dynamic> ids) async {
    CollectionReference coolsRef =
        FirebaseFirestore.instance.collection("cools");
    List<CoolDevice> cools = [];
    for (String id in ids) {
      await coolsRef.doc(id).get().then((snapshot) {
        if (snapshot.exists) {
          Map data = snapshot.data() as Map;
          data["id"] = id;
          print('Document data: $data');
          int level = data["level"];
          String name = data["name"];
          int min = data["min"];
          int max = data["max"];
          bool isOn = data["isOn"];
          cools.add(CoolDevice(id, level, name, min, max, isOn));
        } else {
          print('Document does not exist on the database');
        }
      });
    }
    return cools;
  }

  static Future<DeviceModel> getDeviceControllerByIds(
      String measureId, List<dynamic> coolIds) async {
    return getMeasureById(measureId).then((measure) {
      return getCoolsByIds(coolIds).then((cools) {
        return DeviceModel(measure, cools);
      });
    });
  }

  static Future<bool> updateUser(String? email, String? password, String? name,
      String? role, String? room, String? sex) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user!.uid);
      if (role != null) {
        await userRef.update({"role": role});
      }
      if (room != null) {
        await userRef.update({"room": room});
      }
      if (sex != null) {
        await userRef.update({"sex": sex});
      }
      if (email != null) {
        await user.updateEmail(email);
      }
      if (password != null) {
        await user.updatePassword(password);
      }
      if (name != null) {
        await user.updateProfile(displayName: name);
      }
      return true;
    } catch (e) {
      print('$e');
    }
    return false;
  }

  static Future<bool> updateLevelCoolDevice(CoolDevice cool) async {
    try {
      CollectionReference cools =
          FirebaseFirestore.instance.collection('cools');
      cools.doc(cool.id).update({
        'level': cool.level,
        'isOn': cool.isOn,
      });
      CollectionReference logs = FirebaseFirestore.instance.collection('logs');
      logs.add({
        'id': cool.id,
        'type': 'cool',
        'data': cool.isOn ? cool.level : 0,
        'timestamp': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('$e');
    }
    return false;
  }

  static Future<bool> updateMeasureDevice(MeasureDevice measure) async {
    try {
      CollectionReference measures =
          FirebaseFirestore.instance.collection('measures');
      measures.doc(measure.id).update({
        'data': '${measure.temperature}-${measure.humidity}',
      });
      CollectionReference logs = FirebaseFirestore.instance.collection('logs');
      logs.add({
        'id': measure.id,
        'type': 'measure',
        'data': '${measure.temperature}-${measure.humidity}',
        'timestamp': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('$e');
    }
    return false;
  }

  static Future<List<Map>> queryLogs(
      String id, String type, DateTime fromTime, DateTime toTime) async {
    List<Map> logResults = [];
    try {
      CollectionReference logs = FirebaseFirestore.instance.collection('logs');
      await logs
          .orderBy('timestamp', descending: true)
          .where('id', isEqualTo: id)
          .where('type', isEqualTo: type)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(fromTime),
              isLessThanOrEqualTo: Timestamp.fromDate(toTime))
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((snapshot) {
          if (snapshot.exists) {
            Map data = snapshot.data() as Map;
            data['timestamp'] = (data['timestamp'] as Timestamp).toDate();
            print('Document data: $data');
            logResults.add(data);
          } else {
            print('Document does not exist on the database');
          }
        });
      });
    } catch (e) {
      print('$e');
    }
    return logResults;
  }
}
