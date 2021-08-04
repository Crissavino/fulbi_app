import 'dart:io';

import 'package:fulbito_app/models/match.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static Database? _database;
  static final DBService db = DBService._();
  DBService._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  Future<Database> initDB() async {

    // path donde va la db
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    final path = join(documentsDirectory.path, 'FulbitoDB.db');
    print(path);

    // crear db
    // incrementar version de db cuando se cambie la estructura

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE Matches(
            id INTEGER,
            location_id INTEGER,
            when_play TEXT,
            genre_id INTEGER,
            type_id INTEGER,
            num_players INTEGER,
            cost REAL,
            chat_id INTEGER,
            owner_id INTEGER,
            currency_id INTEGER,
            is_free_match INTEGER,
            is_confirmed INTEGER,
            have_notifications INTEGER,
            participants TEXT,
            deleted_at TEXT,
            created_at TEXT,
            updated_at TEXT
          );
        ''');
      },
    );
  }

  Future<int?> insertNewMatch(Match newMatch) async {
    final db = await database;
    Match? match = await getMatch(newMatch.id);
    if (match == null) {
      final res = await db!.insert('Matches', newMatch.toJsonForSQFLite());
      return res;
    }
    return null;

  }

  Future<Match?> getMatch(int matchId) async {
    final db = await database;
    final res = await db!.query('Matches', where: 'id = ?', whereArgs: [
      matchId
    ]);
    print(res.isNotEmpty ? res.first : null);
    return res.isNotEmpty ? Match.fromJsonForSQFLite(res.first) : null;
  }
}