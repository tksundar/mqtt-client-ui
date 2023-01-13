import 'dart:convert';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTClient {
  late final MqttServerClient _client;

  late String recvdMsg;

  late String subscribedTopic;

  String get _recvdMsg {
    return recvdMsg;
  }

  String get _subscribedTopic {
    return subscribedTopic;
  }

  MQTTClient(String url, String clientId, String port) {
    _client = MqttServerClient(url, port);
    _client.keepAlivePeriod = 60;
    _client.onConnected = onConnected;
    _client.onDisconnected = onDisconnected;
    MqttConnectMessage connectMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillTopic('willtopic')
        .withWillMessage('My will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client.connectionMessage = connectMessage;
    _client.logging(on: true);
  }

  void subscribe(String topic) {
    _client.onSubscribed = onSubscribed;
    _client.subscribe(topic, MqttQos.atLeastOnce);
    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? msg) {
      final recMess = msg![0].payload as MqttPublishMessage;
      List<int> msgbytes = (recMess.payload.message).cast<int>();
      recvdMsg = utf8.decode(msgbytes);
      subscribedTopic = topic;
      print(
          'Received message: topic is ${msg[0].topic}, payload is $recvdMsg ');
    });
  }

  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    _client.published!.listen((event) {
      List<int> msgBytes = event.payload.message.cast<int>();
      print(
          'Published topic: topic is ${event.variableHeader!.topicName}, with Qos ${event.header!.qos} and paayload as ${utf8.decode(msgBytes)}');
    });
  }

  Future<int> connect() async {
    try {
      await _client.connect();
    } on NoConnectionException catch (e) {
      print('connect exception - $e');
    } on SocketException catch (e) {
      print('socket exception - $e');
    }
    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      print('client connected');
    } else {
      print(
          'client connection failed - disconnecting, status is ${_client.connectionStatus}');
      _client.disconnect();
      exit(-1);
    }

    return 0;
  }

  void disconnect() {
    _client.disconnect();
  }

  void onSubscribed(String topic) {
    print('subscribed $topic');
  }

  void onConnected() {
    print("client connected");
  }

  void onDisconnected() {
    print('client disconnected');
  }
}
