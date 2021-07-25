import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class Printer extends StatefulWidget {
  final dynamic receiptData;

  Printer({Key key, @required this.receiptData}) : super(key: key);

  @override
  _PrinterState createState() => _PrinterState();
}

class _PrinterState extends State<Printer> {
  String logo;
  String pathImage;
  bool isConnected;
  bool isBluetoothOn;
  BluetoothDevice connectedPrinter;
  List<BluetoothDevice> allBluetoothDevices = [];

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  @override
  void initState() {
    super.initState();

    checkBluetoothState();
    getBluetoothState();
    initialLogoPath();
  }

  void checkBluetoothState() async {
    final isBluetoothOff = !await bluetooth.isOn;

    if (isBluetoothOff) {
      requireBluetoothAccess(context);
    }
  }

  void getBluetoothState() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException catch (err) {
      show('First');
    } catch (err) {
      show('Second');
    }

    bluetooth.onStateChanged().listen((state) async {
      if (state == BlueThermalPrinter.STATE_OFF) {
        setState(() { allBluetoothDevices = []; });
        requireBluetoothAccess(context);
      } else if (state == BlueThermalPrinter.STATE_ON) {
        getBluetoothState();
      }
    });

    setState(() {
      allBluetoothDevices = devices;
    });
  }

  void initialLogoPath() async{
    final filename = '168-daily-logo.png';

    var bytes = await rootBundle.load("assets/images/168-daily-logo.png");
    String dir = (await getApplicationDocumentsDirectory()).path;

    writeToFile(bytes,'$dir/$filename');

    setState(() {
      pathImage='$dir/$filename';
    });
  }

  writeToFile(ByteData data, String path) {
    final buffer = data.buffer;

    return new File(path).writeAsBytes(
      buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppbar(),
      body: renderPrinters(),
    );
  }

  renderAppbar() {
    return AppBar(
        backgroundColor: Color(0xFF008d4c),
        title: Text('Printers'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.print),
            onPressed: connectedPrinter != null ? () { onReceiptPrint(); } : null,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () { getBluetoothState(); },
          ),
        ]
    );
  }

  renderPrinters() {
    return ListView.builder(
      itemCount: allBluetoothDevices.length,
      itemBuilder: (BuildContext context, int index) {
        final device = allBluetoothDevices[index];
        final name = device.name;
        final address = device.address;
        final isConnected = connectedPrinter != null ? connectedPrinter.address == device.address : false;

        return ListTile(
          leading: Icon(Icons.bluetooth),
          title: Text(name),
          subtitle: Text(address),
          trailing: isConnected ? Text('Connected') : null,
          onTap: () async {
            if (connectedPrinter == null) { // First time connected
              await onConnect(device);
            } else if (connectedPrinter != null && connectedPrinter.address == device.address) { // Disconnected
              await onDisconnect();
            } else if (connectedPrinter != null && connectedPrinter.address != device.address) { // Has Connected and Connect with another device
              await onDisconnect();
              await onConnect(device);
            }
          },
        );
      }
    );
  }

  Future<void> onConnect(dynamic device) async {
    try {
      showLoading(context);

      bool hasConnected = await bluetooth.isConnected;

      if (!hasConnected) {
        try {
          bool connected = await bluetooth.connect(device);

          if (connected) {
            setState(() { connectedPrinter = device; });
            show('Connected');
          }
        } catch (error) {
          show('Failed to connect device. Please try again');
        }
      } else {
        throw Error;
      }

      Navigator.pop(context);
    } catch (error) {
      show('Error Something');
    }
  }

  Future<void> onDisconnect() {
    bluetooth.disconnect();
    setState(() => connectedPrinter = null);
  }

  void show(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 2),
      content: Text(text)
    ));
  }

  void onReceiptPrint() async {
    final receipt = widget.receiptData;
    final List<dynamic> saleItems = receipt['sales'];

    try {
      bool isConnected = await bluetooth.isConnected;

      if (isConnected) {
        bluetooth.printNewLine();
        bluetooth.printCustom("************************************************", 0, 0);

        bluetooth.printImage(pathImage);
        bluetooth.printNewLine();

        bluetooth.printCustom("Shop\t: ${receipt['name']}", 0, 0);
        bluetooth.printCustom("Phone\t: ${receipt['phone']}", 0, 0);
        bluetooth.printCustom("Sale Date\t: ${receipt['sale_date']}", 0, 0);
        bluetooth.printCustom("Invoice No\t: ${receipt['invoice_no']}", 0, 0);
        bluetooth.printCustom("Customer\t: ${receipt['customer_name']}", 0, 0);
        bluetooth.printCustom("Cus Phone\t: ${receipt['table_name']}", 0, 0);
        bluetooth.printCustom("Address\t: ${receipt['address']}", 0, 0);

        bluetooth.printCustom("----------------------------------------------------", 0, 0);
        bluetooth.printCustom("No°     Name                 Price   Qty   Dis   Amount", 0, 0);
        bluetooth.printCustom("----------------------------------------------------", 0, 0);


        for (var i = 0; i < saleItems.length; i++) {
          final item = saleItems[i];

          bluetooth.printCustom("${item['no']}   ${item['name']}\t${item['price']}     ${item['qty']}     ${item['discount']}\%    \$ ${item['total']}", 0, 0);
          bluetooth.printCustom("----------------------------------------------------", 0, 0);
        }

        bluetooth.printCustom("Subtotal \$ ${receipt['sub_total']}", 0, 2);
        bluetooth.printNewLine();
        bluetooth.printCustom("Delivery ${receipt['delivery']}", 0, 2);
        bluetooth.printNewLine();
        bluetooth.printCustom("Total ${receipt['total']}", 0, 2);
        bluetooth.printNewLine();
        bluetooth.printCustom("Paid ${receipt['paid']}", 0, 2);
        bluetooth.printNewLine();
        bluetooth.printCustom("Receive ${receipt['receive']}", 0, 2);
        bluetooth.printNewLine();
        bluetooth.printCustom("Exchange ${receipt['exchange']}", 0, 2);

        bluetooth.printNewLine();
        bluetooth.printCustom("Thanks you!", 2, 1);
        bluetooth.printCustom("************************************************", 0, 0);

        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();

        bluetooth.paperCut();
      }

      // Disconnect bluetooth device and popback screen
      await onDisconnect();
      Navigator.pop(context);
    } catch (error) {
      show('Error while printing. Please try again');
    }
  }

  requireBluetoothAccess(context) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () { Navigator.pop(context); },
    );

    Widget continueButton = TextButton(
      child: Text("Open Setting"),
      onPressed:  () async {
        await bluetooth.openSettings;
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("168Daily would like to use bluetooth"),
      content: Text("Turn on bluetooth to allow 168Daily access with printer."),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return alert;
      },
    );
  }

  showLoading(context){
    AlertDialog alert = AlertDialog(
      content: Container(
        height: 70,
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF008d4c))),
            SizedBox(height: 10),
            Text('Loadng'),
          ],
        ),
      )
    );

    showDialog(
      context:context,
      barrierDismissible: false,
      builder:(context){
        return alert;
      },
    );
  }
}
