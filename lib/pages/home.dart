import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/enums.dart';
import 'package:band_names/services/socket.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(id: '1', name: 'metallica', votes: 5),
    // Band(id: '2', name: 'lisa', votes: 25),
    // Band(id: '3', name: 'bon jovi', votes: 10),
    // Band(id: '4', name: 'mago de oz', votes: 8),
    // Band(id: '5', name: 'SOAD', votes: 9)
  ];
  @override
  void initState() {
    super.initState();
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Band Names',
          style: TextStyle(color: Colors.black87),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.Online
                ? Icon(
                    Icons.check_circle,
                    color: Colors.blue[300],
                  )
                : socketService.serverStatus == ServerStatus.Offline
                    ? Icon(
                        Icons.offline_bolt,
                        color: Colors.red,
                      )
                    : Icon(
                        Icons.change_circle_outlined,
                        color: Colors.yellow,
                      ),
          )
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) =>
                  _bandTile(bands[index]),
              itemCount: bands.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: addNewBand,
        elevation: 1,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      direction: DismissDirection.startToEnd,
      onDismissed: ((_) {
        socketService.socket.emit('delete-band', {'id': band.id});
      }),
      background: Container(
        padding: EdgeInsets.only(left: 8),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete Band',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      key: Key(band.id),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () {
          socketService.socket.emit('vote-band', {'id': band.id});
        },
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('New Band Name'),
              content: TextField(
                controller: textController,
              ),
              actions: [
                MaterialButton(
                    child: Text(
                      'Add',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    elevation: 5,
                    textColor: Colors.blue,
                    onPressed: () => addBandToList(textController.text))
              ],
            );
          });
    }
    showCupertinoDialog(
        context: context,
        builder: ((context) {
          return CupertinoAlertDialog(
            title: Text('New Band Name'),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: [
              CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(
                    'Add',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => addBandToList(textController.text)),
              CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text(
                    'Dismiss',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => Navigator.pop(context))
            ],
          );
        }));
  }

  void addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (name.length > 1) {
      socketService.socket.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

  PieChart _showGraph() {
    Map<String, double> dataMap = new Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });
    return PieChart(dataMap: dataMap);
  }
}
