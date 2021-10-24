import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:dailypos/printer.dart';
import 'package:flutter/cupertino.dart';
import 'package:dailypos/widget/widget_to_image.dart';

import 'components/utils.dart';

class Receipt extends StatefulWidget {
  final dynamic receiptData;

  Receipt({Key key, @required this.receiptData}) : super(key: key);
 
  @override
  _ReceiptState createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  GlobalKey captureWidget;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Receipt'),
      backgroundColor: Color(0xFF008d4c),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.print),
          tooltip: 'Show Snackbar',
          onPressed: () async {
            final capturedReceipt = await Utils.capture(captureWidget);

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Printer(receiptData: widget.receiptData, receiptGenerated: capturedReceipt)),
            );
          },
        ),
      ]
    ),
    body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        padding: EdgeInsets.all(20),
        child: WidgetToImage(
          builder: (key) {
            this.captureWidget = key;

            return Column(
              children: <Widget>[
                _renderReceiptInfo(),
                _renderTable(),
                _renderBottom(),
              ]
            );
          }
        )
      ),
    )
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
      ': ${widget.receiptData['name']}',
      ': ${widget.receiptData['phone']}',
      ': ${widget.receiptData['sale_date']}',
      ': ${widget.receiptData['invoice_no']}',
      ': ${widget.receiptData['customer_name']}',
      ': ${widget.receiptData['table_name']}',
      ': ${widget.receiptData['address']}'
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
            child: Image.network(widget.receiptData['logo'], width: 60, height: 60),
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
    final List<dynamic> saleItems = widget.receiptData['sales'];

    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 20),
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
          for (var i = 0; i < saleItems.length; i++) _renderItem(saleItems[i])
        ],
      ),
    );
  }

  _renderItem(dynamic saleItems) {
    final formatCurrency = new NumberFormat.decimalPattern();

    final items = [
      saleItems['no'],
      saleItems['name'],
      formatCurrency.format(double.parse(saleItems['price'])).toString(),
      saleItems['qty'],
      '${saleItems['discount']}%',
      formatCurrency.format(double.parse(saleItems['total'])).toString(),
    ];

    return TableRow(
      children: [
        for (var i = 0; i < items.length; i++) Utils.tableCell(items[i])
      ],
    );
  }

  _renderBottom() {
    final formatCurrency = new NumberFormat.decimalPattern();

    final titles = [
      'Subtotal',
      'Delivery',
      'Total',
      'Paid',
      'Currency',
      'Receive',
      'Exchange',
    ];
    final seperator = [
      '\$',
      '\$',
      '\$',
      '?',
      '\$',
      '\$',
      '\$',
    ];
    final values = [
      widget.receiptData['sub_total'],
      widget.receiptData['delivery'],
      widget.receiptData['total'],
      widget.receiptData['paid'],
      widget.receiptData['currency'],
      widget.receiptData['receive'],
      widget.receiptData['exchange'],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(right: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
            Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0 ; i < titles.length; i++) Utils.summaryText(text: titles[i]),
                  ],
                ),
                Column(
                  children: [
                    for (var i = 0 ; i < seperator.length; i++) Utils.summaryText(text: seperator[i]),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0 ; i < values.length; i++) Utils.summaryText(text: values[i], removeDollarSign: true),
                  ],
                )
              ],
            ),
           ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
