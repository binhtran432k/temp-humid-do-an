import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

MqttClient setup(String serverAddress, String uniqueID, int port) {
  return new MqttBrowserClient.withPort(serverAddress, uniqueID, port);
}
