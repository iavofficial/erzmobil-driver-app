/**
 * Copyright © 2025 IAV GmbH Ingenieurgesellschaft Auto und Verkehr, All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
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
  static final columnLastActiveBusId = 'lastactivebusid';

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
            $columnFinishedTourIndex INTEGER,
            $columnLastActiveBusId INTEGER
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
    if (version < 4) {
      await db.execute('''
            ALTER TABLE $table ADD COLUMN $columnLastActiveBusId INTEGER
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
          columnIsActive,
          columnLastActiveBusId
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
          columnLastActiveBusId
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
