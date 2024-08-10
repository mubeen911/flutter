import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:path/path.dart' show join;

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentDirectory implements Exception {}

class DatabaseIsNotOpen implements Exception {}

class CouldNotDeleteUser implements Exception {}

class UserAlreadyExists implements Exception {}

class CouldNotFindUser implements Exception {}

class NotesServices {
  Database? _db;

Future <void> deleteNote({required int id})
{
  final db= _getDatabaseorThrow();
  final deleteCount=db.delete(noteTable,limit:1, where: 'id = ?', whereArgs: [id],)
}

  Future<DatabaseNotes> createNotes({required DatabaseUser owner}) async {
    final db = _getDatabaseorThrow();

    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      CouldNotFindUser();
    }
    const text = "";
    final noteId = await db.insert(
        noteTable, {colUserId: owner.id, colText: text, colIsSyncWithCloud: 1});

    return DatabaseNotes(
        id: noteId, userId: owner.id, text: text, issyncwithcloud: true);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseorThrow();

    final result = await db.query(userTable,
        limit: 1, where: 'email=?', whereArgs: [email.toLowerCase()]);
    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseorThrow();
    final result = await db.query(userTable,
        limit: 1, where: 'email=?', whereArgs: [email.toLowerCase()]);
    if (result.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {colEmail: email.toLowerCase()});
    return DatabaseUser(id: userId, email: email);
  }

  Database _getDatabaseorThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
// creating table of user

      await db.execute(createUserTable);
// create table of notes

      await db.execute(createTableNotes);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseorThrow();
    final deletedcount = await db
        .delete(userTable, where: 'email=?', whereArgs: [email.toLowerCase()]);
    if (deletedcount != 1) {
      throw CouldNotDeleteUser();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[colID] as int,
        email = map[colEmail] as String;
  @override
  String toString() => 'Person,id=$id, email=$email';
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;
  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNotes {
  final int id;
  final int userId;
  final String text;
  final bool issyncwithcloud;
  @immutable
  const DatabaseNotes(
      {required this.id,
      required this.userId,
      required this.text,
      required this.issyncwithcloud});
  DatabaseNotes.fromRow(Map<String, Object> map)
      : id = map[colID] as int,
        userId = map[colUserId] as int,
        issyncwithcloud = map[colIsSyncWithCloud] as int == 1 ? true : false,
        text = map[colText] as String;

  @override
  String toString() =>
      'Notes, ID=$id, userId=$userId,issyncwithcloud=$issyncwithcloud,text=$text';
  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;
  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const colID = 'id';
const colEmail = 'email';
const colUserId = 'user_id';
const colText = 'text';
const colIsSyncWithCloud = 'is_sync_with_cloud';
const createUserTable = '''
              CREATE TABLE IF NOT EXISTS "user" (
	            "id"	INTEGER NOT NULL,
	            "email"	TEXT NOT NULL UNIQUE,
	           PRIMARY KEY("id" AUTOINCREMENT)
                );''';
const createTableNotes = ''' CREATE TABLE "notes" (
	        "id"	INTEGER NOT NULL,
	        "user_id"	INTEGER NOT NULL,
	        "text"	TEXT,
	         "is_sync_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	         PRIMARY KEY("id" AUTOINCREMENT),
	         FOREIGN KEY("user_id") REFERENCES "user"("id")
          );''';
const userTable = 'user';
const noteTable = 'notes';
