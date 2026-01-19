# Firebase Web Setup Instructions

## The app is currently configured for Android. To run on Web, follow these steps:

### Option 1: Run on Android (Recommended)
```powershell
flutter run -d windows
# or
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

### Option 2: Configure Firebase for Web

1. **Get Firebase Web Config:**
   - Go to: https://console.firebase.google.com/
   - Select project: **ruhuna-rating-app**
   - Click ⚙️ → Project settings
   - Scroll to "Your apps"
   - Click **Web icon** (</>) to add web app
   - Register app
   - Copy the configuration

2. **Update main.dart:**
   Replace the placeholder values in `lib/main.dart` (lines 17-23) with your actual Firebase config:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "YOUR_ACTUAL_API_KEY",           // Replace this
    authDomain: "ruhuna-rating-app.firebaseapp.com",  // Replace this
    projectId: "ruhuna-rating-app",          // Replace this
    storageBucket: "ruhuna-rating-app.appspot.com",   // Replace this
    messagingSenderId: "YOUR_SENDER_ID",     // Replace this
    appId: "YOUR_APP_ID",                    // Replace this
  ),
);
```

3. **Run the app:**
```powershell
flutter run -d chrome
```

### For Now: Test on Android or Windows

The easiest way to test right now is:

```powershell
# Check available devices
flutter devices

# Run on Windows (if available)
flutter run -d windows

# OR connect Android device/emulator and run
flutter run -d android
```
