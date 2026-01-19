# 🚀 Quick Start: Firebase Setup Checklist

## ⚡ Quick Setup (5 Minutes)

### ✅ Step 1: Download google-services.json
1. Go to: https://console.firebase.google.com/
2. Open project: **ruhuna-rating-app**
3. Click ⚙️ Settings → Project settings
4. Scroll to "Your apps" section
5. If no Android app exists:
   - Click Android icon
   - Package name: `com.example.rateapp`
   - Register app
6. Download `google-services.json`
7. **Place it here:** `android/app/google-services.json`

### ✅ Step 2: Enable Authentication
1. In Firebase Console → Authentication
2. Click "Get Started"
3. Sign-in method → Email/Password → Enable → Save

### ✅ Step 3: Create Firestore Database
1. In Firebase Console → Firestore Database
2. Create database → Test mode → Enable
3. Select location: asia-south1 (or closest to you)

### ✅ Step 4: Run the App
```powershell
flutter clean
flutter pub get
flutter run
```

---

## 📝 Test Credentials

### Register a New User:
- Name: John Doe
- University ID: S2020001
- Role: Student
- Password: password123

### Then Login:
- University ID: S2020001
- Password: password123

---

## 🔍 Verify Setup

After registration, check Firebase Console:

1. **Authentication → Users**
   - Should see: S2020001@ruhuna.ac.lk

2. **Firestore Database → Data**
   - Should see: users collection with user document

---

## 📄 For Complete Guide
See: [FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md)

---

## ❗ Common Issues

### Can't find google-services.json?
**Location:** `android/app/google-services.json`
**NOT:** `android/google-services.json` ❌

### Build fails?
```powershell
flutter clean
flutter pub get
flutter run
```

### Login fails "user not found"?
- Register first using the Register screen
- Check Firebase Console → Authentication → Users

---

**That's it! You're ready to go! 🎉**
