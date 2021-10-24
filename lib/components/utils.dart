import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:app_settings/app_settings.dart';

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

  static summaryText({String text, bool removeDollarSign = false}) {
    var stringText = '';
    var textValue = text == null ? '0' : text;
    bool hasDollarSign = textValue.contains('\$');

    stringText = hasDollarSign && removeDollarSign ? textValue.split('\$')[1] : textValue;

    return Column(
      children: [
        Container(child: Text(stringText + ' ', style: TextStyle(fontWeight: FontWeight.bold))),
        SizedBox(height: 10),
      ],
    );
  }

  static requestLocationAccess(context) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () { Navigator.pop(context); },
    );

    Widget continueButton = TextButton(
      child: Text("Open Setting"),
      onPressed:  () async {
        await AppSettings.openLocationSettings();

        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("168Daily would like to use your location to find nearby printer"),
      content: Text("Turn on location to allow 168Daily access with printer."),
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
}
