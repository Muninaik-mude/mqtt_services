// import 'package:flutter/cupertino.dart';

// enum MQTTAppConnectionState { connected, disconnected, connecting }
// class MQTTAppState with ChangeNotifier{
//   MQTTAppConnectionState _appConnectionState = MQTTAppConnectionState.disconnected;
//   String _receivedText = '';
//   String _historyText = '';

//   void setReceivedText(String text) {
//     _receivedText = text;
//     _historyText = _historyText + '\n' + _receivedText;
//     notifyListeners();
//   }
//   void setAppConnectionState(MQTTAppConnectionState state) {
//     _appConnectionState = state;
//     notifyListeners();
//   }

//   String get getReceivedText => _receivedText;
//   String get getHistoryText => _historyText;
//   MQTTAppConnectionState get getAppConnectionState => _appConnectionState;

//   void setConnectionState(MQTTAppConnectionState disconnected) {}

//   void addReceivedMessage(String payload) {}

// }
//another code

import 'package:flutter/cupertino.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTAppState with ChangeNotifier {
  MQTTAppConnectionState _appConnectionState = MQTTAppConnectionState.disconnected;
  String _receivedText = '';
  String _historyText = '';
  String _disconnectNotification = '';  
  void setReceivedText(String text) {
    _receivedText = text;
    _historyText = '$_historyText\n$_receivedText';
    notifyListeners();
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  void setDisconnectNotification(String message) {
    _disconnectNotification = message;
    notifyListeners();
  }

  void clearDisconnectNotification() {
    _disconnectNotification = '';
    notifyListeners();
  }

  String get getReceivedText => _receivedText;
  String get getHistoryText => _historyText;
  String get disconnectNotification => _disconnectNotification; 
  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;
}

