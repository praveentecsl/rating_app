# University of Ruhuna Rating App

A comprehensive Flutter application for rating university services at the University of Ruhuna. This app allows students, staff, and administrators to rate various university services and view trending ratings.

## Features

✅ **Secure Login System**: Authentication for students, staff, and admin using university ID
✅ **Multiple Services**: Rate 7 different university services
✅ **Sub-Service Ratings**: Each service has detailed sub-categories (e.g., Food Quality, Seating, etc.)
✅ **Real-time Ratings**: Use intuitive sliders (0-10) to rate services
✅ **Trending Dashboard**: View top-rated services dynamically
✅ **Professional UI**: Clean, modern design with university colors
✅ **SQLite Database**: Secure local data storage with encrypted passwords
✅ **Automatic Updates**: Ratings update in real-time

## Services Available

1. **Food (Canteens)**
   - Food Quality
   - Seating Availability
   - Queue Management
   - Comfortability
   - Animal Interruptions

2. **Security**
   - Response Time
   - Visibility
   - Safety Feeling
   - Equipment Quality

3. **Library**
   - Book Availability
   - Study Space
   - Noise Level
   - Staff Helpfulness
   - Internet Access

4. **Lecture Halls**
   - Seating Comfort
   - Audio/Visual Equipment
   - Cleanliness
   - Ventilation

5. **Gardening**
   - Maintenance
   - Aesthetic Appeal
   - Cleanliness

6. **Accommodation (Hostels)**
   - Room Condition
   - Bathroom Facilities
   - Common Areas
   - Security
   - Internet Connection

7. **Sports**
   - Equipment Quality
   - Facility Condition
   - Availability
   - Coaching Support

## Demo Credentials

The app comes pre-loaded with sample users:

| Role    | University ID | Password    |
| ------- | ------------- | ----------- |
| Student | S2020001      | password123 |
| Staff   | ST2020001     | password123 |
| Admin   | ADMIN001      | admin123    |

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── db/
│   └── database_helper.dart     # SQLite database management
├── models/
│   ├── user.dart               # User data model
│   ├── service.dart            # Service data model
│   ├── subservice.dart         # SubService data model
│   └── rating.dart             # Rating data model
├── screens/
│   ├── login_screen.dart       # Login interface
│   ├── home_screen.dart        # Home dashboard
│   └── service_detail_screen.dart  # Service rating interface
└── theme/
    └── app_theme.dart          # App styling and colors
```

## Database Schema

### Users Table

- `user_id`: Primary key (auto-increment)
- `university_id`: Unique university ID (login)
- `name`: User's full name
- `role`: student | staff | admin
- `password`: Hashed password (SHA-256)

### Services Table

- `service_id`: Primary key (auto-increment)
- `service_name`: Name of the service
- `description`: Service description
- `image_path`: Icon identifier

### SubServices Table

- `subservice_id`: Primary key (auto-increment)
- `service_id`: Foreign key to Services
- `subservice_name`: Name of the sub-service
- `description`: Sub-service description

### Ratings Table

- `rating_id`: Primary key (auto-increment)
- `user_id`: Foreign key to Users
- `subservice_id`: Foreign key to SubServices
- `score`: Rating score (0-10)
- `comment`: Optional comment
- `timestamp`: Rating timestamp

### Trending Table

- `trend_id`: Primary key (auto-increment)
- `service_id`: Foreign key to Services
- `average_score`: Calculated average
- `rank`: Service ranking

## Installation & Setup

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android Emulator or Physical Device

### Installation Steps

1. **Clone or download this project**

2. **Navigate to project directory**

   ```bash
   cd rateapp
   ```

3. **Install dependencies**

   ```bash
   flutter pub get
   ```

4. **Run the app**

   ```bash
   flutter run
   ```

5. **Build for release (Android)**
   ```bash
   flutter build apk --release
   ```

## Dependencies

The app uses the following packages:

- `sqflite: ^2.3.0` - SQLite database
- `path: ^1.9.0` - Path manipulation
- `crypto: ^3.0.3` - Password hashing
- `cupertino_icons: ^1.0.8` - iOS-style icons

## How to Use

### 1. Login

- Open the app
- Enter your university ID and password
- Use demo credentials provided above
- Click "LOGIN"

### 2. View Services

- After login, you'll see the home screen
- Top-rated service is highlighted at the top
- All services are listed below with current ratings

### 3. Rate a Service

- Tap on any service card
- You'll see all sub-services for that service
- Use sliders to rate each sub-service (0-10)
- Ratings are saved automatically as you slide
- Click "SAVE ALL RATINGS & RETURN" to go back

### 4. View Trending

- Home screen automatically shows services ranked by rating
- Top service is highlighted with a trophy icon
- Pull down to refresh ratings

### 5. Logout

- Click the logout icon in the top-right corner
- Confirm logout

## Color Scheme

The app uses University of Ruhuna's official colors:

- **Primary Color**: Dark Green (#1B5E20)
- **Secondary Color**: Medium Green (#388E3C)
- **Accent Color**: Gold/Yellow (#FFC107)
- **Background**: Light Gray (#F5F5F5)

## Rating System

- **0-2**: Very Poor (Red)
- **3-4**: Poor to Below Average (Deep Orange)
- **5-6**: Average to Above Average (Orange)
- **7-8**: Good to Very Good (Light Green)
- **9-10**: Excellent (Green)

## Security Features

- Passwords are hashed using SHA-256 before storage
- No plain-text passwords are stored in the database
- User sessions are maintained during app lifetime
- Logout required for user switching

## Future Enhancements

Potential features for future versions:

- [ ] Comments on ratings
- [ ] Admin dashboard for viewing all feedback
- [ ] Push notifications for service updates
- [ ] Export ratings to CSV/PDF
- [ ] Multi-language support (Sinhala/Tamil/English)
- [ ] Dark mode theme
- [ ] User profile management
- [ ] Service comparison charts
- [ ] Historical rating trends
- [ ] Image uploads for services

## Testing

Run unit tests:

```bash
flutter test
```

## Troubleshooting

### Database Issues

If you encounter database errors:

1. Uninstall the app completely
2. Reinstall to create a fresh database

### Build Errors

If you get build errors:

1. Run `flutter clean`
2. Run `flutter pub get`
3. Try building again

### Connection Issues

The app works completely offline as it uses local SQLite database.

## Contributing

To contribute to this project:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is created for educational purposes for the University of Ruhuna.

## Support

For issues or questions:

- Check the troubleshooting section
- Review the code documentation
- Contact the development team

## Version History

- **v1.0.0** (January 2026)
  - Initial release
  - 7 services with sub-services
  - User authentication
  - Rating system
  - Trending dashboard

---

**Developed for University of Ruhuna**

_Empowering students and staff to improve university services through feedback_
