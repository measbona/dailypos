import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';

class Printer extends StatefulWidget {
  final dynamic receiptData;
  Printer({Key key, @required this.receiptData}) : super(key: key);

  @override
  _PrinterState createState() => _PrinterState();
}

class _PrinterState extends State<Printer> {
  bool isBluetoothOn = true;
  bool isPrinterFound = false;
  bool isScanning = false;

  BluetoothManager bluetoothManager = BluetoothManager.instance;
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      handleBluetoothState();
    } else {
      refindPrinter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF008d4c),
        title: Text('Printer'),
      ),
      body: isBluetoothOn ? renderPrinters() : renderBluetoothOff(),
    );
  }

  void handleBluetoothState() {
    bluetoothManager.state.listen((value) {
      if (value == 10) {
        //off
        setState(() {
          isBluetoothOn = false;
        });
      } else if (value == 12) {
        //on
        setState(() {
          isBluetoothOn = true;
        });

        refindPrinter();
      }
    });
  }

  void refindPrinter() {
    setState(() {
      isScanning = true;
    });

    printerManager.startScan(Duration(seconds: 4));
    printerManager.scanResults.listen((devices) {
      print(devices);  
    });

    Timer(Duration(seconds: 4), () => { setState(() { isScanning = false; }) });
  }

  renderPrinters() {
    return isPrinterFound ? renderAllPrinters() : renderPrinterNotFound();
  }

  renderAllPrinters() {
    return Center(
      child: Text('All Printer'),
    );
  }

  renderBluetoothOff() {
    return Center(
      child: Text('Your devices bluetooth is off', style: TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  renderPrinterNotFound() {
    final buttonColor = isScanning ? Colors.grey[400] : Color(0xFF008d4c);
    final iconColor = isScanning ? Colors.grey[200] : Colors.white;
    final disableAction = isScanning ? null : () { refindPrinter(); };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(isScanning ? 'Scanning.....' : 'No nearby POS were found', style: TextStyle(fontWeight: FontWeight.w500)),
          Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton( icon: Icon(Icons.refresh, color: iconColor ), onPressed: disableAction),
          )
        ],
      ),
    );
  }
}