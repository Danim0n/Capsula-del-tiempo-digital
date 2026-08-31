import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

QueryExecutor openPlatformConnection() => DatabaseConnection.delayed(
  Future(() async {
    final database = await WasmDatabase.open(
      databaseName: 'capsula_del_tiempo_digital',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return database.resolvedExecutor;
  }),
);
