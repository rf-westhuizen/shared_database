import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<DriftIsolate> createDriftIsolate() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final path = p.join(dbFolder.path, 'shared_db.sqlite');
  final driftIsolate = await DriftIsolate.spawn(() {
    return NativeDatabase(File(path));
  });
  return driftIsolate;
}
