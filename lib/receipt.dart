import 'dart:typed_data';

import 'package:dailypos/screenshot.dart';
import 'package:dailypos/widget/widget_to_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'components/utils.dart';

class Receipt extends StatefulWidget {
  final String title;

  const Receipt({
    @required this.title,
  });
 
  @override
  _ReceiptState createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  GlobalKey captureWidget;
  dynamic receiptJson = {
    "shop_type":"02",
    "printer_type":"80mm",
    "name":"បូណា",
    "phone":"+85570333170",
    "invoice_no":"18_1602",
    "sale_date":"09/19/2021",
    "customer_name":"none",
    "table_name":"none",
    "address":"none",
    "sub_total":"13.50",
    "delivery":"\$ 0",
    "total":"\$ 13.50",
    "paid":"Yes",
    "currency":"USD",
    "receive":"\$ 15",
    "exchange":"\$ 1.50",
    "cur_sign":"\$",
    "logo":"https://www.168daily.com/public/logo/1610336885.png",
    "sales":[
        {
          "no":"1",
          "name":"Khmer Food",
          "price":"15",
          "qty":"1",
          "discount":"10",
          "total":"13.50"
        },
        {
          "no":"2",
          "name":"ម្ហូបខ្មែរ",
          "price":"15",
          "qty":"2",
          "discount":"0",
          "total":"16.50"
        }
    ]
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Receipt'),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.screen_share_outlined),
          tooltip: 'Show Snackbar',
          onPressed: () async {
            final capturedReceipt = await Utils.capture(captureWidget);

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Screenshot(capturedReceipt)),
            );
          },
        ),
      ]
    ),

    body: Container(
      padding: EdgeInsets.all(20),
      child: WidgetToImage(
        builder: (key) {
          this.captureWidget = key;

          return Column(
            children: <Widget>[
              _renderReceiptInfo(),
              _renderTable(),
            ]
          );
        }
      )
    ),
  );

  _renderInfo() {
    final titles = [
      'Shop',
      'Phone',
      'Sale Date',
      'Invoice Nº',
      'Customer',
      'Cus Phone',
      'Address',
    ];
    final values = [
      ': ${receiptJson['name']}',
      ': ${receiptJson['phone']}',
      ': ${receiptJson['sale_date']}',
      ': ${receiptJson['invoice_no']}',
      ': ${receiptJson['customer_name']}',
      ': ${receiptJson['table_name']}',
      ': ${receiptJson['address']}'
    ];

    return Container(
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < titles.length ; i++) Utils.text(titles[i]),
            ],
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < values.length ; i++) Utils.text(values[i]),
            ],
          ),
        ],
      ),
    );
  }

  _renderReceiptInfo() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _renderInfo(),

          Container(
            margin: EdgeInsets.only(right: 30, bottom: 125),
            child: Image.network(receiptJson['logo'], width: 60, height: 60),
          ),
        ],
      ),
    );
  }

  _renderTable() {
    final width = MediaQuery.of(context).size.width.floor();
    final headers = [
      'No',
      'Name',
      'Price',
      'Qty',
      'Dis',
      'Amount',
    ];
    final List<dynamic> saleItems = receiptJson['sales'];

    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      child: Table(
        border: TableBorder(
          top: BorderSide(width: 2, style: BorderStyle.solid),
          bottom: BorderSide(width: 2, style: BorderStyle.solid),
          horizontalInside: BorderSide(width: 2, style: BorderStyle.solid)
        ),
        columnWidths: {
          0: FixedColumnWidth(width / 18),
          1: FixedColumnWidth(width / 3),
          2: FixedColumnWidth(width / 10),
          3: FixedColumnWidth(width / 10),
          4: FixedColumnWidth(width / 10),
          5: FixedColumnWidth(width / 5),
        },
        children: [
          TableRow(
            children: [
              for (var i = 0; i < headers.length; i++) Utils.tableCell(headers[i])
            ]
          ),
          // list all item row
          for (var i = 0; i < saleItems.length; i++) _renderItem(saleItems[i])
        ],
      ),
    );
  }

  _renderItem(dynamic saleItems) {
    final items = [
      saleItems['no'],
      saleItems['name'],
      saleItems['price'],
      saleItems['qty'],
      saleItems['discount'],
      saleItems['total']
    ];

    return TableRow(
      children: [
        for (var i = 0; i < items.length; i++) Utils.tableCell(items[i])
      ],
    );
  }
}