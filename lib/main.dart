import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Zonnetje"),
        ),
        body: Graphs(),
      ),
    );
  }
}

class Graphs extends StatefulWidget {
  @override
  _GraphsState createState() => _GraphsState();
}

class _GraphsState extends State<Graphs> {
  Future futureDevices;
  String dropdownValue = "dev";
  Future go;
  DateTime date =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  static GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    futureDevices = fetchDevices();
    go = Future.delayed(Duration(seconds: 2), () => true);
  }

  FutureBuilder deviceDropdown() {
    return FutureBuilder(
        future: futureDevices,
        builder: (BuildContext context, snapshot) {
          print(snapshot.data);
          if (snapshot.hasData) {
            List<DropdownMenuItem<String>> items = [];

            var aliases = {"1104DN0518": "6 panels", "1304DP0010": "10 panels"};

            for (String v in snapshot.data) {
              items.add(DropdownMenuItem(
                  value: v, child: Text("$v (${aliases[v]})")));
            }

            if (dropdownValue == "dev") {
              dropdownValue = snapshot.data[0];
            }

            return DropdownButton<String>(
              icon: Icon(Icons.arrow_downward),
              hint: Text("Omvormer"),
              items: items,
              value: dropdownValue,
              onChanged: (String newVal) {
                setState(() {
                  dropdownValue = newVal;
                });
              },
            );
          }
          return Text("Error!");
        });
  }

  FutureBuilder graphImg() {
    double p() {
      double width = MediaQuery.of(context).size.width;
      double height = MediaQuery.of(context).size.height;

      if (width > height) {
        return (1 - height / width) * height;
      }
      return 0.0;
    }

    return FutureBuilder(
      future: futureDevices,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: p()),
              child: Image.network(
                fetchDayReportImg(
                    dropdownValue, date.year, date.month, date.day),
                fit: BoxFit.contain,
              ),
            ),
            IconButton(icon: Icon(Icons.share), onPressed: shareGraph)
          ]);
        }
        return Text("error!");
      },
    );
  }

  Row datePicker(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            icon: Icon(Icons.arrow_left),
            onPressed: () {
              setState(() {
                date = date.subtract(Duration(days: 1));
              });
            }),
        FlatButton(
            onPressed: () => showDayPicker(context),
            child: Text("${date.year}-${date.month}-${date.day}")),
        IconButton(
            icon: Icon(Icons.arrow_right),
            onPressed: () {
              setState(() {
                DateTime today = DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day);
                if (date != today) {
                  date = date.add(Duration(days: 1));
                }
              });
            })
      ],
    );
  }

  Future<void> showDayPicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(2015),
        lastDate: DateTime(2030));

    if (picked != null && picked != date) {
      setState(() {
        date = picked;
      });
    }
  }

  Future<void> shareGraph() async {
    var url = fetchDayReportImg(dropdownValue, date.year, date.month, date.day);
    var resp = await get(url);

    final docDir = (await getExternalStorageDirectory()).path;
    File imgFile = new File('$docDir/$dropdownValue.png');
    imgFile.writeAsBytesSync(resp.bodyBytes);

    Share.shareFiles([imgFile.path], subject: "share graph image");
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ListView(
      children: [
        Column(
          children: [deviceDropdown(), datePicker(context), graphImg()],
        )
      ],
    ));
  }
}
