import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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

  factory SharedDatabase.local() {
    _shareInstance ??= SharedDatabase(_openConnection());
    return _shareInstance!;
  }



}

class UserTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
}
