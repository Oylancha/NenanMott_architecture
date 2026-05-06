// lib/services/database_helper.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('words.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // --- 1. BUMP THE VERSION TO 6 ---
    return await openDatabase(path,
        version: 6, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  // --- 2. UPDATE _createDB WITH *ALL* COLUMNS ---
  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE words ( 
  id TEXT PRIMARY KEY, 
  term TEXT NOT NULL,
  term_latin TEXT,
  russian TEXT NOT NULL,
  english TEXT,
  french TEXT,
  german TEXT,
  turkish TEXT, 
  arabic TEXT,  
  category TEXT,
  exampleSentence TEXT,
  exampleTranslation TEXT,
  audioUrl TEXT,
  imageUrl TEXT,
  exampleAudioUrl TEXT, 
  isCustom INTEGER NOT NULL DEFAULT 0,
  
  -- Progress Fields
  reviewLevel INTEGER NOT NULL DEFAULT 0,
  nextReview TEXT,
  correctCount INTEGER NOT NULL DEFAULT 0,
  incorrectCount INTEGER NOT NULL DEFAULT 0,
  isLearned INTEGER NOT NULL DEFAULT 0,
  state INTEGER NOT NULL DEFAULT 0,
  markedAsKnown INTEGER NOT NULL DEFAULT 0
  )
''');
  }

  // --- 3. onUpgrade IS FOR EXISTING USERS ---
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE words ADD COLUMN exampleAudioUrl TEXT');
        print('Database upgraded to v2: Added exampleAudioUrl column.');
      } catch (e) {
        print('Error upgrading database to v2: $e');
      }
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE words ADD COLUMN english TEXT');
        print('Database upgraded to v3: Added english column.');
      } catch (e) {
        print('Error upgrading database to v3: $e');
      }
    }
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE words ADD COLUMN french TEXT');
        await db.execute('ALTER TABLE words ADD COLUMN german TEXT');
        print('Database upgraded to v4: Added french and german columns.');
      } catch (e) {
        print('Error upgrading database to v4: $e');
      }
    }
    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE words ADD COLUMN term_latin TEXT');
        print('Database upgraded to v5: Added term_latin column.');
      } catch (e) {
        print('Error upgrading database to v5: $e');
      }
    }
    // --- 4. ADD UPGRADE LOGIC FOR v6 ---
    if (oldVersion < 6) {
      try {
        await db.execute('ALTER TABLE words ADD COLUMN turkish TEXT');
        await db.execute('ALTER TABLE words ADD COLUMN arabic TEXT');
        print('Database upgraded to v6: Added turkish and arabic columns.');
      } catch (e) {
        print('Error upgrading database to v6: $e');
      }
    }
  }

  // --- 5. BUMP THE MIGRATION KEY TO v9 TO FORCE RE-LOAD ---
  Future<void> migrateData(AssetBundle rootBundle) async {
    final prefs = await SharedPreferences.getInstance();

    // Use a single, simple migration key
    final bool isMigrated = prefs.getBool('isDatabaseMigrated_v10') ?? false; // <-- BUMPED KEY
    if (isMigrated) {
      print('Database is already migrated. Skipping.');
      return;
    }

    print('Starting database migration...');
    final db = await instance.database;
    final batch = db.batch();

    // 1. Migrate words from the *single* words.json
    try {
      // It now *always* loads words.json
      final String jsonString = await rootBundle.loadString('assets/words.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      for (var entry in jsonData.entries) {
        final word = Word.fromJson(entry.key, entry.value);
        batch.insert('words', word.toDbMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      print('Migrated ${jsonData.length} words from JSON.');
    } catch (e) {
      print('Error migrating words.json: $e');
    }

    // 2. Migrate custom words from SharedPreferences
    try {
      final customWordsJson = prefs.getString('custom_words');
      if (customWordsJson != null) {
        final Map<String, dynamic> customWordsData = json.decode(customWordsJson);
        for (var entry in customWordsData.entries) {
          final word = Word.fromJson(entry.key, entry.value);
          batch.insert('words', word.toDbMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        print('Migrated ${customWordsData.length} custom words.');
      }
    } catch (e) {
      print('Error migrating custom_words: $e');
    }

    // 3. Migrate progress data from SharedPreferences
    try {
      final progressJson = prefs.getString('word_progress');
      if (progressJson != null) {
        final Map<String, dynamic> progressData = json.decode(progressJson);
        for (var entry in progressData.entries) {
          final wordId = entry.key;
          final progress = entry.value as Map<String, dynamic>;
          
          // Convert SharedPreferences progress to DB format
          final dbProgress = {
            'reviewLevel': progress['reviewLevel'] ?? 0,
            'nextReview': progress['nextReview'],
            'correctCount': progress['correctCount'] ?? 0,
            'incorrectCount': progress['incorrectCount'] ?? 0,
            'isLearned': (progress['isLearned'] ?? false) ? 1 : 0,
            'state': progress['state'] ?? 0,
            'markedAsKnown': (progress['markedAsKnown'] ?? false) ? 1 : 0,
          };
          
          batch.update('words', dbProgress, where: 'id = ?', whereArgs: [wordId]);
        }
        print('Migrated progress for ${progressData.length} words.');
      }
    } catch (e) {
      print('Error migrating word_progress: $e');
    }

    // Commit all changes
    await batch.commit();

    // Mark migration as complete
    await prefs.setBool('isDatabaseMigrated_v10', true); // <-- BUMPED KEY
    print('Database migration complete.');
  }

  Future<void> resetProgress(AssetBundle rootBundle) async {
    List<Word> originalWords;

    // It now *always* loads words.json
    try {
      final String jsonString = await rootBundle.loadString('assets/words.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      originalWords = jsonData.entries.map((entry) {
        return Word.fromJson(entry.key, entry.value);
      }).toList();
      print('Successfully loaded ${originalWords.length} words from JSON.');
    } catch (e) {
      print('CRITICAL ERROR: Could not parse assets/words.json: $e');
      print('Database reset aborted. No data was changed.');
      // Re-throw the exception so the provider can catch it.
      throw Exception('Failed to parse words.json. Reset aborted.');
    }

    // 2. If parsing is successful, proceed with the database transaction.
    final db = await instance.database;
    await db.transaction((txn) async {
      // 2a. Clear all existing data
      await txn.delete('words');
      
      // 2b. Insert all the new words
      final batch = txn.batch();
      for (final word in originalWords) {
        batch.insert('words', word.toDbMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit();
    });
    print('Reloaded ${originalWords.length} original words into database.');

    // 3. Clear ALL old SharedPreferences data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isDatabaseMigrated_v10'); // <-- BUMPED KEY
    await prefs.remove('custom_words');
    await prefs.remove('word_progress');

    // 4. Set the migration flag to true so migrateData doesn't run.
    await prefs.setBool('isDatabaseMigrated_v9', true); // <-- BUMPED KEY
    print('Cleared old SharedPreferences and completed reset.');
  }

  Future<Word> create(Word word) async {
    final db = await instance.database;
    await db.insert('words', word.toDbMap());
    return word;
  }

  Future<Word> readWord(String id) async {
    final db = await instance.database;
    final maps = await db.query('words', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Word.fromDb(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Word>> readAllWords() async {
    final db = await instance.database;
    final maps = await db.query('words');
    return maps.map((json) => Word.fromDb(json)).toList();
  }

  Future<int> update(Word word) async {
    final db = await instance.database;
    return db.update(
      'words',
      word.toDbMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  Future<int> updateProgress(Word word) async {
    final db = await instance.database;
    return db.update(
      'words',
      word.toProgressDbMap(), // Only update progress fields
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await instance.database;
    return await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null; // <--- CRITICAL: Reset the static variable
      print('Database closed and reference reset.');
    }
  }
}