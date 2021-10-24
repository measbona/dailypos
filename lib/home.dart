import 'dart:io';

import 'package:dailypos/receipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  dynamic jsonData;

  InAppWebViewController webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
  android: AndroidInAppWebViewOptions(
    useHybridComposition: true,
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Color(0xFF008d4c),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(Platform.isIOS ? 'http://ios.168daily.com/' : 'https://www.168daily.com/')),
        initialOptions: options,
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onConsoleMessage: (controller, consoleMessage) async {
          final androidDefineMessage = 'Uncaught ReferenceError: ok is not defined';
          final isOnAndroidPress = consoleMessage.message.contains(androidDefineMessage);

          if (isOnAndroidPress) {
            final functionName = 'getData';
            final data = await controller.evaluateJavascript(source: '$functionName()');

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Receipt(receiptData: data)),
            );
          }
        },
        onLoadStop: (controller, url) async {
          if (Platform.isIOS) {
            final functionName = 'getData';
            final data = await controller.evaluateJavascript(source: '$functionName()');

            setState(() {
              jsonData = data;
            });
          }
        },
      ),
      floatingActionButton: Platform.isIOS && jsonData != null ? FloatingActionButton(
        child: Icon(Icons.print_rounded),
        backgroundColor: Color(0xFF008d4c),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Receipt(receiptData: jsonData)),
          );
        },
      ) : null,
    );
  }
}