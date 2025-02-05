import 'package:flutter/material.dart';

import 'package:mqtt_services/widgets/mqtt_View.dart';
import 'package:mqtt_services/mqtt/state/mqtt_app_state.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        title: 'Mqtt',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ChangeNotifierProvider<MQTTAppState>(
          create: (_) => MQTTAppState(),
          child: MQTTView(),
        ));
  }
}











 /*
    final MQTTManager manager = MQTTManager(host:'test.mosquitto.org',topic:'flutter/amp/cool',identifier:'ios');
    manager.initializeMQTTClient();
       */