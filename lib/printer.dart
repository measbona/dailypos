import 'dart:async';
import 'dart:io' show Platform;

import 'package:dailypos/components/utils.dart';
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:image/image.dart' as ImageProcess;
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';

class Printer extends StatefulWidget {
  final dynamic receiptData;
  final dynamic receiptGenerated;

  Printer({Key key, @required this.receiptData, @required this.receiptGenerated}) : super(key: key);

  @override
  _PrinterState createState() => _PrinterState();
}

class _PrinterState extends State<Printer> {
  String message;
  bool isScanning = false;
  bool isPrinting = false;
  bool isPermissionOff = false;
  List<PrinterBluetooth> devices = [];

  BluetoothManager bluetoothManager = BluetoothManager.instance;
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();

  @override
  void initState() {
    validateLocation();
    validateBluetooth();

    super.initState();
  }

  validateLocation() async {
    final status = await Permission.location.status;
    final serviceStatus = await Permission.location.serviceStatus.isDisabled;

    if (!status.isGranted || serviceStatus) Utils.requestLocationAccess(context);
  }

  validateBluetooth() async {
    if (Platform.isAndroid) {
      bluetoothManager.state.listen((val) {
        if (!mounted) return;

        if (val == 12) {
          printerFinder();

          setState(() => isPermissionOff = false );
        } else if (val == 10) {
          setState(() => {
            message = 'Your devices bluetooth is off',
            isPermissionOff = true
          });
        }
      });
    } else {
      printerFinder();
    }
  }

  void printerFinder() {
    setState(() => isScanning = true);

    printerManager.startScan(Duration(seconds: 4));
    printerManager.scanResults.listen((val) {
      if (!mounted) return;

      setState(() => devices = val);

      if (devices.isEmpty) setState(() => { message = 'No nearby POS were found' });
    });

    Timer(Duration(seconds: 4), () => { setState(() { isScanning = false; }) });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Printer'),
        backgroundColor: Color(0xFF008d4c)
      ),
      body: devices.isEmpty ? renderPrinterNotFound() : renderPrinters()
    );
  }

  renderPrinters() {
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (c, i) {
        return ListTile(
          leading: Icon(Icons.print),
          title: Text(devices[i].name),
          subtitle: Text(devices[i].address),
          onTap: isPrinting ? null : () {
            onPrinterSelect(devices[i]);
          },
        );
      },
    );
  }

  renderPrinterNotFound() {
    final buttonColor = isScanning ? Colors.grey[400] : Color(0xFF008d4c);
    final iconColor = isScanning ? Colors.grey[200] : Colors.white;
    final disableAction = isScanning ? null : () {
      if (isPermissionOff) {
        AppSettings.openBluetoothSettings();
      } else {
        printerFinder();
      }
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(isScanning ? 'Scanning.....' : message, style: TextStyle(fontWeight: FontWeight.w500)),
          Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton( icon: Icon(isPermissionOff ? Icons.settings : Icons.refresh, color: iconColor), onPressed: disableAction),
          )
        ],
      ),
    );
  }

  Future<void> onPrinterSelect(PrinterBluetooth printer) async {
    var result;

    setState(() => isPrinting = true);

    printerManager.selectPrinter(printer);

    final receipt = await printReceipt(PaperSize.mm80);

    if (Platform.isIOS) {
      result = await printerManager.printTicket(receipt, chunkSizeBytes: 50);
    } else {
      result = await printerManager.printTicket(receipt, chunkSizeBytes: 256, queueSleepTimeMs: 10);
    }

    setState(() => isPrinting = false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(result.msg),
      ),
    );
  }

  Future<Ticket> printReceipt(PaperSize paper) async {
    final ticket = Ticket(paper);
    final width = MediaQuery.of(context).size.width.floor();

    final image = ImageProcess.decodeImage(widget.receiptGenerated);
    final resizeImage = ImageProcess.copyResize(image, width: width + 190);

    ticket.image(resizeImage);
    ticket.text('Thank you!', styles: PosStyles(align: PosAlign.center, bold: true));
    ticket.cut();

    return ticket;
  }

  @override
  void dispose() {
    printerManager.stopScan();
    super.dispose();
  }
}