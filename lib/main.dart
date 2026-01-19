import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'screens/landing_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with platform-specific options
    if (kIsWeb) {
      // For web, you MUST configure Firebase web options from Firebase Console
      // Follow these steps:
      // 1. Go to Firebase Console → Your Project → Project Settings
      // 2. Add a Web App (</> icon)
      // 3. Copy the config values and replace the placeholders below
      
      // Firebase web configuration
      const firebaseOptions = FirebaseOptions(
        apiKey: "AIzaSyD39lbl8OyQAUkudeEsRoIBZV6YGFz8gkU",
        authDomain: "ruhuna-rating-app.firebaseapp.com",
        projectId: "ruhuna-rating-app",
        storageBucket: "ruhuna-rating-app.firebasestorage.app",
        messagingSenderId: "1050938826630",
        appId: "1:1050938826630:web:e4410ff81ff7d7b7aa5607",
      );
      
      await Firebase.initializeApp(options: firebaseOptions);
      sqflite.databaseFactory = databaseFactoryFfiWeb;
    } else {
      // For Android/iOS, use google-services.json/GoogleService-Info.plist
      await Firebase.initializeApp();
    }
  } catch (e) {
    // If Firebase fails to initialize, show error
    print('Firebase initialization error: $e');
    print('Please configure Firebase for web platform.');
    print('See WEB_SETUP_INSTRUCTIONS.md for details.');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University of Ruhuna Rating App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    // Show landing page first
    return const LandingScreen();
  }
}
