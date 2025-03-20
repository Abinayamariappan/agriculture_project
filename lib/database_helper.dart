import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('agriconnect.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // ✅ Farmers Table
    await db.execute('''
      CREATE TABLE farmers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL UNIQUE
      )
    ''');

    // ✅ Products Table (Crops, Seeds, Fertilizers)
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        farmer_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL,  
        price REAL NOT NULL,
        min_kg REAL NOT NULL,
        total_kg REAL NOT NULL,
        description TEXT NOT NULL,
        image TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE
      )
    ''');

    // ✅ Pesticides Table
    await db.execute('''
      CREATE TABLE pesticides (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        farmer_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        location TEXT NOT NULL,
        spraying_area REAL NOT NULL,
        description TEXT NOT NULL,
        image TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE
      )
    ''');

    // ✅ Drip Irrigation Table
    await db.execute('''
       CREATE TABLE drip_irrigation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        farmer_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        water_source TEXT NOT NULL,
        land_area REAL NOT NULL,
        location TEXT NOT NULL,
        description TEXT NOT NULL,
        image TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE
      )
    ''');

    // ✅ Farmland Table
    await db.execute('''
      CREATE TABLE farmland (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        farmer_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        size REAL NOT NULL,
        location TEXT NOT NULL,
        description TEXT NOT NULL,
        image TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE
      )
    ''');
  }

  // ✅ Register Farmer
  Future<int> registerFarmer({required String name, required String phone}) async {
    final db = await instance.database;
    int farmerId = await db.insert('farmers', {'name': name.trim(), 'phone': phone.trim()});
    print("Farmer Registered with ID: $farmerId");
    return farmerId;
  }

  Future<String?> getLoggedInUserPhone() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
        'users',
        columns: ['phone'],
        where: 'is_logged_in = ?',
        whereArgs: [1]
    );
    return result.isNotEmpty ? result.first['phone'] as String : null;
  }

  // ✅ Get Farmer by Phone (Fix: Return Full Farmer Data)
  Future<Map<String, dynamic>?> getFarmerByPhone(String phone) async {
    final db = await database;
    final result = await db.query(
      'farmers',
      where: 'phone = ?',
      whereArgs: [phone],
    );
    if (result.isNotEmpty) {
      return {
        'id': result.first['id'] as int? ?? 0, // Ensure id is int
        'name': result.first['name'] ?? "Unknown",
        'phone': result.first['phone'] ?? "Not Available",
      };
    }
    return null;
  }


  // ✅ Get Farmer by ID
  Future<Map<String, dynamic>?> getFarmerById(int id) async {
    final db = await instance.database;
    final result = await db.query('farmers', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  // ✅ Get Products by Farmer ID
  Future<List<Map<String, dynamic>>> getProductsByFarmer(int farmerId) async {
    final db = await instance.database;
    return await db.query('products', where: 'farmer_id = ?', whereArgs: [farmerId]);
  }

  // ✅ Insert Product (Crop/Seed/Fertilizer)
  Future<int> insertProduct({
    required int farmerId,
    required String name,
    required String category,
    required double price,
    required double minKg,
    required double totalKg,
    required String description,
    required String image,
    required String status,
  }) async {
    final db = await instance.database;
    return await db.insert('products', {
      'farmer_id': farmerId,
      'name': name,
      'category': category,
      'price': price,
      'min_kg': minKg,
      'total_kg': totalKg,
      'description': description,
      'image': image,
      'status': status,
    });
  }

  // ✅ Insert Pesticide
  Future<int> insertPesticide({
    required int farmerId,
    required String type,
    required String location,
    required double sprayingArea,
    required String description,
    required String image,
    required String status,
  }) async {
    final db = await instance.database;
    return await db.insert('pesticides', {
      'farmer_id': farmerId,
      'type': type,
      'location': location,
      'spraying_area': sprayingArea,
      'description': description,
      'image': image,
      'status': status,
    });
  }

  // ✅ Insert Drip Irrigation
  Future<int> insertDripIrrigation({
    required int farmerId,
    required String type,
    required String waterSource,
    required double landArea,
    required String location,
    required String description,
    required String image,
    required String status,
  }) async {
    final db = await instance.database;
    return await db.insert('drip_irrigation', {
      'farmer_id': farmerId,
      'type': type,
      'water_source': waterSource,
      'land_area': landArea,
      'location': location,
      'description': description,
      'image': image,
      'status': status,
    });
  }

  // ✅ Insert Farmland
  Future<int> insertFarmland({
    required int farmerId,
    required String name,
    required double size,
    required String location,
    required String description,
    required String image,
    required String status,
  }) async {
    final db = await instance.database;
    return await db.insert('farmland', {
      'farmer_id': farmerId,
      'name': name,
      'size': size,
      'location': location,
      'description': description,
      'image': image,
      'status': status,
    });
  }

  // ✅ Get All Products
  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await instance.database;
    return await db.query('products');
  }

  // ✅ Get All Pesticides
  Future<List<Map<String, dynamic>>> getPesticides() async {
    final db = await instance.database;
    return await db.query('pesticides');
  }

  // ✅ Get All Drip Irrigation Entries
  Future<List<Map<String, dynamic>>> getDripIrrigation() async {
    final db = await instance.database;
    return await db.query('drip_irrigation');
  }

  // ✅ Get All Farmland Entries
  Future<List<Map<String, dynamic>>> getFarmland() async {
    final db = await instance.database;
    return await db.query('farmland');
  }

  // ✅ Update Product Status
  Future<int> updateProductStatus(int id, String status) async {
    final db = await instance.database;
    return await db.update('products', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  // ✅ Delete Product
  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // ✅ Close Database
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
