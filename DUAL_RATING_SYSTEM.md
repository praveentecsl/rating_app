# Dual Rating Pool System - Implementation Guide

## Overview

The University of Ruhuna Rating App now implements a **Dual Rating Pool System** that tracks both individual user contributions and overall service ratings. This system enables rapid detection of service quality issues and provides transparency about how each user's feedback contributes to service improvements.

## System Architecture

### 1. Common Rating Pool
- **Purpose**: Aggregates ALL user ratings for each service
- **Calculation**: Average of all ratings from all users
- **Updates**: Immediately when any user submits a rating
- **Visibility**: Shown to all users in the service detail screen

### 2. Personal Rating Pool
- **Purpose**: Tracks individual user's rating history and contributions
- **Calculation**: User-specific average for each service
- **Updates**: When the user submits their ratings
- **Visibility**: Shown in user profile and service detail screens

## Key Features

### For All Users

#### 1. User Profile Screen (`user_profile_screen.dart`)
Access via the profile icon (👤) in the home screen app bar.

**Displays:**
- User information (name, university ID, role)
- **Contribution Statistics**:
  - Total number of ratings given
  - Personal average rating score
- **Rating History**:
  - All services/subservices rated
  - Scores given
  - Comments (if any)
  - Timestamps

#### 2. Service Detail Screen - Rating Pools Display
When rating a service, users see:

**Common Pool Section:**
- Overall average score from all users
- Total number of ratings
- Visual indicators (star rating with color coding)

**Personal Contribution Section:**
- User's average rating for this service
- Number of ratings the user has given
- Contribution message

**Color Coding:**
- 🟢 Green (8-10): Excellent
- 🟠 Orange (5-7): Average/Good
- 🔴 Red (0-4): Poor/Below Average

#### 3. Real-time Impact
- When users rate services, their ratings immediately:
  - Update the common pool average
  - Appear in their personal rating history
  - Contribute to trend detection

### For Administrators

#### Admin Monitoring Dashboard (`admin_monitoring_screen.dart`)
Access via the dashboard icon (📊) in the home screen app bar (admin users only).

**Features:**

1. **Rating Drop Alerts**
   - Detects significant rating drops in the last 24 hours
   - Severity levels:
     - 🔴 **CRITICAL**: Drop of 4.0+ points
     - 🟠 **HIGH**: Drop of 3.0-3.9 points
     - 🟡 **MODERATE**: Drop of 2.0-2.9 points
   - Shows previous vs. recent averages
   - Provides recommended actions

2. **Service Rankings**
   - Lists all services ranked by average rating
   - Shows total rating count per service
   - Visual rank indicators (🥇🥈🥉)
   - Color-coded scores

## Database Schema Enhancements

### New Methods in `database_helper.dart`

```dart
// Get user's rating history with service details
Future<List<Map<String, dynamic>>> getUserRatingsWithDetails(int userId)

// Get user's contribution statistics
Future<Map<String, dynamic>> getUserContributionStats(int userId)

// Get recent rating trends for a service
Future<List<Map<String, dynamic>>> getRecentServiceRatingTrend(
  int serviceId,
  int daysBack,
)

// Detect sudden rating drops (for alerts)
Future<List<Map<String, dynamic>>> detectRatingDrops(
  double dropThreshold,
  int hoursBack,
)

// Get user's rating contribution for a specific service
Future<Map<String, dynamic>> getUserServiceRating(
  int userId,
  int serviceId,
)
```

## Use Case: Issue Detection Flow

### Scenario: Canteen Food Quality Problem

1. **Issue Occurs**: Food quality drops due to supply problem
2. **Users React**: Multiple students rate food quality as poor (0-3)
3. **System Response**:
   - Common pool average drops from 7.5 to 4.2
   - Each user's contribution is recorded in their personal pool
   - System detects 3.3-point drop in 24 hours

4. **Admin Alert**:
   - Dashboard shows CRITICAL alert for Food Service
   - Displays: "Previous Avg: 7.5 → Recent Avg: 4.2"
   - Shows 15 recent poor ratings

5. **Action Taken**:
   - Admin investigates based on alert
   - Issue is identified and resolved
   - Future ratings improve, reflected in both pools

## Benefits

### 1. Transparency
- Users see how their feedback contributes to overall ratings
- Clear visibility of both personal and collective opinions

### 2. Accountability
- Users' rating history is tracked
- Personal pool shows individual contribution patterns

### 3. Rapid Response
- Sudden drops trigger immediate alerts
- Authorities can take quick corrective action
- Issues are addressed before they escalate

### 4. Engagement
- Users feel their feedback matters
- Visual representation of contribution encourages participation
- Historical data shows impact over time

### 5. Data-Driven Decisions
- Trends analysis helps identify patterns
- Service rankings guide resource allocation
- Historical data supports long-term planning

## Technical Implementation Details

### Rating Submission Flow

```
User rates service → 
  Save to Ratings table → 
    Update common pool (automatic via SQL AVG) → 
      Update user's personal pool → 
        Show confirmation → 
          Return to home
```

### Alert Detection Logic

```sql
-- Compares average ratings from last 24 hours vs. previous period
-- Triggers alert if:
--   1. Drop > threshold (e.g., 2.0 points)
--   2. Recent ratings count >= 3 (minimum for significance)
--   3. Both periods have data
```

### Data Refresh Strategy

- **Service Detail Screen**: Loads stats when opened
- **User Profile**: Loads on screen open, refreshable by pull-down
- **Admin Dashboard**: Loads on open, manual refresh button
- **Common Pool**: Auto-calculated via SQL aggregate functions

## Security & Privacy

- Users can only see their own rating history
- Admins see aggregate data and alerts
- Individual ratings are anonymous in common pool
- Personal pool data is private to each user

## Future Enhancements

Potential additions:
1. Email/push notifications for critical alerts
2. Downloadable reports for administrators
3. Rating trends graphs and charts
4. Comparison between time periods
5. Department-wise filtering
6. Export functionality for data analysis

## Testing the System

### As a Regular User:
1. Log in to the app
2. Click profile icon to view your contribution stats
3. Rate a service
4. Return to profile to see your updated history
5. View service detail to see both rating pools

### As an Administrator:
1. Log in with admin credentials
2. Click dashboard icon in app bar
3. View rating drop alerts (if any)
4. Check service rankings
5. Tap any service to view details
6. Use refresh button to reload data

## Support & Troubleshooting

### Common Issues:

**Q: Rating pools not updating?**
A: Pull down to refresh on profile/monitoring screens

**Q: Admin dashboard not visible?**
A: Only users with role='admin' can see monitoring dashboard

**Q: Personal contribution shows 0?**
A: User hasn't rated any services yet

**Q: No alerts showing?**
A: Good news! No significant rating drops detected

## Conclusion

The Dual Rating Pool System provides a comprehensive, transparent, and responsive feedback mechanism that benefits both users and administrators. It empowers students and staff to contribute meaningfully to service improvements while enabling authorities to respond quickly to emerging issues.

---

**Implementation Date**: January 2026  
**Version**: 1.0  
**Status**: ✅ Complete
