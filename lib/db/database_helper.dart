import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/service.dart';
import '../models/subservice.dart';
import '../models/rating.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ruhuna_rating.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        university_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        role TEXT CHECK(role IN ('student','staff','admin')) NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Services (
        service_id INTEGER PRIMARY KEY AUTOINCREMENT,
        service_name TEXT NOT NULL,
        description TEXT,
        image_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE SubServices (
        subservice_id INTEGER PRIMARY KEY AUTOINCREMENT,
        service_id INTEGER NOT NULL,
        subservice_name TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY(service_id) REFERENCES Services(service_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Ratings (
        rating_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        subservice_id INTEGER NOT NULL,
        score INTEGER CHECK(score BETWEEN 0 AND 10) NOT NULL,
        comment TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES Users(user_id),
        FOREIGN KEY(subservice_id) REFERENCES SubServices(subservice_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Trending (
        trend_id INTEGER PRIMARY KEY AUTOINCREMENT,
        service_id INTEGER NOT NULL,
        average_score REAL,
        rank INTEGER,
        FOREIGN KEY(service_id) REFERENCES Services(service_id)
      )
    ''');
  }

  // Hash password for security
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // User operations
  Future<int> insertUser(User user) async {
    final db = await database;
    final hashedUser = User(
      universityId: user.universityId,
      name: user.name,
      role: user.role,
      password: _hashPassword(user.password),
    );
    return await db.insert('Users', hashedUser.toMap());
  }

  Future<User?> authenticateUser(String universityId, String password) async {
    final db = await database;
    final hashedPassword = _hashPassword(password);

    final results = await db.query(
      'Users',
      where: 'university_id = ? AND password = ?',
      whereArgs: [universityId, hashedPassword],
    );

    if (results.isNotEmpty) {
      return User.fromMap(results.first);
    }
    return null;
  }

  Future<User?> getUserById(int userId) async {
    final db = await database;
    final results = await db.query(
      'Users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (results.isNotEmpty) {
      return User.fromMap(results.first);
    }
    return null;
  }

  // Service operations
  Future<int> insertService(Service service) async {
    final db = await database;
    return await db.insert('Services', service.toMap());
  }

  Future<List<Service>> getAllServices() async {
    final db = await database;
    final results = await db.query('Services');
    return results.map((map) => Service.fromMap(map)).toList();
  }

  Future<Service?> getServiceById(int serviceId) async {
    final db = await database;
    final results = await db.query(
      'Services',
      where: 'service_id = ?',
      whereArgs: [serviceId],
    );

    if (results.isNotEmpty) {
      return Service.fromMap(results.first);
    }
    return null;
  }

  // SubService operations
  Future<int> insertSubService(SubService subService) async {
    final db = await database;
    return await db.insert('SubServices', subService.toMap());
  }

  Future<List<SubService>> getSubServicesByServiceId(int serviceId) async {
    final db = await database;
    final results = await db.query(
      'SubServices',
      where: 'service_id = ?',
      whereArgs: [serviceId],
    );
    return results.map((map) => SubService.fromMap(map)).toList();
  }

  // Rating operations
  Future<int> insertRating(Rating rating) async {
    final db = await database;

    // Check if user has already rated this subservice
    final existing = await db.query(
      'Ratings',
      where: 'user_id = ? AND subservice_id = ?',
      whereArgs: [rating.userId, rating.subserviceId],
    );

    if (existing.isNotEmpty) {
      // Update existing rating
      return await db.update(
        'Ratings',
        {'score': rating.score, 'comment': rating.comment},
        where: 'user_id = ? AND subservice_id = ?',
        whereArgs: [rating.userId, rating.subserviceId],
      );
    } else {
      // Insert new rating
      return await db.insert('Ratings', rating.toMap());
    }
  }

  Future<List<Rating>> getRatingsBySubService(int subserviceId) async {
    final db = await database;
    final results = await db.query(
      'Ratings',
      where: 'subservice_id = ?',
      whereArgs: [subserviceId],
    );
    return results.map((map) => Rating.fromMap(map)).toList();
  }

  Future<Rating?> getUserRatingForSubService(
    int userId,
    int subserviceId,
  ) async {
    final db = await database;
    final results = await db.query(
      'Ratings',
      where: 'user_id = ? AND subservice_id = ?',
      whereArgs: [userId, subserviceId],
    );

    if (results.isNotEmpty) {
      return Rating.fromMap(results.first);
    }
    return null;
  }

  // Calculate average rating for a service
  Future<double> calculateAverageRating(int serviceId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT AVG(r.score) as avg_score
      FROM Ratings r
      INNER JOIN SubServices s ON r.subservice_id = s.subservice_id
      WHERE s.service_id = ?
    ''',
      [serviceId],
    );

    if (result.isNotEmpty && result.first['avg_score'] != null) {
      return (result.first['avg_score'] as num).toDouble();
    }
    return 0.0;
  }

  // Get trending services (sorted by average rating)
  Future<List<Map<String, dynamic>>> getTrendingServices() async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT 
        s.service_id,
        s.service_name,
        s.description,
        s.image_path,
        AVG(r.score) as average_score,
        COUNT(DISTINCT r.user_id) as rating_count
      FROM Services s
      LEFT JOIN SubServices ss ON s.service_id = ss.service_id
      LEFT JOIN Ratings r ON ss.subservice_id = r.subservice_id
      GROUP BY s.service_id
      ORDER BY average_score DESC, rating_count DESC
    ''');

    return results;
  }

  // Get service statistics
  Future<Map<String, dynamic>> getServiceStats(int serviceId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT 
        COUNT(DISTINCT r.user_id) as total_ratings,
        AVG(r.score) as average_score,
        MIN(r.score) as min_score,
        MAX(r.score) as max_score
      FROM Ratings r
      INNER JOIN SubServices s ON r.subservice_id = s.subservice_id
      WHERE s.service_id = ?
    ''',
      [serviceId],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return {
      'total_ratings': 0,
      'average_score': 0.0,
      'min_score': 0,
      'max_score': 0,
    };
  }

  // Initialize with sample data
  Future<void> initializeSampleData() async {
    try {
      final db = await database;

      // Check if data already exists (with timeout for web)
      try {
        final serviceCount = Sqflite.firstIntValue(
          await db
              .rawQuery('SELECT COUNT(*) FROM Services')
              .timeout(const Duration(seconds: 3)),
        );

        if (serviceCount! > 0) {
          print('Data already initialized');
          return; // Data already initialized
        }
      } catch (e) {
        print(
          'Warning: Could not check existing data, proceeding with initialization',
        );
      }

      print('Initializing sample data...');

      // Insert services
      final services = [
        Service(
          serviceName: 'Food (Canteens)',
          description: 'Campus dining facilities',
          imagePath: 'canteen',
        ),
        Service(
          serviceName: 'Security',
          description: 'Student security services',
          imagePath: 'security',
        ),
        Service(
          serviceName: 'Library',
          description: 'University library facilities',
          imagePath: 'library',
        ),
        Service(
          serviceName: 'Lecture Halls',
          description: 'Classroom and lecture hall conditions',
          imagePath: 'lecture_hall',
        ),
        Service(
          serviceName: 'Gardening',
          description: 'Campus landscaping and environment',
          imagePath: 'gardening',
        ),
        Service(
          serviceName: 'Accommodation',
          description: 'Hostel facilities',
          imagePath: 'hostel',
        ),
        Service(
          serviceName: 'Sports',
          description: 'Sports facilities and activities',
          imagePath: 'sports',
        ),
      ];

      for (var service in services) {
        await insertService(service);
      }

      print('Services inserted');

      // Insert sub-services for Canteen (serviceId: 1)
      final canteenSubServices = [
        SubService(
          serviceId: 1,
          subserviceName: 'Food Quality',
          description: 'Quality and taste of food',
        ),
        SubService(
          serviceId: 1,
          subserviceName: 'Seating Availability',
          description: 'Availability of seats',
        ),
        SubService(
          serviceId: 1,
          subserviceName: 'Queue Management',
          description: 'Waiting time and queue efficiency',
        ),
        SubService(
          serviceId: 1,
          subserviceName: 'Comfortability',
          description: 'Overall comfort and ambiance',
        ),
        SubService(
          serviceId: 1,
          subserviceName: 'Animal Interruptions',
          description: 'Issues with animals in dining areas',
        ),
      ];

      for (var subService in canteenSubServices) {
        await insertSubService(subService);
      }

      // Insert sub-services for Security (serviceId: 2)
      final securitySubServices = [
        SubService(
          serviceId: 2,
          subserviceName: 'Response Time',
          description: 'Speed of security response',
        ),
        SubService(
          serviceId: 2,
          subserviceName: 'Visibility',
          description: 'Security presence on campus',
        ),
        SubService(
          serviceId: 2,
          subserviceName: 'Safety Feeling',
          description: 'How safe students feel',
        ),
        SubService(
          serviceId: 2,
          subserviceName: 'Equipment Quality',
          description: 'Quality of security equipment',
        ),
      ];

      for (var subService in securitySubServices) {
        await insertSubService(subService);
      }

      // Insert sub-services for Library (serviceId: 3)
      final librarySubServices = [
        SubService(
          serviceId: 3,
          subserviceName: 'Book Availability',
          description: 'Availability of required books',
        ),
        SubService(
          serviceId: 3,
          subserviceName: 'Study Space',
          description: 'Quality and availability of study areas',
        ),
        SubService(
          serviceId: 3,
          subserviceName: 'Noise Level',
          description: 'Quietness of the library',
        ),
        SubService(
          serviceId: 3,
          subserviceName: 'Staff Helpfulness',
          description: 'Library staff assistance',
        ),
        SubService(
          serviceId: 3,
          subserviceName: 'Internet Access',
          description: 'WiFi and computer access',
        ),
      ];

      for (var subService in librarySubServices) {
        await insertSubService(subService);
      }

      // Insert sub-services for Lecture Halls (serviceId: 4)
      final lectureHallSubServices = [
        SubService(
          serviceId: 4,
          subserviceName: 'Seating Comfort',
          description: 'Comfort of chairs and desks',
        ),
        SubService(
          serviceId: 4,
          subserviceName: 'Audio/Visual Equipment',
          description: 'Quality of AV equipment',
        ),
        SubService(
          serviceId: 4,
          subserviceName: 'Cleanliness',
          description: 'Cleanliness of halls',
        ),
        SubService(
          serviceId: 4,
          subserviceName: 'Ventilation',
          description: 'Air quality and temperature',
        ),
      ];

      for (var subService in lectureHallSubServices) {
        await insertSubService(subService);
      }

      // Insert sub-services for Gardening (serviceId: 5)
      final gardeningSubServices = [
        SubService(
          serviceId: 5,
          subserviceName: 'Maintenance',
          description: 'Regular upkeep of gardens',
        ),
        SubService(
          serviceId: 5,
          subserviceName: 'Aesthetic Appeal',
          description: 'Visual beauty of campus',
        ),
        SubService(
          serviceId: 5,
          subserviceName: 'Cleanliness',
          description: 'Cleanliness of outdoor areas',
        ),
      ];

      for (var subService in gardeningSubServices) {
        await insertSubService(subService);
      }

      // Insert sub-services for Accommodation (serviceId: 6)
      final accommodationSubServices = [
        SubService(
          serviceId: 6,
          subserviceName: 'Room Condition',
          description: 'State of hostel rooms',
        ),
        SubService(
          serviceId: 6,
          subserviceName: 'Bathroom Facilities',
          description: 'Quality of bathrooms',
        ),
        SubService(
          serviceId: 6,
          subserviceName: 'Common Areas',
          description: 'Quality of shared spaces',
        ),
        SubService(
          serviceId: 6,
          subserviceName: 'Security',
          description: 'Hostel security measures',
        ),
        SubService(
          serviceId: 6,
          subserviceName: 'Internet Connection',
          description: 'WiFi availability and speed',
        ),
      ];

      for (var subService in accommodationSubServices) {
        await insertSubService(subService);
      }

      // Insert sub-services for Sports (serviceId: 7)
      final sportsSubServices = [
        SubService(
          serviceId: 7,
          subserviceName: 'Equipment Quality',
          description: 'Quality of sports equipment',
        ),
        SubService(
          serviceId: 7,
          subserviceName: 'Facility Condition',
          description: 'State of sports facilities',
        ),
        SubService(
          serviceId: 7,
          subserviceName: 'Availability',
          description: 'Access to sports facilities',
        ),
        SubService(
          serviceId: 7,
          subserviceName: 'Coaching Support',
          description: 'Quality of coaching',
        ),
      ];

      for (var subService in sportsSubServices) {
        await insertSubService(subService);
      }

      print('Sample data initialization complete');
    } catch (e) {
      print('Error initializing sample data: $e');
      // Don't rethrow - allow app to continue even if initialization fails
    }
  }

  // Close database
  // Get all ratings by a specific user
  Future<List<Map<String, dynamic>>> getUserRatingsWithDetails(
    int userId,
  ) async {
    final db = await database;
    final results = await db.rawQuery(
      '''
      SELECT 
        r.rating_id,
        r.score,
        r.comment,
        r.timestamp,
        ss.subservice_name,
        s.service_name,
        s.service_id,
        ss.subservice_id
      FROM Ratings r
      INNER JOIN SubServices ss ON r.subservice_id = ss.subservice_id
      INNER JOIN Services s ON ss.service_id = s.service_id
      WHERE r.user_id = ?
      ORDER BY r.timestamp DESC
    ''',
      [userId],
    );

    return results;
  }

  // Get user's contribution statistics
  Future<Map<String, dynamic>> getUserContributionStats(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT 
        COUNT(*) as total_ratings,
        AVG(score) as average_score,
        MIN(score) as min_score,
        MAX(score) as max_score
      FROM Ratings
      WHERE user_id = ?
    ''',
      [userId],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return {
      'total_ratings': 0,
      'average_score': 0.0,
      'min_score': 0,
      'max_score': 0,
    };
  }

  // Get recent rating trends for a service (for monitoring sudden drops)
  Future<List<Map<String, dynamic>>> getRecentServiceRatingTrend(
    int serviceId,
    int daysBack,
  ) async {
    final db = await database;
    final results = await db.rawQuery(
      '''
      SELECT 
        DATE(r.timestamp) as date,
        AVG(r.score) as average_score,
        COUNT(*) as rating_count
      FROM Ratings r
      INNER JOIN SubServices ss ON r.subservice_id = ss.subservice_id
      WHERE ss.service_id = ? 
        AND r.timestamp >= datetime('now', '-$daysBack days')
      GROUP BY DATE(r.timestamp)
      ORDER BY date DESC
    ''',
      [serviceId],
    );

    return results;
  }

  // Detect sudden rating drops (for alert system)
  Future<List<Map<String, dynamic>>> detectRatingDrops(
    double dropThreshold,
    int hoursBack,
  ) async {
    final db = await database;
    final results = await db.rawQuery(
      '''
      SELECT 
        s.service_id,
        s.service_name,
        AVG(CASE WHEN r.timestamp >= datetime('now', '-$hoursBack hours') 
            THEN r.score END) as recent_avg,
        AVG(CASE WHEN r.timestamp < datetime('now', '-$hoursBack hours') 
            THEN r.score END) as previous_avg,
        COUNT(CASE WHEN r.timestamp >= datetime('now', '-$hoursBack hours') 
            THEN 1 END) as recent_count
      FROM Services s
      INNER JOIN SubServices ss ON s.service_id = ss.service_id
      INNER JOIN Ratings r ON ss.subservice_id = r.subservice_id
      GROUP BY s.service_id, s.service_name
      HAVING recent_avg IS NOT NULL 
        AND previous_avg IS NOT NULL
        AND (previous_avg - recent_avg) > ?
        AND recent_count >= 3
      ORDER BY (previous_avg - recent_avg) DESC
    ''',
      [dropThreshold],
    );

    return results;
  }

  // Get service rating distribution for a user
  Future<Map<String, dynamic>> getUserServiceRating(
    int userId,
    int serviceId,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT 
        COUNT(*) as ratings_given,
        AVG(r.score) as user_average
      FROM Ratings r
      INNER JOIN SubServices ss ON r.subservice_id = ss.subservice_id
      WHERE r.user_id = ? AND ss.service_id = ?
    ''',
      [userId, serviceId],
    );

    if (result.isNotEmpty && result.first['ratings_given'] != 0) {
      return result.first;
    }
    return {'ratings_given': 0, 'user_average': null};
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
