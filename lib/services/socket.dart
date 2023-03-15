import 'package:band_names/services/enums.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService with ChangeNotifier {
  // ignore: prefer_final_fields
  ServerStatus _serverStatus = ServerStatus.Connecting;

  SocketService() {
    this._initConfig();
  }
  void _initConfig() {
    IO.Socket socket = IO.io('http://localhost:3001', {
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket.onConnect((_) {
      print('connect');
    });

    socket.onDisconnect((_) => print('disconnect'));
  }
}
