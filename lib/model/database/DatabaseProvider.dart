import 'dart:async';

import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static final _databaseName = "Erzmobil.db";
  static final _databaseVersion = 3;

  static final table = 'user';

  static final columnId = '_id';
  static final columnName = 'name';
  static final columnFirstName = 'firstname';
  static final columnMail = 'email';
  static final columnPhone = 'phone';
  static final columnAddress = 'address';
  static final columnIsActive = 'isactive';
  static final columnFinishedTourIndex = 'finishedtourindex';
  static final columnActiveTourId = 'activetourid';

  static final columnRegisteredVersions = 'versions';

  static Database? _database;

  static final DatabaseProvider _instance = new DatabaseProvider._internal();

  factory DatabaseProvider() {
    return _instance;
  }

  DatabaseProvider._internal();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnMail TEXT NOT NULL,
            $columnName TEXT,
            $columnFirstName TEXT,
            $columnAddress TEXT,
            $columnPhone TEXT,
            $columnRegisteredVersions TEXT,
            $columnIsActive INTEGER, 
            $columnActiveTourId INTEGER,
            $columnFinishedTourIndex INTEGER
          )
          ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    int version = oldVersion;
    if (version < 2) {
      await db.execute('''
            ALTER TABLE $table ADD COLUMN $columnRegisteredVersions TEXT
            ''');
      ++version;
    }
    if (version < 3) {
      await db.execute('''
            ALTER TABLE $table ADD COLUMN $columnIsActive INTEGER
            ''');
      await db.execute('''
            ALTER TABLE $table ADD COLUMN $columnActiveTourId INTEGER
            ''');
      await db.execute('''
            ALTER TABLE $table ADD COLUMN $columnFinishedTourIndex INTEGER
            ''');
      ++version;
    }
  }

  Future<User?> getUser(String mail) async {
    Database? db = await _instance.database;
    List<Map> maps = await db!.query(table,
        columns: [
          columnId,
          columnName,
          columnFirstName,
          columnAddress,
          columnPhone,
          columnMail,
          columnRegisteredVersions,
          columnActiveTourId,
          columnFinishedTourIndex,
          columnIsActive
        ],
        where: '$columnMail = ?',
        whereArgs: [mail]);

    if (maps.length > 0) {
      Logger.info("loaded stored user, user list ${maps.length}");
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getActiveUser() async {
    Database? db = await _instance.database;
    List<Map> maps = await db!.query(table,
        columns: [
          columnId,
          columnName,
          columnFirstName,
          columnAddress,
          columnPhone,
          columnMail,
          columnRegisteredVersions,
          columnIsActive,
          columnActiveTourId,
          columnFinishedTourIndex,
        ],
        where: '$columnIsActive = ?',
        whereArgs: [1]);

    if (maps.length > 0) {
      Logger.info("loaded active user");
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insert(User user) async {
    Database? db = await _instance.database;
    return await db!.insert(table, user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(User user) async {
    Database? db = await _instance.database;
    return await db!.update(table, user.toMap(),
        where: '$columnId = ?', whereArgs: [user.id]);
  }

  Future<int> delete(User user) async {
    Database? db = await _instance.database;
    return await db!
        .delete(table, where: '$columnId = ?', whereArgs: [user.id]);
  }
}
