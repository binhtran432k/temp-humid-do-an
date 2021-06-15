import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';

import 'mqtt/MqttServerClient.dart'
    if (dart.library.html) 'mqtt/MqttBrowserClient.dart' as mqttsetup;

class MqttClientApi {
  var _client;
  late String _identifier;
  Future<Null>? isWorking;
  bool isReal;

  MqttClientApi([this.isReal = false]) {
    this._identifier = UniqueKey().toString();
  }

  Future<void> disconnect() async {
    if (_client != null) {
      _client.disconnect();
    }
  }

  Future<bool> subscribe(String topic) async {
    if (isWorking != null) {
      await isWorking; // wait for future complete
      return subscribe(topic);
    }

    // lock
    var completer = new Completer<Null>();
    isWorking = completer.future;

    if (await _connectToClient() == true) {
      _subscribe(topic);
    }

    // unlock
    completer.complete();
    isWorking = null;

    return true;
  }

  //
  // Connect to Mqtt server
  //
  Future<bool> _connectToClient() async {
    if (_client != null &&
        _client.connectionStatus.state == MqttConnectionState.connected) {
    } else {
      _client = await _login();
      if (_client == null) {
        return false;
      }
    }
    return true;
  }

  void _onSubscribed(String topic) {
    print('Subscribed topic: $topic');
  }

  void _onDisconnected() {
    print('Disconnected');
  }

  void _onConnected() {
    print('Connected');
  }

  void _onSubscribeFail(String topic) {
    print('Failed to subscribe topic: $topic');
  }

  void _onUnsubscribed(String? topic) {
    print('Unsubscribed topic: $topic');
  }

  void _pong() {
    print('Ping response client callback invoked');
  }

  //static Stream<List<Watts>> wattsStream() {}
  //
  Future<Map> _getBroker() async {
    String connect = await rootBundle.loadString('config/private.json');
    return (json.decode(connect));
  }

  //
  // login to Broker
  //
  Future<MqttClient> _login() async {
    Map connectJson = await _getBroker();
    String broker = connectJson["broker"];
    String host;
    int port;
    if (kIsWeb) {
      host = connectJson[broker]["wsbroker"]["host"];
      port = connectJson[broker]["wsbroker"]["port"];
    } else {
      host = connectJson[broker]["broker"]["host"];
      port = connectJson[broker]["broker"]["port"];
    }
    String username = "";
    String key = "";
    if (isReal) {
      username = connectJson["realUsername"];
      key = connectJson["realKey"];
    } else {
      username = connectJson["username"];
      key = connectJson["key"];
    }
    _client = mqttsetup.setup(host, key, port);
    //_client.logging(on: true);

    /// Add the unsolicited disconnection callback
    _client.onDisconnected = _onDisconnected;
    _client.onConnected = _onConnected;
    _client.onSubscribed = _onSubscribed;
    _client.onUnsubscribed = _onUnsubscribed;
    _client.onSubscribeFail = _onSubscribeFail;
    _client.pongCallback = _pong;

    _client.keepAlivePeriod = 60;

    final connMess = MqttConnectMessage()
        .withClientIdentifier("client" + _identifier)
        .authenticateAs(username, key)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client.connectionMessage = connMess;
    try {
      print('Connecting');
      await _client.connect();
    } catch (e) {
      print('Exception: $e');
      _client.disconnect();
      _client = null;
      return _client;
    }

    if (_client.connectionStatus.state == MqttConnectionState.connected) {
      print('Client connected');

      _client.published.listen((MqttPublishMessage message) {
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message!);
        print('Published message: $payload to topic: ' +
            '${message.variableHeader!.topicName}');
      });
    } else {
      print('Client connection failed - disconnecting, ' +
          'status is ${_client.connectionStatus}');
      _client.disconnect();
      //if (!kIsWeb) {
      //  exit(-1);
      //}
      _client = null;
    }

    return _client;
  }

//
// Subscribe to the readings being published into Adafruit's mqtt by the energy monitor(s).
//
  Future<void> _subscribe(String topic,
      {MqttQos qos = MqttQos.atLeastOnce}) async {
    // for now hardcoding the topic
    _client.subscribe(topic, qos);
  }

  void addListen(dynamic callback) {
    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    _client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message!);

      print('Received message: $payload from topic: ${c[0].topic}');
      callback(c[0].topic, payload);
    });
  }

//////////////////////////////////////////
// Publish to an (Adafruit) mqtt topic.
  Future<void> publish(String topic, String value,
      {bool retain = false, MqttQos qos = MqttQos.atMostOnce}) async {
    if (isWorking != null) {
      await isWorking; // wait for future complete
      return publish(topic, value);
    }

    // lock
    var completer = Completer<Null>();
    isWorking = completer.future;

    // Connect to the client if we haven't already
    if (await _connectToClient() == true) {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(value);
      _client.publishMessage(topic, qos, builder.payload, retain: retain);
    }

    // unlock
    completer.complete();
    isWorking = null;
  }
}
