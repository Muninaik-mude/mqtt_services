import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mqtt_services/mqtt/state/mqtt_app_state.dart';
import 'package:mqtt_services/mqtt/mqtt_manager.dart';
import 'package:uuid/uuid.dart';

class MQTTView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MQTTViewState();
  }
}

class _MQTTViewState extends State<MQTTView> {
  final TextEditingController _hostTextController = TextEditingController();
  final TextEditingController _messageTextController = TextEditingController();
  final TextEditingController _topicTextController = TextEditingController();

  late MQTTAppState currentAppState;
  late MQTTManager manager;
  String deviceIdentifier = 'Flutter_Device';
  final Uuid uuid = Uuid();

  @override
  void dispose() {
    _hostTextController.dispose();
    _messageTextController.dispose();
    _topicTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    currentAppState = Provider.of<MQTTAppState>(context);

      WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentAppState.disconnectNotification.isNotEmpty) {
        _showSnackBar(currentAppState.disconnectNotification);
        currentAppState.clearDisconnectNotification();
      }
    });
    
   
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentAppState.getAppConnectionState == MQTTAppConnectionState.disconnected) {
        _showSnackBar("Your device is disconnected.");
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('MQTT Client')),
        backgroundColor: Colors.greenAccent,
      ),
      body: _buildColumn(),
    );
  }

  Widget _buildColumn() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          _buildConnectionStateText(
              _prepareStateMessageFrom(currentAppState.getAppConnectionState)),
          const SizedBox(height: 20),
          _buildEditableColumn(),
          const SizedBox(height: 20),
          _buildScrollableTextWith(currentAppState.getHistoryText),
        ],
      ),
    );
  }

  Widget _buildEditableColumn() {
    return Column(
      children: <Widget>[
        _buildTextFieldWith(_hostTextController, 'Enter broker address',
            currentAppState.getAppConnectionState),
        const SizedBox(height: 10),
        _buildTextFieldWith(_topicTextController, 'Enter topic to subscribe',
            currentAppState.getAppConnectionState),
        const SizedBox(height: 10),
        _buildPublishMessageRow(),
        const SizedBox(height: 10),
        _buildConnectButtonFrom(currentAppState.getAppConnectionState),
      ],
    );
  }

  Widget _buildPublishMessageRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: _buildTextFieldWith(_messageTextController, 'Enter a message',
              currentAppState.getAppConnectionState),
        ),
        _buildSendButtonFrom(currentAppState.getAppConnectionState),
      ],
    );
  }

  Widget _buildConnectButtonFrom(MQTTAppConnectionState state) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
            child: const Text('Connect'),
            onPressed: state == MQTTAppConnectionState.disconnected ? _configureAndConnect : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Disconnect'),
            onPressed: state == MQTTAppConnectionState.connected ? _disconnect : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSendButtonFrom(MQTTAppConnectionState state) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      child: const Text('Send'),
      onPressed: state == MQTTAppConnectionState.connected
          ? () {
              _publishMessage(_messageTextController.text);
            }
          : null,
    );
  }

  Widget _buildTextFieldWith(TextEditingController controller, String hintText, MQTTAppConnectionState state) {
    return TextField(
      enabled: (controller == _messageTextController && state == MQTTAppConnectionState.connected) ||
          ((controller == _hostTextController || controller == _topicTextController) &&
              state == MQTTAppConnectionState.disconnected),
      controller: controller,
      decoration: InputDecoration(labelText: hintText),
    );
  }

  Widget _buildConnectionStateText(String status) {
    return Text(
      status,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildScrollableTextWith(String historyText) {
    return Expanded(
      child: SingleChildScrollView(
        child: Text(historyText),
      ),
    );
  }

  String _prepareStateMessageFrom(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting...';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
      default:
        return 'Unknown State';
    }
  }

  void _configureAndConnect() {
    // Generate a unique identifier using UUID
    deviceIdentifier = uuid.v4();
    
    manager = MQTTManager(
      host: _hostTextController.text,
      topic: _topicTextController.text,
      identifier: deviceIdentifier,
      state: currentAppState,
    );

    manager.initializeMQTTClient();
    manager.connect();
  }

  void _disconnect() {
    manager.disconnect();
    _showSnackBar("Your device is disconnected.");
  }

  void _publishMessage(String text) {
    if (text.isNotEmpty) {
      final String message = '$deviceIdentifier says: $text';
      manager.publish(message);
      _messageTextController.clear();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 3)),
    );
  }
}
//another code

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:mqtt_services/mqtt/state/mqtt_app_state.dart';
// import 'package:mqtt_services/mqtt/mqtt_manager.dart';
// import 'package:uuid/uuid.dart';

// class MQTTView extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return _MQTTViewState();
//   }
// }

// class _MQTTViewState extends State<MQTTView> {
//   final TextEditingController _hostTextController = TextEditingController();
//   final TextEditingController _messageTextController = TextEditingController();
//   final TextEditingController _topicTextController = TextEditingController();

//   late MQTTAppState currentAppState;
//   late MQTTManager manager;
//   String deviceIdentifier = 'Flutter_Device';
//   final Uuid uuid = Uuid();

//   @override
//   void dispose() {
//     _hostTextController.dispose();
//     _messageTextController.dispose();
//     _topicTextController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     currentAppState = Provider.of<MQTTAppState>(context);

//     // Show disconnect message if received
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (currentAppState.disconnectNotification.isNotEmpty) {
//         _showSnackBar(currentAppState.disconnectNotification);
//         currentAppState.clearDisconnectNotification();
//       }
//     });

//     return Scaffold(
//       appBar: AppBar(
//         title: Center(child: const Text('MQTT Client')),
//         backgroundColor: Colors.greenAccent,
//       ),
//       body: _buildColumn(),
//     );
//   }

//   Widget _buildColumn() {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         children: <Widget>[
//           _buildConnectionStateText(
//               _prepareStateMessageFrom(currentAppState.getAppConnectionState)),
//           const SizedBox(height: 20),
//           _buildEditableColumn(),
//           const SizedBox(height: 20),
//           _buildScrollableTextWith(currentAppState.getHistoryText),
//         ],
//       ),
//     );
//   }

//   void _configureAndConnect() {
//     deviceIdentifier = uuid.v4();

//     manager = MQTTManager(
//       host: _hostTextController.text,
//       topic: _topicTextController.text,
//       identifier: deviceIdentifier,
//       state: currentAppState,
//     );

//     manager.initializeMQTTClient();
//     manager.connect();
//   }

//   void _disconnect() {
//     manager.disconnect();
//     _showSnackBar("Your device is disconnected.");
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), duration: Duration(seconds: 3)),
//     );
//   }
// }

