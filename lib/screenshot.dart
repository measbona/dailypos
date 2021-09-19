import 'package:flutter/material.dart';

class Screenshot extends StatefulWidget {
  dynamic capturedReceipt;
  Screenshot(this.capturedReceipt);

  @override
  _ScreenshotState createState() => _ScreenshotState();
}

class _ScreenshotState extends State<Screenshot> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screenshot Image'),
      ),

      body: Container(
        child: widget.capturedReceipt != null ? Image.memory(widget.capturedReceipt) : Container(),
      )
    );
  }
}