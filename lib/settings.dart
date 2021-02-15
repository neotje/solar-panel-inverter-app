import 'package:flutter/cupertino.dart';

import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter/widgets.dart';

class AppSettings {
  final List<Alias> aliases;

  AppSettings({this.aliases});
}

class Alias {
  final String device;
  final String name;

  Alias({this.device, this.name});
}

class SettingsManager {
  Future<Database> database;

  Future<void> init() async {
    database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'zonnetje_database.db'),
    );
  }
}
