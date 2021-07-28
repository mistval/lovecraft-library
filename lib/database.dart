import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io' as io;
import 'dart:convert' as convert;

const _DB_FILE_NAME = 'database.json';

io.File _databaseFile;
Map<String, dynamic> _database;
var _writePromise = Future.value();

final Future _loadDatabaseFile = getApplicationDocumentsDirectory().then((dir) {
  var filePath = path.join(dir.path, _DB_FILE_NAME);
  _databaseFile = io.File(filePath);
});

final Future<Map<String, dynamic>> _loadDatabase = _loadDatabaseFile.then((x) async {
  if (!await _databaseFile.exists()) {
    _database = new Map<String, dynamic>();
    return;
  }

  var databaseString = await _databaseFile.readAsString();
  _database = convert.jsonDecode(databaseString);
});

Future init() {
  return _loadDatabase;
}

Future<void> _writeDatabase() async {
  if (_database == null) {
    throw StateError('Database is not loaded!');
  }

  _writePromise = _writePromise.then((x) => _databaseFile.writeAsString(convert.jsonEncode(_database)));
  await _writePromise;
}

dynamic getValueForKey(String key) {
  if (_database == null) {
    throw StateError('Database is not loaded!');
  }

  return _database[key];
}

Future<void> setValueForKey(String key, dynamic value) async {
  if (_database == null) {
    throw StateError('Database is not loaded!');
  }

  _database[key] = value;
  await _writeDatabase();
}
