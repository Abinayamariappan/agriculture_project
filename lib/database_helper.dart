import '../models/product_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer';  // ✅ Added for logging
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  factory DatabaseHelper() {
    return instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('agriculture2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 12,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
        onDowngrade: onDatabaseDowngradeDelete, // 🔽 Added for safety
      );
    } catch (e) {
      log("Database Initialization Error: $e");
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      await db.execute('''
      CREATE TABLE farmers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT UNIQUE NOT NULL,
        address TEXT,
        profile_image BLOB,
        created_at INTEGER NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE admins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        address TEXT,
        image BLOB
      )
    ''');

      await db.execute('''
        CREATE TABLE govt_schemes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          apply TEXT
        )
      ''');


      await db.execute('''
      CREATE TABLE crops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        price REAL,
        min_kg REAL,
        total_kg REAL,
        description TEXT,
        image BLOB,
        status TEXT,
        farmer_id INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

      await db.execute('''
        CREATE TABLE fertilizers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            category TEXT,
            price REAL,
            min_kg REAL,
            total_kg REAL,
            description TEXT,
            image BLOB,
            status TEXT,
            farmer_id INTEGER,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
      ''');

      await db.execute('''
        CREATE TABLE seeds (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          category TEXT, -- ✅ Added
          price REAL NOT NULL,
          min_kg REAL NOT NULL,
          total_kg REAL NOT NULL,
          description TEXT NOT NULL,
          image BLOB,
          status TEXT NOT NULL,
          farmer_id INTEGER NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');


      await db.execute('''
          CREATE TABLE farmlands (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            farmer_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            size REAL NOT NULL,
            location TEXT NOT NULL,
            description TEXT,
            image BLOB,
            wages REAL,
            status TEXT DEFAULT 'Worker Requested',
            created_at INTEGER DEFAULT (strftime('%s', 'now')),
            FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE
          )
        ''');

      await db.execute('''
        CREATE TABLE drip_irrigation (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          farmer_id INTEGER NOT NULL,
          type TEXT NOT NULL,
          water_source TEXT NOT NULL,
          land_area REAL NOT NULL,
          location TEXT NOT NULL,
          wages REAL,
          description TEXT NOT NULL,
          image BLOB,
          status TEXT DEFAULT 'Worker Requested', -- Status as a text field
          created_at INTEGER DEFAULT (strftime('%s', 'now')),
          FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE
        );

    ''');

      await db.execute('''
      CREATE TABLE pesticides (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        farmer_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        location TEXT NOT NULL,
        spraying_area REAL NOT NULL,
        description TEXT NOT NULL,
        wages TEXT, 
        image BLOB NOT NULL,
        status TEXT NOT NULL DEFAULT 'Worker Requested',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE
      );

    ''');

      await db.execute('''
      CREATE TABLE jobs (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT    NOT NULL,
        category   TEXT    NOT NULL,
        status     TEXT    NOT NULL DEFAULT 'Pending',
        farmer_id  INTEGER NOT NULL,
        FOREIGN KEY(farmer_id) REFERENCES farmers(id)
      );
    ''');

      await db.execute('''
        CREATE TABLE customer_jobs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          location TEXT,
          description TEXT,
          status TEXT DEFAULT 'Pending',
          customer_name TEXT,
          customer_phone TEXT,
          image TEXT,
          customer_id INTEGER,  -- Add this line
          FOREIGN KEY (customer_id) REFERENCES users(id)
        );
      ''');

      await db.execute('''
      CREATE TABLE wishlist (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          image BLOB,
          price TEXT,
          user_id INTEGER,  -- Add this line
          FOREIGN KEY (user_id) REFERENCES users(id)
        );
    ''');

      // Insert default jobs
      await db.insert('jobs', {'name': 'Manage Farmland', 'category': 'Farmland', 'status': 'Pending',});
      await db.insert('jobs', {'name': 'Drip Irrigation Setup', 'category': 'Drip Irrigation', 'status': 'Pending'});
      await db.insert('jobs', {'name': 'Pesticide Spraying', 'category': 'Pesticide Spraying', 'status': 'Pending'});

      await db.execute('''
      CREATE TABLE status (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price REAL,
        quantity INTEGER,
        user_id INTEGER
      )
   ''');

      await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            total_amount REAL NOT NULL,
            payment_method TEXT NOT NULL,
            order_status TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            user_id INTEGER,  -- Add this line
            FOREIGN KEY (user_id) REFERENCES users(id)
          );

    ''');

      await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
      )
    ''');

      log("✅ Database Created Successfully with BLOB images");
    } catch (e) {
      log("❌ Database Creation Error: $e");
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.transaction((txn) async {
      try {
        if (oldVersion < 2) {
          print("🔄 Upgrading to Version 2: Adding 'address' & 'profile_image' columns...");
          await txn.execute('ALTER TABLE farmers ADD COLUMN address TEXT');
          await txn.execute('ALTER TABLE farmers ADD COLUMN profile_image TEXT');

          // ✅ Add columns in `users` table
          await txn.execute('ALTER TABLE users ADD COLUMN address TEXT');
          await txn.execute('ALTER TABLE users ADD COLUMN image TEXT');
        }

        if (oldVersion < 3) {
          print("🔄 Upgrading to Version 3: Creating 'weather' table...");
          await txn.execute('''
          CREATE TABLE IF NOT EXISTS weather (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            district TEXT NOT NULL,
            state TEXT NOT NULL,
            temperature TEXT NOT NULL,
            condition TEXT NOT NULL,
            last_updated INTEGER NOT NULL -- 🔥 Use INTEGER timestamp
          )
        ''');
        }

        if (oldVersion < 4) {
          print("🔄 Upgrading to Version 4: Creating 'products' table...");
          await txn.execute('''
           CREATE TABLE IF NOT EXISTS products (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              farmer_id INTEGER,
              category TEXT NOT NULL,
              name TEXT NOT NULL,
              price REAL NOT NULL,
              min_kg INTEGER NOT NULL,
              total_kg INTEGER NOT NULL,
              description TEXT,
              image BLOB,
              status TEXT DEFAULT 'Available'
            )
        ''');
        }

        if (oldVersion < 5) {
          print("🔄 Upgrading to Version 5: Adding Drip Irrigation Table...");
          await txn.execute('''
          CREATE TABLE IF NOT EXISTS drip_irrigation (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            farmer_id INTEGER NOT NULL,
            type TEXT NOT NULL,
            water_source TEXT NOT NULL,
            land_area REAL NOT NULL,
            location TEXT NOT NULL,
            description TEXT NOT NULL,
            image TEXT,
            status TEXT DEFAULT 'Worker Requested',
            created_at INTEGER NOT NULL,
            FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE
          )
        ''');
        }

        if (oldVersion < 6) {
          print("🔄 Upgrading to Version 6: Adding `status_id` Columns...");
          await txn.execute('ALTER TABLE products ADD COLUMN status_id INTEGER REFERENCES status(id) ON DELETE SET NULL');
          await txn.execute('ALTER TABLE farmlands ADD COLUMN status_id INTEGER REFERENCES status(id) ON DELETE SET NULL');
          await txn.execute('ALTER TABLE drip_irrigation ADD COLUMN status_id INTEGER REFERENCES status(id) ON DELETE SET NULL');
        }

        if (oldVersion < 7) {
          print("🔄 Upgrading to Version 7: Adding 'job_description' column...");
          await txn.execute('ALTER TABLE jobs ADD COLUMN job_description TEXT');
        }

        if (oldVersion < 8) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS customer_jobs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              location TEXT,
              description TEXT,
              status TEXT DEFAULT 'Pending',
              customer_name TEXT,
              customer_phone TEXT,
              image TEXT,
              customer_id INTEGER,
              FOREIGN KEY (customer_id) REFERENCES users(id)
            );
          ''');
        }

        if (oldVersion < 9) {
          print("🔄 Upgrading to Version 10: Adding columns to fertilizers...");


          // Create the new table with the updated schema
          await db.execute('''
            CREATE TABLE IF NOT EXISTS fertilizers (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              price REAL,
              min_kg REAL,
              total_kg REAL,
              description TEXT,
              image BLOB,
              status TEXT,
              farmer_id INTEGER
            )
    ''');
        }
        if (oldVersion < 10) {
          await db.execute(''' ALTER TABLE pesticides ADD COLUMN wages TEXT;''');
          // Add user_id to customer_jobs
          await db.execute('ALTER TABLE customer_jobs ADD COLUMN customer_id INTEGER');

          // Add user_id to wishlist
          await db.execute('ALTER TABLE wishlist ADD COLUMN user_id INTEGER');

          // Add user_id to orders
          await db.execute('ALTER TABLE orders ADD COLUMN user_id INTEGER');
          await db.execute('ALTER TABLE cart ADD COLUMN user_id INTEGER');
          await db.execute('ALTER TABLE jobs ADD COLUMN farmer_id INTEGER;');

        }
        if(oldVersion < 11) {
          await db.execute('''
        CREATE TABLE IF NOT EXISTS cart (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          price REAL,
          quantity INTEGER,
          user_id INTEGER
        )
      ''');
        }

        if(oldVersion < 12){
          await db.execute("ALTER TABLE fertilizers ADD COLUMN category TEXT");
          await db.execute("ALTER TABLE seeds ADD COLUMN category TEXT");
          await db.execute('ALTER TABLE crops ADD COLUMN created_at TEXT DEFAULT CURRENT_TIMESTAMP');
          await db.execute('ALTER TABLE fertilizers ADD COLUMN created_at TEXT DEFAULT CURRENT_TIMESTAMP');


        }

        print("✅ Database Upgraded to Version $newVersion");

      } catch (e) {
        print("❌ Database Upgrade Failed: ${e.toString()}");
        throw Exception("Database Upgrade Error: $e");
      }
    });
  }


  Future<int> registerUser(String name, String phone, String hashedPassword) async {
    try {
      final db = await database;
      var result = await db.insert(
        'users',
        {
          'name': name,
          'phone': phone,
          'password': hashedPassword,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return result;
    } catch (e) {
      print("Error registering user: $e");
      return -1;  // Return -1 to indicate an error occurred
    }
  }

  Future<Map<String, dynamic>?> loginUser(String phone, String password) async {
    final db = await database;
    String hashedPassword = sha256.convert(utf8.encode(password)).toString();

    try {
      final result = await db.query(
        'users',
        where: 'phone = ? AND password = ?',
        whereArgs: [phone, hashedPassword],
      );

      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }

  Future<void> insertCrop({
    required String name,
    required double price,
    required double minKg,
    required double totalKg,
    required String description,
    required Uint8List image,
    required String status,
    required int farmerId,
  }) async {
    final db = await database;
    await db.insert(
      'crops',
      {
        'name': name,
        'category': 'Crop',
        'price': price,
        'min_kg': minKg,
        'total_kg': totalKg,
        'description': description,
        'image': image,
        'status': status,
        'farmer_id': farmerId,
      },
    );
  }

  Future<int> insertFertilizer({
    required String name,
    required double price,
    required double minKg,
    required double totalKg,
    required String description,
    required Uint8List image,
    required String status,
    required int farmerId,
  }) async {
    final db = await database;
    return await db.insert('fertilizers', {
      'name': name,
      'category': 'Fertilizer', // ✅ Add this line
      'price': price,
      'min_kg': minKg,
      'total_kg': totalKg,
      'description': description,
      'image': image,
      'status': status,
      'farmer_id': farmerId,
    });
  }

  Future<int> insertSeed({
    required String name,
    required double price,
    required double minKg,
    required double totalKg,
    required String description,
    required Uint8List image,
    required String status,
    required int farmerId,
  }) async {
    final db = await instance.database;
    return await db.insert('seeds', {
      'name': name,
      'category': 'Seed', // ✅ Add this line
      'price': price,
      'min_kg': minKg,
      'total_kg': totalKg,
      'description': description,
      'image': image,
      'status': status,
      'farmer_id': farmerId,
    });
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    final db = await database;
    await db.update(
      'orders',
      {'order_status': newStatus},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllCrops(int farmerId) async {
    final db = await instance.database;
    final result = await db.query(
      'crops',
      where: 'farmer_id = ?',
      whereArgs: [farmerId],
    );

    // Return an empty list if the result is null or empty
    return result.isEmpty ? [] : result;
  }

  Future<List<Map<String, dynamic>>> getAllFertilizers(int farmerId) async {
    final db = await instance.database;
    return await db.query(
      'fertilizers',
      where: 'farmer_id = ?',
      whereArgs: [farmerId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllSeeds(int farmerId) async {
    final db = await instance.database;
    return await db.query(
      'seeds',
      where: 'farmer_id = ?',
      whereArgs: [farmerId],
    );
  }



  Future<List<Map<String, dynamic>>> getSeedsByFarmer(int farmerId) async {
    final db = await instance.database;
    return await db.query(
      'seeds',
      where: 'farmer_id = ?',
      whereArgs: [farmerId],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> updateItemStatus(String category, int id, String newStatus) async {
    final db = await database;

    // Normalize category
    category = category[0].toUpperCase() + category.substring(1).toLowerCase();

    String table;
    switch (category) {
      case 'Crop':
        table = 'crops';
        break;
      case 'Fertilizer':
        table = 'fertilizers';
        break;
      case 'Seed':
        table = 'seeds';
        break;
      default:
        throw Exception('Unknown category: $category');
    }

    await db.update(
      table,
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteItem(String category, int id) async {
    final db = await instance.database;
    // Normalize the category string to match the expected format
    category = category[0].toUpperCase() + category.substring(1).toLowerCase();

    String table = _getTableName(category);
    await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllAvailableProducts() async {
    try {
      final db = await instance.database;

      // Query the crops, fertilizers, and seeds tables without the farmer_id filter
      final crops = await db.query(
        'crops',
        where: 'status = ?',
        whereArgs: ['Available'],
      );

      final fertilizers = await db.query(
        'fertilizers',
        where: 'status = ?',
        whereArgs: ['Available'],
      );

      final seeds = await db.query(
        'seeds',
        where: 'status = ?',
        whereArgs: ['Available'],
      );

      // Add category tag to each
      final all = [
        ...crops.map((e) => {...e, 'category': 'Crop'}),
        ...fertilizers.map((e) => {...e, 'category': 'Fertilizer'}),
        ...seeds.map((e) => {...e, 'category': 'Seed'}),
      ];

      return all;
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableProductsByCategory(String category) async {
    try {
      final db = await instance.database;
      String table = _getTableName(category);

      // Query the specified table without the farmer_id filter
      final result = await db.query(
        table,
        where: 'status = ?',
        whereArgs: ['Available'],
        orderBy: 'created_at DESC',
      );

      return result.map((e) => {...e, 'category': category}).toList();
    } catch (e) {
      print("Error fetching products by category: $e");
      return [];
    }
  }

  String _getTableName(String category) {
    switch (category) {
      case 'Crop':
        return 'crops';
      case 'Fertilizer':
        return 'fertilizers';
      case 'Seed':
        return 'seeds';
      default:
        throw Exception('Invalid category: $category');
    }
  }

  Future<int> insertFarmland({
    required int farmerId,
    required String name,
    required double size,
    required String location,
    required String description,
    required double wages,
    required Uint8List image,
    required String status,
  }) async {
    final db = await database; // Get a reference to the database

    // Insert a new farmland record
    return await db.insert(
      'farmlands', // Table name
      {
        'farmer_id': farmerId, // Foreign key to farmer
        'name': name, // Farmland name
        'size': size, // Size of the farmland (in acres)
        'location': location, // Location of the farmland
        'description': description, // Farmland description
        'wages': wages, // Wages per day
        'image': image, // Image stored as bytes
        'status': status, // Status (e.g., 'Worker Requested')
        'created_at': DateTime.now().millisecondsSinceEpoch, // Timestamp for creation
      },
    );
  }


  // ✅ Insert a new Drip Irrigation Request
  Future<void> insertDripIrrigation({
    required int farmerId,
    required String type,
    required String waterSource,
    required double landArea,
    required String location,
    required double wages,
    required String description,
    required Uint8List image, // BLOB image as Uint8List
    String status = 'Worker Requested',
  }) async {
    final db = await DatabaseHelper.instance.database;

    await db.insert('drip_irrigation', {
      'farmer_id': farmerId,
      'type': type,
      'water_source': waterSource,
      'land_area': landArea,
      'location': location,
      'wages': wages,
      'description': description,
      'image': image,
      'status': status,
      'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unix timestamp
    });
  }

  Future<void> insertPesticide({
    required int farmerId,
    required String type,
    required String location,
    required double sprayingArea,
    required String description,
    required Uint8List image, // ✅ BLOB - image as bytes
    required double wages,     // ✅ optional if needed in table
    String status = 'Worker Requested',
  }) async {
    final db = await instance.database;
    await db.insert('pesticides', {
      'farmer_id': farmerId,
      'type': type,
      'location': location,
      'spraying_area': sprayingArea,
      'description': description,
      'wages': wages,
      'image': image,
      'status': status,
      'created_at': DateTime.now().toIso8601String(), // optional, since table has default
    });
  }

  // Get farmland jobs for a specific farmer
  Future<List<Map<String, dynamic>>> getFarmlandRequests({int? farmerId}) async {
    final db = await instance.database;
    return await db.query(
      'farmlands',
      columns: ['id', 'name', 'location', 'status', 'wages', 'image'],
      where: farmerId != null ? 'farmer_id = ?' : null,
      whereArgs: farmerId != null ? [farmerId] : null,
    );
  }

// Get drip irrigation jobs for a specific farmer
  Future<List<Map<String, dynamic>>> getDripIrrigationRequests({int? farmerId}) async {
    final db = await instance.database;
    return await db.query(
      'drip_irrigation',
      columns: ['id', 'type as name', 'location', 'status', 'wages', 'image'],
      where: farmerId != null ? 'farmer_id = ?' : null,
      whereArgs: farmerId != null ? [farmerId] : null,
    );
  }

// Get pesticide spraying jobs for a specific farmer
  Future<List<Map<String, dynamic>>> getPesticideRequests({int? farmerId}) async {
    final db = await instance.database;
    return await db.query(
      'pesticides',
      columns: ['id', 'type as name', 'location', 'status', 'wages', 'image'],
      where: farmerId != null ? 'farmer_id = ?' : null,
      whereArgs: farmerId != null ? [farmerId] : null,
    );
  }


  Future<void> updateJobStatus(int id, String status, String table) async {
    final db = await instance.database;
    await db.update(
      table,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteJob(int id, String table) async {
    final db = await instance.database;
    await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ✅ Insert Weather Data
  Future<int> saveWeatherData({
    required String district,
    required String state,
    required String temperature,
    required String condition,
  }) async {
    final db = await database;
    return await db.insert(
      'weather',
      {
        'district': district,
        'state': state,
        'temperature': temperature,
        'condition': condition,
        'last_updated': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace old data
    );
  }

  // ✅ Retrieve Weather Data by District
  Future<Map<String, dynamic>?> getWeatherData(String district) async {
    final db = await database;
    try {
      final result = await db.query(
        'weather',
        where: 'district = ?',
        whereArgs: [district],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      log("Error retrieving weather data: $e", name: "DatabaseHelper");
      return null;
    }
  }

  // ✅ Update Weather Data
  Future<int> updateWeatherData({
    required String district,
    required String state,
    required String temperature,
    required String condition,
  }) async {
    final db = await database;
    return await db.update(
      'weather',
      {
        'state': state,
        'temperature': temperature,
        'condition': condition,
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'district = ?',
      whereArgs: [district],
    );
  }


// ✅ Insert Farmer (Registration) with Transactions & Optimized Timestamp
  Future<int> registerFarmer({required String name, required String phone}) async {
    final db = await database;

    return await db.transaction((txn) async {
      try {
        // ✅ Check if farmer already exists
        var existingFarmer = await txn.query(
          'farmers',
          where: 'phone = ?',
          whereArgs: [phone],
        );

        if (existingFarmer.isNotEmpty) {
          throw Exception("Farmer with this phone number already exists!");
        }

        // ✅ Insert new farmer (without unnecessary nulls)
        int id = await txn.insert(
          'farmers',
          {
            'name': name,
            'phone': phone,
            'created_at': DateTime.now().millisecondsSinceEpoch,  // 🔥 Use INTEGER timestamp
          },
        );

        log("✅ New Farmer Registered: ID $id");
        return id;
      } catch (e) {
        log("❌ Farmer Registration Error: $e");
        rethrow; // Ensures rollback on failure
      }
    });
  }

  Future<void> updateUserAddress(String phone, String newAddress) async {
    final db = await database;
    try {
      await db.update(
        'users',
        {'address': newAddress},
        where: 'phone = ?',
        whereArgs: [phone],
      );
      log("Address updated for user with phone: $phone");
    } catch (e) {
      log("Error updating address for user with phone: $phone: $e");
    }
  }



  // ✅ Get Farmer by Phone (Login)
  Future<Map<String, dynamic>?> getFarmerByPhone(String phone) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'farmers',
        where: 'phone = ?',
        whereArgs: [phone],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      log("Error Fetching Farmer by Phone: $e");
      return null;
    }
  }

  // ✅ Get All Farmers
  Future<List<Map<String, dynamic>>> getAllFarmers() async {
    final db = await database;
    try {
      return await db.query('farmers');
    } catch (e) {
      log("Error Fetching Farmers: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getFarmerById(int id) async {
    final db = await instance.database;
    final result = await db.query('farmers', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }


  // ✅ Update Farmer Address
  Future<int> updateFarmerAddress(int farmerId, String address) async {
    final db = await database;
    try {
      int rowsAffected = await db.update(
        'farmers',
        {'address': address},
        where: 'id = ?',
        whereArgs: [farmerId],
      );
      log("Updated Address for Farmer ID $farmerId ✅");
      return rowsAffected;
    } catch (e) {
      log("Error Updating Address: $e");
      return 0;
    }
  }

  // ✅ Update Farmer Profile Image
  Future<int> updateProfileImage(int farmerId, String imagePath) async {
    final db = await database;
    try {
      int rowsAffected = await db.update(
        'farmers',
        {'profile_image': imagePath},
        where: 'id = ?',
        whereArgs: [farmerId],
      );
      log("Updated Profile Image for Farmer ID $farmerId ✅");
      return rowsAffected;
    } catch (e) {
      log("Error Updating Profile Image: $e");
      return 0;
    }
  }

  Future<int> updateCustomerProfileImage(String userPhone, String imagePath) async {
    final db = await database;
    try {
      int rowsAffected = await db.update(
        'customers', // Assuming customers table
        {'profile_image': imagePath},
        where: 'phone = ?',
        whereArgs: [userPhone], // Use phone instead of ID
      );
      log("Updated Profile Image for Customer with Phone $userPhone ✅");
      return rowsAffected;
    } catch (e) {
      log("Error Updating Customer Profile Image: $e");
      return 0;
    }
  }

  // ✅ Delete Farmer
  Future<int> deleteFarmer(int farmerId) async {
    final db = await database;
    try {
      int rowsDeleted = await db.delete(
        'farmers',
        where: 'id = ?',
        whereArgs: [farmerId],
      );
      log("Deleted Farmer ID $farmerId ✅");
      return rowsDeleted;
    } catch (e) {
      log("Error Deleting Farmer: $e");
      return 0;
    }
  }


// 🧠 Get all products for a farmer with optional category and status filters
  Future<List<Product>> getFarmerProducts({
    required int farmerId,
    String category = "All",
    String status = "All",
  }) async {
    final db = await database;

    List<String> whereClauses = ['farmer_id = ?'];
    List<dynamic> whereArgs = [farmerId];

    if (category != "All") {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }

    if (status != "All") {
      whereClauses.add('status = ?');
      whereArgs.add(status);
    }

    final List<Map<String, dynamic>> result = await db.query(
      'products',
      where: whereClauses.join(" AND "),
      whereArgs: whereArgs,
    );

    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> getProductsByCategoryWithStatus(int? farmerId, String category, {String? status}) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (category != "All") {
      whereClause += 'category = ?';
      whereArgs.add(category);
    }

    if (status != null) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += 'status = ?';
      whereArgs.add(status);
    }

    if (farmerId != null) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += 'farmer_id = ?';
      whereArgs.add(farmerId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereClause.isNotEmpty ? whereArgs : null,
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }


// 🧾 Get raw product maps (useful for dynamic list builders or raw display)
  Future<List<Map<String, dynamic>>> getProductMapsByCategoryWithStatus(
      int farmerId,
      String category, {
        String status = "All",
      }) async {
    final db = await database;
    List<String> whereClauses = ['farmer_id = ?'];
    List<dynamic> whereArgs = [farmerId];

    if (category != "All") {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }

    if (status != "All") {
      whereClauses.add('status = ?');
      whereArgs.add(status);
    }

    return await db.query(
      'products',
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
    );
  }

// 🔄 Update product availability or sale status
  Future<int> updateProductStatus(int productId, String status) async {
    final db = await database;
    return await db.update(
      'products',
      {'status': status},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  // ✅ Insert Admin Credentials
  Future<void> insertAdmin(String email, String password) async {
    final db = await database;  // Access the database correctly
    await db.insert(
      'admins',
      {'email': email, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace, // Prevent duplicates
    );
  }

// ✅ Check if Admin Exists
  Future<bool> doesAdminExist(String email) async {
    final db = await database;  // Access the database correctly
    final result = await db.query(
      'admins',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

// ✅ Authenticate Admin (Login)
  Future<bool> authenticateAdmin(String email, String password) async {
    final db = await database;  // Access the database correctly
    final result = await db.query(
      'admins',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty;
  }

// ✅ Insert a new Government Scheme
  Future<int> insertGovtScheme(String title, String description) async {
    final db = await database;
    return await db.insert('govt_schemes', {
      'title': title,
      'description': description,
    });
  }

// ✅ Get All Government Schemes
  Future<List<Map<String, dynamic>>> getGovtSchemes() async {
    final db = await database;
    return await db.query('govt_schemes', orderBy: 'id DESC');
  }

// ✅ Update a Government Scheme
  Future<int> updateGovtScheme(int id, String title, String description) async {
    final db = await database;
    return await db.update(
      'govt_schemes',
      {'title': title, 'description': description},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// ✅ Delete a Government Scheme
  Future<int> deleteGovtScheme(int id) async {
    final db = await database;
    return await db.delete('govt_schemes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getPendingJobRequests(String farmerId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT COUNT(*) as count FROM CustomerJobs WHERE farmer_id = ? AND status = 'pending'",
        [farmerId]
    );
    return result.isNotEmpty ? result.first['count'] as int : 0;
  }

  Future<int> addToCart(Map<String, dynamic> item) async {
    final db = await database;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentUserId = prefs.getInt('currentUserId') ?? 0;

    return await db.insert(
      'cart',
      {
        'name': item['name'],
        'price': item['price'],
        'quantity': item['quantity'],
        'user_id': currentUserId, // 👈 Include user ID
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getCartItemsForUser(int userId) async {
    final db = await database;
    var result = await db.query(
      'cart',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Ensure the result is mutable by wrapping it in a List of Maps
    return List<Map<String, dynamic>>.from(result);
  }

  Future<Map<String, dynamic>?> getCartItemByNameForUser(String name, int userId) async {
    final db = await database;
    final result = await db.query(
      'cart',
      where: 'name = ? AND user_id = ?',
      whereArgs: [name, userId],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Get all cart items
  Future<List<Map<String, dynamic>>> getCartItems(int currentUserId) async {
    final db = await database;

    return await db.query(
      'cart',
      where: 'user_id = ?',
      whereArgs: [currentUserId],
    );
  }


  // Update cart item quantity
  Future<int> updateCartItemQuantity(int id, int quantity) async {
    final db = await database;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentUserId = prefs.getInt('currentUserId') ?? 0;

    return await db.update(
      'cart',
      {'quantity': quantity},
      where: 'id = ? AND user_id = ?',  // Ensure user_id is matched
      whereArgs: [id, currentUserId],
    );
  }
  Future<int> removeFromCart(int id) async {
    final db = await database;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentUserId = prefs.getInt('currentUserId') ?? 0;

    return await db.delete(
      'cart',
      where: 'id = ? AND user_id = ?',  // Ensure user_id is matched
      whereArgs: [id, currentUserId],
    );
  }

  Future<void> clearCartForUser(int userId) async {
    final db = await database;
    await db.delete(
      'cart',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Clear cart
  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart');
  }

  Future<void> insertWishlist(Map<String, dynamic> item, int userId) async {
    final db = await database;
    await db.insert('wishlist', {
      'name': item['name'],
      'image': item['image'],
      'price': item['price'],
      'user_id': userId,
    });
  }

  // Add item to wishlist for the current user
  Future<void> addToWishlist(String name, Uint8List image, String price) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentUserId = prefs.getInt('currentUserId') ?? 0;  // Get current user ID from SharedPreferences

    if (currentUserId == 0) {
      throw Exception('User not logged in!');
    }

    final db = await database;

    try {
      await db.insert(
        'wishlist',
        {
          'name': name,
          'image': image,
          'price': price,
          'user_id': currentUserId,  // Ensure user is linked with the wishlist item
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // Use ConflictAlgorithm.replace to update duplicates (if needed)
      );
    } catch (e) {
      print("Error adding to wishlist: $e");
      throw Exception('Failed to add to wishlist');
    }
  }

// Retrieve all wishlist items for a specific user
  Future<List<Map<String, dynamic>>> getWishlist(int userId) async {
    final db = await database;
    return await db.query(
      'wishlist',
      where: 'user_id = ?', // Use correct column name 'user_id'
      whereArgs: [userId],
    );
  }

// Remove item from wishlist for a specific user
  Future<int> removeFromWishlist(int userId, String name) async {
    final db = await database;
    return await db.delete(
      'wishlist',
      where: 'user_id = ? AND name = ?', // Filter by user_id and name
      whereArgs: [userId, name],
    );
  }

// Clear entire wishlist for a specific user
  Future<void> clearWishlist(int userId) async {
    final db = await database;
    await db.delete(
      'wishlist',
      where: 'user_id = ?', // Only clear the wishlist for a specific user
      whereArgs: [userId],
    );
  }

  // Insert or Update User Info
  Future<void> insertOrUpdateUser(String name, String phone, String address, String? imagePath) async {
    final db = await database;
    await db.insert(
      'users',
      {'name': name, 'phone': phone, 'address': address, 'image': imagePath},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get User Info
  Future<Map<String, dynamic>?> getUser(String phone) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertOrder(
      double totalAmount,
      String paymentMethod,
      List<Map<String, dynamic>> cartItems,
      {required int userId}  // 👈 Add the userId parameter here
      ) async {
    final db = await database;
    int orderId = 0;

    await db.transaction((txn) async {
      orderId = await txn.insert(
        'orders',
        {
          'total_amount': totalAmount,
          'payment_method': paymentMethod,
          'order_status': 'Pending',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'user_id': userId,  // 👈 Attach the userId here
        },
      );

      for (var item in cartItems) {
        await txn.insert('order_items', {
          'order_id': orderId,
          'product_name': item['name'],
          'quantity': item['quantity'],
          'price': item['price'],
        });
      }
    });

    return orderId;
  }

  Future<List<Map<String, dynamic>>> getOrderHistory(int userId) async {
    final db = await database;
    return await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> printOrders() async {
    final db = await database;
    final orders = await db.query('orders');
    print(orders);
  }

  Future<void> checkTableStructure() async {
    final db = await database;
    final result = await db.rawQuery("PRAGMA table_info(orders)");
    print(result);
  }


  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await database;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentUserId = prefs.getInt('currentUserId') ?? 0;

    return await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [currentUserId],
      orderBy: 'created_at DESC',
    );
  }


  Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
    final db = await database;
    return await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }


  Future<int> saveOrder(double totalAmount, List<Map<String, dynamic>> cartItems) async {
    final db = await database;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentUserId = prefs.getInt('currentUserId') ?? 0;

    int orderId = await db.insert('orders', {
      'total_amount': totalAmount,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'user_id': currentUserId, // 👈
    });

    for (var item in cartItems) {
      await db.insert('order_items', {
        'order_id': orderId,
        'product_name': item['name'],
        'quantity': item['quantity'],
        'price': item['price'],
      });
    }

    return orderId;
  }

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final db = await database;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentUserId = prefs.getInt('currentUserId') ?? 0;

    // Fetch orders for the current user
    return await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [currentUserId],
      orderBy: 'created_at DESC', // Sorting orders by creation date, descending
    );
  }


  Future<void> insertCustomerJob(
      String title,
      String location,
      String description,
      String phone, {
        required String name,
        String? imageBase64,
        required int customerId, // <-- add this
      }) async {
    final db = await database;
    await db.insert('customer_jobs', {
      'title': title,
      'location': location,
      'description': description,
      'customer_phone': phone,
      'customer_name': name,
      'status': 'Pending',
      'image': imageBase64,
      'customer_id': customerId, // <-- insert this
    });
  }

  Future<List<Map<String, dynamic>>> getCustomerJobs() async {
    final db = await database;
    return await db.query('customer_jobs');
  }

  Future<List<Map<String, dynamic>>> getCustomerJobsByCustomerId(int customerId) async {
    final db = await database;
    return await db.query(
      'customer_jobs',
      where: 'customer_id = ?',
      whereArgs: [customerId],
    );
  }


  Future<List<Map<String, dynamic>>> getPendingCustomerJobs() async {
    final db = await database;
    return await db.query(
      'customer_jobs',
      where: 'status = ?',
      whereArgs: ['Pending'],
    );
  }

  Future<void> updateCustomerJobStatus(int id, String status) async {
    final db = await database;
    await db.update(
      'customer_jobs',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteCustomerJob(int id) async {
    final db = await database;
    await db.delete(
      'customer_jobs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// ✅ Close Database
  Future<void> close() async {
    final db = await _database;
    if (db != null) {
      await db.close();
      log("Database Closed ✅");
    }
  }
}

