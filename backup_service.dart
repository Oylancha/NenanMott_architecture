import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_helper.dart';

class BackupService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads the local words.db to Firebase Storage
  Future<void> backupDatabase(String userId) async {
    try {
      // 1. Locate the local database file
      final dbFolder = await getDatabasesPath();
      final file = File(join(dbFolder, 'words.db'));

      if (!await file.exists()) {
        throw Exception("Local database not found!");
      }

      // 2. Create a reference in Firebase Storage
      // Path: users/{userId}/backups/words.db
      final ref = _storage.ref().child('users/$userId/backups/words.db');

      // 3. Upload the file with metadata
      final metadata = SettableMetadata(
        contentType: 'application/x-sqlite3',
        customMetadata: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      await ref.putFile(file, metadata);
      print("Backup successful: ${ref.fullPath}");
    } catch (e) {
      print("Error during backup: $e");
      rethrow; // Let the UI handle the error message
    }
  }

  /// Downloads the backup from Firebase and overwrites the local DB
  Future<void> restoreDatabase(String userId) async {
    try {
      // 1. Create a reference to the backup file
      final ref = _storage.ref().child('users/$userId/backups/words.db');

      // Check if it exists (getMetadata will throw if not found)
      await ref.getMetadata();

      // 2. Close the active database connection!
      await DatabaseHelper.instance.close();

      // 3. Locate the local path
      final dbFolder = await getDatabasesPath();
      final file = File(join(dbFolder, 'words.db'));

      // 4. Download and overwrite
      await ref.writeToFile(file);
      print("Restore successful. Database overwritten.");

    } catch (e) {
      print("Error during restore: $e");
      rethrow;
    }
  }
}