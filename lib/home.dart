import 'printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
        initialUrlRequest: URLRequest(url: Uri.parse("https://www.168daily.com/")),
        initialOptions: options,
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onConsoleMessage: (controller, consoleMessage) async {
          final errorMessafe = SnackBar(content: Text('Error somethings'));

          final androidDefineMessage = 'Uncaught ReferenceError: ok is not defined';
          final iosDefineMessage = 'Failed to set the "href" property on "Location"';

          final isOnAndroidPress = consoleMessage.message.contains(androidDefineMessage);
          final isOnIosPress = consoleMessage.message.contains(iosDefineMessage);
          
          if (isOnAndroidPress || isOnIosPress) {
            final functionName = 'getData';
            final data = await controller.evaluateJavascript(source: '$functionName()');

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Printer(receiptData: data)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(errorMessafe);
          }
        },
      ),
    );
  }
}