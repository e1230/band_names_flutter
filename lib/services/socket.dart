import 'package:band_names/services/enums.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService with ChangeNotifier {
  // ignore: prefer_final_fields
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;
  SocketService() {
    this._initConfig();
  }
  void _initConfig() {
    this._socket = IO.io('http://localhost:3001', {
      'transports': ['websocket'],
      'autoConnect': true,
    });
    _socket.onConnect((_) {
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
    // socket.on('nuevo-mensaje', (payload) {
    //   print('nuevo mensaje: $payload');
    // });
  }
}
