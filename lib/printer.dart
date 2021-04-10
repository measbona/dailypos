import 'package:flutter/material.dart';

class Printer extends StatefulWidget {
  final dynamic receiptData;
  Printer({Key key, @required this.receiptData}) : super(key: key);

  @override
  _PrinterState createState() => _PrinterState();
}

class _PrinterState extends State<Printer> {
  final List<Map<String, dynamic>> data = [
    {
      'title': 'CODE SOFT Bluetooth',
      'code': '33399176-1121-c8f9-14c3-24f2a-17fcbf',
    },
    {
      'title': 'POSX',
      'code': '22288990-2333-c1s1-20c3-24f2a-17fcbf',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff0f2f5),
      appBar: AppBar(
        backgroundColor: Color(0xFF008d4c),
        title: Text('Printer'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh), 
            onPressed: () {}
          ),
          SizedBox(width: 10)
        ],
      ),
      body: buildBody(),
    );
  }

  buildBody() {
    return Container(
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (c, i) {
          return Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            child: ListTile(
              tileColor: Colors.white,
              leading: Icon(Icons.print_rounded),
              title: Text('${data[i]['title']}'),
              subtitle: Text('${data[i]['code']}'),
              onTap: (){
                print(data[i]['title']);
              },
            ),
          );
        },
      ),
    );
  }
}