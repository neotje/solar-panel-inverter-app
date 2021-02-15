import 'dart:convert';

import 'package:http/http.dart' as http;

String host = "192.168.111.31:9124";

class DayReportRow {
  final double output;
  final int time;

  DayReportRow({this.time, this.output});
}

List<DayReportRow> dayReportFromJson(Map<String, dynamic> json) {
  List<DayReportRow> arr = [];
  print(json["report"].length);
  for (var r in json["report"]) {
    arr.add(DayReportRow(time: r['time'], output: r['PAC']));
  }

  return arr;
}

Future<List<DayReportRow>> fetchDayReport(
    String device, int year, int month, int day) async {
  final response = await http
      .get(Uri.http(host, "get/${device}/report/${year}/${month}/${day}"));

  if (response.statusCode == 200) {
    return dayReportFromJson(jsonDecode(response.body));
  }
  return [];
}

String fetchDayReportImg(String device, int year, int month, int day) {
  return Uri.http(host, "get/${device}/graph_img/${year}/${month}/${day}")
      .toString();
}

Future fetchDevices() async {
  final response = await http.get(Uri.http(host, "get/devices"));

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['devices'];
  }
  return [];
}
