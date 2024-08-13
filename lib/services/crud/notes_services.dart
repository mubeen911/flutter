import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:notes/services/crud/crud_exception.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:path/path.dart' show join;

class NotesServices {
  Database? _db;
  List<DatabaseNotes> _notes = [];
  static final _shared = NotesServices._sharedInstance();
  NotesServices._sharedInstance();
  factory NotesServices() => _shared;
  final _notesStreamController =
      StreamController<List<DatabaseNotes>>.broadcast();
  Stream<List<DatabaseNotes>> get allNotes => _notesStreamController.stream;

  Future<void> _cacheNotes() async {
    final notes = await getAllNotes();
    _notes = notes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseUser> getorcreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (_) {
      rethrow;
    }
  }

  Future<DatabaseNotes> updateNotes(
      {required DatabaseNotes note, required String text}) async {
    await _ensuredbIsOpen();
    final db = _getDatabaseorThrow();

    await getNotes(id: note.id);
    final updateCount = await db.update(noteTable, {
      colText: text,
      colIsSyncWithCloud: 0,
    });
    if (updateCount == 0) {
      throw CouldNotUpdateNotes;
    } else {
      final updateNote = await getNotes(id: note.id);
      _notes.removeWhere((notes) => note.id == updateNote.id);
      _notes.add(updateNote);
      _notesStreamController.add(_notes);
      return updateNote;
    }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    await _ensuredbIsOpen();
    final db = _getDatabaseorThrow();
    final notes = await db.query(noteTable);

    return notes.map((noteRow) => DatabaseNotes.fromRow(noteRow));
  }

  Future<DatabaseNotes> getNotes({required int id}) async {
    await _ensuredbIsOpen();
    final db = _getDatabaseorThrow();
    final result =
        await db.query(noteTable, limit: 1, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) {
      throw CouldNotFindNotes();
    } else {
      final note = DatabaseNotes.fromRow(result.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensuredbIsOpen();
    final db = _getDatabaseorThrow();
    final numberofDeleltions = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberofDeleltions;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensuredbIsOpen();
    final db = _getDatabaseorThrow();
    final deleteCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNotes> createNotes({required DatabaseUser owner}) async {
    await _ensuredbIsOpen();
    final db = _getDatabaseorThrow();

    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      CouldNotFindUser();
    }
    const text = "";
    final noteId = await db.insert(
        noteTable, {colUserId: owner.id, colText: text, colIsSyncWithCloud: 1});

    final note = DatabaseNotes(
        id: noteId, userId: owner.id, text: text, issyncwithcloud: true);
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensuredbIsOpen();
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
    await _ensuredbIsOpen();
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

  Future<void> _ensuredbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {}
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
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }

  Future<void> deleteUser({required String email}) async {
    await _ensuredbIsOpen();
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
  DatabaseNotes.fromRow(Map<String, Object?> map)
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
