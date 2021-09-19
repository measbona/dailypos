import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

class Utils {
  static Future capture(GlobalKey key) async {
    if (key == null) return null;

    RenderRepaintBoundary boundary = key.currentContext.findRenderObject();

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData.buffer.asUint8List();

    return pngBytes;
  }

  static text(String text) {
    return Column(
      children: [
        Text(text, style: TextStyle(height: 1, fontWeight: FontWeight.bold)),
        SizedBox(height: 10)
      ]
    );
  }

  static tableCell(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
      )
    );
  }
}
