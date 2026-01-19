# Firebase Authentication Setup Guide for Ruhuna Rating App

## ✅ What Has Been Completed

All code changes have been implemented. Now you need to configure Firebase in the Firebase Console.

---

## 📋 Step-by-Step Firebase Console Setup

### **Step 1: Access Your Firebase Project**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Sign in with your Google account
3. Find and click on your project: **"ruhuna-rating-app"**
   - If the project doesn't exist, click **"Add project"** and create it with name "ruhuna-rating-app"

---

### **Step 2: Enable Firebase Authentication**

1. In the Firebase Console left sidebar, click **"Authentication"**
2. Click **"Get Started"** button
3. Go to the **"Sign-in method"** tab
4. Find **"Email/Password"** in the list
5. Click on it and toggle **"Enable"**
6. Click **"Save"**

✅ Authentication is now enabled!

---

### **Step 3: Create Firestore Database**

1. In the Firebase Console left sidebar, click **"Firestore Database"**
2. Click **"Create database"** button
3. Choose **"Start in test mode"** (we'll add security rules later)
4. Click **"Next"**
5. Select a Cloud Firestore location (choose the one closest to Sri Lanka, like `asia-south1`)
6. Click **"Enable"**

⏳ Wait for the database to be created (takes ~30 seconds)

---

### **Step 4: Add Android App to Firebase**

1. In Firebase Console, click the **⚙️ Settings icon** next to "Project Overview"
2. Click **"Project settings"**
3. Scroll down to **"Your apps"** section
4. Click the **Android icon** (robot icon) to add Android app

#### Configure Android App:

**Android package name:** `com.example.rateapp`

**App nickname (optional):** Ruhuna Rating App Android

**Debug signing certificate (optional):** Leave blank for now

5. Click **"Register app"**

---

### **Step 5: Download google-services.json**

1. Click **"Download google-services.json"**
2. Save the file
3. **Important:** Move this file to:
   ```
   d:\AAA_sem_05\Moble_app\rateapp\android\app\google-services.json
   ```

   **Path must be exactly:** `android/app/google-services.json`

4. Click **"Next"** in Firebase Console
5. Click **"Next"** again (Gradle setup is already done)
6. Click **"Continue to console"**

✅ Android configuration complete!

---

### **Step 6: (Optional) Add iOS App**

If you want to test on iOS:

1. Click the **iOS icon** (Apple icon)
2. **iOS bundle ID:** `com.example.rateapp`
3. Download **`GoogleService-Info.plist`**
4. Place it in: `ios/Runner/GoogleService-Info.plist`

---

### **Step 7: Set Up Firestore Security Rules**

1. In Firebase Console, go to **"Firestore Database"**
2. Click the **"Rules"** tab
3. Replace the existing rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - authenticated users can read their own data
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Services collection - anyone can read, only admins can write
    match /services/{serviceId} {
      allow read: if true;
      allow write: if request.auth != null && 
                   get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'Admin';
    }
    
    // Ratings collection - authenticated users can read and write
    match /ratings/{ratingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                    request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && 
                            resource.data.userId == request.auth.uid;
    }
  }
}
```

4. Click **"Publish"**

---

## 💻 Terminal Commands to Run

Now run these commands in your terminal:

### 1. Install Flutter Dependencies

```powershell
flutter pub get
```

### 2. Clean and Rebuild

```powershell
flutter clean
flutter pub get
```

### 3. Run the App

```powershell
flutter run
```

---

## 🔐 How the Authentication Works

### **University ID Format:**
The app converts University IDs to email format for Firebase:
- University ID: `S2020001` → Email: `S2020001@ruhuna.ac.lk`
- University ID: `ST2020001` → Email: `ST2020001@ruhuna.ac.lk`
- University ID: `ADMIN001` → Email: `ADMIN001@ruhuna.ac.lk`

### **Registration Process:**
1. User enters: Name, University ID, Role, Password
2. App creates Firebase account with email: `{universityId}@ruhuna.ac.lk`
3. User profile saved in Firestore `/users/{uid}` collection

### **Login Process:**
1. User enters: University ID and Password
2. App converts University ID to email format
3. Firebase authenticates using email/password
4. User redirected to Home Screen

---

## 📁 Files Modified/Created

### **Modified:**
- ✅ `pubspec.yaml` - Added Firebase dependencies
- ✅ `lib/main.dart` - Added Firebase initialization
- ✅ `lib/screens/login_screen.dart` - Integrated Firebase auth
- ✅ `android/build.gradle.kts` - Added Google services plugin
- ✅ `android/app/build.gradle.kts` - Added Google services and minSdk

### **Created:**
- ✅ `lib/services/auth_service.dart` - Firebase Authentication service
- ✅ `lib/services/firestore_service.dart` - Firestore database service
- ✅ `lib/screens/register_screen.dart` - User registration screen

---

## 🧪 Testing the App

### **Test Registration:**

1. Run the app
2. Click **"Don't have an account? Register"**
3. Fill in:
   - **Name:** John Doe
   - **University ID:** S2020001
   - **Role:** Student
   - **Password:** password123
   - **Confirm Password:** password123
4. Click **"REGISTER"**
5. Should see success message

### **Test Login:**

1. Enter:
   - **University ID:** S2020001
   - **Password:** password123
2. Click **"LOGIN"**
3. Should navigate to Home Screen

### **Verify in Firebase Console:**

1. Go to **Authentication** → **Users** tab
2. Should see the registered user with email: `S2020001@ruhuna.ac.lk`
3. Go to **Firestore Database** → **Data** tab
4. Should see `users` collection with user document

---

## 🚨 Troubleshooting

### **Error: "com.google.gms:google-services not found"**
- Make sure you added the `google-services.json` file to `android/app/`

### **Error: "FirebaseException: No Firebase App"**
- Ensure Firebase is initialized in `main.dart` before `runApp()`

### **Error: "User not found"**
- The user hasn't registered yet
- Check Firebase Console → Authentication → Users

### **Error: "Network request failed"**
- Check internet connection
- Verify `google-services.json` is in correct location

### **Build fails after adding Firebase**
- Run: `flutter clean && flutter pub get`
- Delete `build` folder and rebuild

---

## 📱 Next Steps

After successful setup:

1. ✅ Test registration with multiple roles (Student, Staff, Admin)
2. ✅ Test login/logout functionality
3. ✅ Implement password reset feature (already in `AuthService`)
4. ✅ Add user profile page
5. ✅ Integrate ratings with authenticated users
6. ✅ Add logout button in home screen

---

## 🔒 Security Notes

- Passwords are handled by Firebase Auth (encrypted)
- Never store passwords in Firestore
- Test mode Firestore rules expire after 30 days
- Update security rules before production
- Use stronger password requirements in production

---

## 📞 Support

If you encounter issues:
1. Check Firebase Console for error logs
2. Run `flutter doctor` to check environment
3. Verify all files are in correct locations
4. Check that `google-services.json` matches your package name

---

**Good luck with your Firebase implementation! 🚀**
