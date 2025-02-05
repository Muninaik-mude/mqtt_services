// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_services/mqtt/state/mqtt_app_state.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
// import 'dart:math';

// class MQTTManager {
//   final MQTTAppState _currentState;
//   MqttServerClient? _client;
//   final String _host;
//   final String _topic;
//   String _identifier;
 

//   MQTTManager({
//     required String host,
//     required String topic,
//     required String identifier,
//     required MQTTAppState state,
   
//   })  : _host = host,
//         _topic = topic,
//         _identifier = identifier,
        
//         _currentState = state {
//     _identifier = _generateUniqueClientId(identifier);
//   }

//   String _generateUniqueClientId(String baseId) {
//     int randomId = Random().nextInt(100000);
//     return '$baseId-$randomId';
//   }

//   void initializeMQTTClient() {
//     _client = MqttServerClient(_host, _identifier);
//     // _client = MqttServerClient.withPort(_host, _identifier, 1883); 
//     _client!.port = 1883;
//     _client!.keepAlivePeriod = 20;
//     _client!.onDisconnected = onDisconnected;
//     _client!.secure = false;
//     _client!.logging(on: true);

//     _client!.onConnected = onConnected;
//     _client!.onSubscribed = onSubscribed;

//     final MqttConnectMessage connMess = MqttConnectMessage()
//         .withClientIdentifier(_identifier)
//         .withWillTopic('willtopic')
//         .withWillMessage('My Will message')
//         .startClean()
//         .withWillQos(MqttQos.atLeastOnce);
        
        
//     print('Connecting to MQTT Broker...');
//     _client!.connectionMessage = connMess;
//   }

//   void connect() async {
//     assert(_client != null);
//     try {
//       print('Connecting to broker...');
//       _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
//       await _client!.connect();
//     } on Exception catch (e) {
//       print('Connection failed: $e');
//       disconnect();
//     }
//   }

//   void disconnect() {
//     print('Disconnecting...');
//     _client!.disconnect();
//   }

//   void publish(String message) {
//     final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
//     builder.addString(message);
//     _client!.publishMessage(_topic, MqttQos.atLeastOnce, builder.payload!);
//   }

//   void onSubscribed(String topic) {
//     print('Subscribed to topic: $topic');
//   }

//   void onDisconnected() {
//     print('Client disconnected');
//     _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
//   }

//   void onConnected() {
//     print('Connected to MQTT broker');
//     _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
//     _client!.subscribe(_topic, MqttQos.atLeastOnce);

//     _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
//       final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
//       final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);
//       _currentState.setReceivedText(pt);
//       print('Received message: $pt from topic: ${c[0].topic}');
//     });
//   }
// }


//another code


import 'dart:async';
import 'dart:math';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_services/mqtt/state/mqtt_app_state.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTManager {
  final MQTTAppState _currentState;
  MqttServerClient? _client;
  final String _host;
  final String _topic;
  String _identifier;
  Timer? _messageTimer; 
  final Random _random = Random();

  
  final List<String> _randomMessages = [
    "Keep an eye on soil moisture for better crop yield!",
    "Weather update: Expect rainfall in the next few days.",
    "Use organic fertilizers for healthier crops!",
    "Proper crop rotation improves soil fertility!",
    "Water your crops early in the morning for better absorption.",
    "Pollinators like bees help improve crop production!",
    "Monitor temperature changes to protect sensitive plants.",
    "Plant cover crops to reduce soil erosion.",
    "Smart farming techniques can boost productivity!",
    "Crop disease detected nearby—take precautions!",
    "Happy farming!"
  ];

  MQTTManager({
    required String host,
    required String topic,
    required String identifier,
    required MQTTAppState state,
  })  : _host = host,
        _topic = topic,
        _identifier = identifier,
        _currentState = state {
    _identifier = _generateUniqueClientId(identifier);
  }

  String _generateUniqueClientId(String baseId) {
    int randomId = Random().nextInt(100000);
    return '$baseId-$randomId';
  }

  void initializeMQTTClient() {
    _client = MqttServerClient(_host, _identifier);
    _client!.port = 1883;
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = onDisconnected;
    _client!.secure = false;
    _client!.logging(on: true);
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .withWillTopic('disconnect/notifications')
        .withWillMessage('$_identifier has disconnected')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    _client!.connectionMessage = connMess;
  }

  void connect() async {
    assert(_client != null);
    try {
      print('Connecting to broker...');
      _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
      await _client!.connect();
    } on Exception catch (e) {
      print('Connection failed: $e');
      disconnect();
    }
  }

  void disconnect() {
    print('Disconnecting...');
    _messageTimer?.cancel(); 
    _client!.disconnect();
  }

  void publish(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(_topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  void onDisconnected() {
    print('Client disconnected');
    _messageTimer?.cancel(); 
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  void onConnected() {
    print('Connected to MQTT broker');
    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);

    _client!.subscribe(_topic, MqttQos.atLeastOnce);
    _client!.subscribe('disconnect/notifications', MqttQos.atLeastOnce);

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);
      _currentState.setReceivedText(pt);

      if (c[0].topic == 'disconnect/notifications') {
        _currentState.setDisconnectNotification(pt);
      }

      print('Received message: $pt from topic: ${c[0].topic}');
    });

    _startAutoPublishing(); 
  }

 void _startAutoPublishing() {
  _messageTimer = Timer.periodic(Duration(seconds: 30), (timer) {  
    String randomMessage = _randomMessages[_random.nextInt(_randomMessages.length)];
    String dateTimeNow = DateTime.now().toString();  
    String messageWithDate = "[$dateTimeNow] $randomMessage";  
    publish(messageWithDate);
    print("Sent random message: $messageWithDate");
  });
}
}
