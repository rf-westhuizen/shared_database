import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../shared_database.dart';

part 'shared_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'shared_db.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(tables: [UserTable])
class SharedDatabase extends _$SharedDatabase {
  SharedDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  // Singleton instance
  static SharedDatabase? _shareInstance;
  static DriftIsolate? _driftIsolate;

  factory SharedDatabase.local() {
    _shareInstance ??= SharedDatabase(_openConnection());
    return _shareInstance!;
  }

  static Future<SharedDatabase> getInstance() async {
    if (_shareInstance == null) {
      // Check if the drift isolate is already registered
      final sendPort = IsolateNameServer.lookupPortByName('drift_isolate');
      if (sendPort == null) {
        // Create and register the isolate if not found
        final driftIsolate = await createDriftIsolate();
        _driftIsolate = driftIsolate;
        IsolateNameServer.registerPortWithName(driftIsolate.connectPort, 'drift_isolate');
        _shareInstance = SharedDatabase(await driftIsolate.connect());
      } else {
        // Connect to the existing isolate
        final driftIsolate = DriftIsolate.fromConnectPort(sendPort);
        _driftIsolate = driftIsolate;
        _shareInstance = SharedDatabase(await driftIsolate.connect());
      }
    }
    return _shareInstance!;
  }



}

class UserTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
}
