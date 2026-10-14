import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database.dart';

Future<File> fileDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  return File(p.join(dir.path, 'auri.sqlite'));
}

Future<AuriDb> apriDatabase() async => AuriDb(NativeDatabase.createInBackground(await fileDatabase()));
