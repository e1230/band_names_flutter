import 'package:band_names/services/socket.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    // socketService.socket.emit('nuevo-mensaje',
    //     {'nombre': 'flutter', 'mensaje': 'mensaje desde flutter'});
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('server status: ${socketService.serverStatus}')],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          socketService.socket.emit('nuevo-mensaje',
              {'nombre': 'flutter', 'mensaje': 'mensaje desde flutter'});
        },
        child: Icon(Icons.message),
      ),
    );
  }
}
