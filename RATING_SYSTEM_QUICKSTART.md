# Quick Start: Dual Rating System

## 🎯 What's New

Your University of Ruhuna Rating App now has a **Dual Rating Pool System** that:
- ✅ Tracks your personal rating contributions
- ✅ Shows how ratings affect the overall service scores
- ✅ Alerts administrators to sudden quality drops
- ✅ Helps authorities take quick action on issues

## 🚀 Quick Access

### For Students & Staff

1. **View Your Profile**
   - Tap the 👤 (profile) icon in the app bar
   - See all your ratings and contribution stats

2. **Rate Services**
   - Select any service
   - See both **Common Pool** (all users) and **Your Contribution**
   - Submit ratings - they update both pools immediately

### For Administrators

1. **Monitoring Dashboard**
   - Tap the 📊 (dashboard) icon in the app bar (admin only)
   - View rating drop alerts
   - See service rankings

## 📊 What You'll See

### User Profile Screen
```
┌─────────────────────────┐
│  My Contribution        │
│  Total Ratings: 12      │
│  Average Score: 7.5     │
│                         │
│  My Rating History      │
│  - Food Quality: 8      │
│  - Library: 9           │
│  - Security: 7          │
└─────────────────────────┘
```

### Service Detail - Rating Pools
```
┌─────────────────────────────┐
│  Rating Pools               │
│                             │
│  Common Pool (All Users)    │
│  ⭐ 7.5/10 | 150 ratings    │
│                             │
│  My Contribution            │
│  ⭐ 8.0/10 | 3 ratings      │
│                             │
│  Your ratings help identify │
│  issues quickly!            │
└─────────────────────────────┘
```

### Admin Dashboard - Alerts
```
┌─────────────────────────────┐
│  🚨 Rating Drop Alerts      │
│                             │
│  CRITICAL: Food Service     │
│  7.5 → 4.2 (-3.3 points)    │
│  15 recent ratings          │
│                             │
│  Action: Investigate now    │
└─────────────────────────────┘
```

## 💡 How It Works

1. **You rate** → Your score saved
2. **Common pool updates** → All users' average changes
3. **Your contribution tracked** → Shows in your profile
4. **System monitors** → Detects sudden drops
5. **Alerts admins** → Quick response to issues

## 🎨 Color Indicators

- 🟢 **Green (8-10)**: Excellent
- 🟠 **Orange (5-7)**: Average/Good  
- 🔴 **Red (0-4)**: Poor - Action Needed

## 📱 New Screens Added

1. **User Profile Screen** - View your rating history
2. **Admin Monitoring Screen** - Dashboard for administrators
3. **Enhanced Service Detail** - Shows both rating pools

## 🔧 Technical Details

**Files Modified:**
- `lib/db/database_helper.dart` - Added rating statistics methods
- `lib/screens/home_screen.dart` - Added profile & dashboard access
- `lib/screens/service_detail_screen.dart` - Added rating pools display

**Files Created:**
- `lib/screens/user_profile_screen.dart` - User profile
- `lib/screens/admin_monitoring_screen.dart` - Admin dashboard
- `DUAL_RATING_SYSTEM.md` - Complete documentation

## 🧪 Test Scenarios

### Scenario 1: Rate a Service
1. Open app and select "Food (Canteens)"
2. See current rating pools
3. Rate all food aspects
4. Submit ratings
5. Check your profile to see updated history

### Scenario 2: View Your Impact
1. Rate multiple services
2. Open your profile
3. See total contributions and average score
4. View rating history with timestamps

### Scenario 3: Admin Monitoring (Admin Only)
1. Log in as admin
2. Click dashboard icon
3. View any rating drop alerts
4. Check service rankings
5. Tap service to see details

## ❓ FAQ

**Q: Can others see my individual ratings?**  
A: No, ratings are anonymous in the common pool. Only you see your personal history.

**Q: How quickly do ratings update?**  
A: Immediately! Both pools update as soon as you submit.

**Q: What triggers an alert?**  
A: A drop of 2+ points in 24 hours with at least 3 recent ratings.

**Q: Can I change my ratings?**  
A: Yes! Rating the same service again updates your previous rating.

## 📚 Full Documentation

See `DUAL_RATING_SYSTEM.md` for complete details including:
- Architecture overview
- Database schema
- Use case examples
- Troubleshooting guide

## ✨ Benefits

**For Users:**
- See your impact on service improvement
- Track your rating history
- Transparent feedback system

**For Administrators:**
- Early warning system for issues
- Data-driven decision making
- Quick response capability

---

**Ready to try it?** Run the app and start rating! Your feedback makes a difference. 🎓
