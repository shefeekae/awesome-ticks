import 'package:data_collection_package/data_collection_package.dart';
import 'package:flutter/foundation.dart';
import 'package:nectar_mqtt/nectar_mqtt.dart';


class MqttServices{
  
  Future<void> connectToMqttClient() async {
  MqttClient mqttClient = MqttClient();
  
  String udid = await Udid().getUdid();
  
  try {
    mqttClient.connect(
        server: 'messages.nectarit.com',
        clientIdentifier: udid,
        port: 8884,
        username: 'mobile-ui',
        password: 'NecAws@123');
  
    // print('mqtt connection successfull');
  } catch (e) {
    if (kDebugMode) {
      print("Connect method exception : ${e.toString()}");
    }
  }
}
  
  
}