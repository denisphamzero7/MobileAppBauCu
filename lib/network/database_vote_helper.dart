// database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/vote_info.dart';


// 2. Database Helper (Đã cập nhật cho VoterInfo)
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'voter.db'); // <-- Đổi tên DB
    return await openDatabase(
      path,
      version: 1, // <-- Bắt đầu với version 1 cho schema mới
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Tạo bảng 'voters' mới dựa trên model VoterInfo
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE voters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT,
        dob TEXT,
        sex TEXT,
        placeOfResidence TEXT,
        citizenIdNumber TEXT, 
        issuingAuthority TEXT,
        voterCardNumber TEXT,
        pollingAreaNumber TEXT,
        ward TEXT,
        city TEXT,
        hasVoted INTEGER DEFAULT 0
      )
    ''');
  }

  // Hàm onUpgrade đơn giản (xóa bảng cũ, tạo bảng mới)
  // HỮU ÍCH KHI THAY ĐỔI SCHEMA HOÀN TOÀN
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute("DROP TABLE IF EXISTS voters");
    // Nếu bạn có bảng 'citizens' cũ, cũng nên xóa nó
    await db.execute("DROP TABLE IF EXISTS citizens");
    await _onCreate(db, newVersion);
  }

  // Hàm để lưu thông tin cử tri
  Future<void> insertVoter(VoterInfo voter) async {
    final db = await database;
    await db.insert(
      'voters', // <-- Đổi tên bảng
      voter.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Hàm để lấy tất cả thông tin cử tri
  Future<List<VoterInfo>> getVoters() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('voters'); // <-- Đổi tên bảng

    return List.generate(maps.length, (i) {
      return VoterInfo.fromMap(maps[i]); // <-- Dùng VoterInfo.fromMap
    });
  }

  // Hàm lấy cử tri bằng số Căn cước công dân
  Future<VoterInfo?> getVoterByCCCD(String cccd) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'voters', // <-- Đổi tên bảng
      where: 'citizenIdNumber = ?', // <-- Đổi tên cột
      whereArgs: [cccd],
    );

    if (maps.isNotEmpty) {
      return VoterInfo.fromMap(maps.first); // <-- Dùng VoterInfo.fromMap
    }
    return null;
  }

  // Hàm đánh dấu cử tri đã bầu cử
  Future<void> markVoterAsVoted(String cccd) async {
    final db = await database;
    await db.update(
      'voters', // <-- Đổi tên bảng
      {'hasVoted': 1},
      where: 'citizenIdNumber = ?', // <-- Đổi tên cột
      whereArgs: [cccd],
    );
  }
}