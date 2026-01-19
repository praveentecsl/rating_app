import 'package:flutter/material.dart';
import 'dart:ui';
import 'service_detail_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../services/rating_logic.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RatingService? _ratingService;
  Map<int, Map<String, dynamic>> _serviceRatings = {};
  List<Map<String, dynamic>> _trendingServices = [];
  bool _isLoadingRatings = true;

  @override
  void initState() {
    super.initState();
    // Initialize RatingService after widget is built to avoid Firebase timing issues
    Future.microtask(() {
      if (mounted) {
        setState(() {
          _ratingService = RatingService();
        });
        _loadServiceRatings();
      }
    });
  }

  Future<void> _loadServiceRatings() async {
    if (_ratingService == null) return;

    try {
      final ratings = <int, Map<String, dynamic>>{};

      for (var service in _services) {
        final serviceId = service['serviceId'] as int;
        final stats = await _ratingService!.getServiceRatingStats(serviceId);
        ratings[serviceId] = stats;
      }

      // Get trending services (top 3)
      final allServiceIds = _services
          .map((s) => s['serviceId'] as int)
          .toList();
      final trendingData = await _ratingService!.getTrendingServices(
        allServiceIds,
      );

      // Map trending data back to full service info
      final trending = trendingData.take(3).map((tData) {
        final service = _services.firstWhere(
          (s) => s['serviceId'] == tData['serviceId'],
        );
        return {...service, ...tData};
      }).toList();

      if (mounted) {
        setState(() {
          _serviceRatings = ratings;
          _trendingServices = trending;
          _isLoadingRatings = false;
        });
      }
    } catch (e) {
      print('Error loading ratings: $e');
      if (mounted) {
        setState(() {
          _isLoadingRatings = false;
        });
      }
    }
  }

  // Hardcoded services list for immediate loading
  static final List<Map<String, dynamic>> _services = [
    {
      'serviceId': 1,
      'serviceName': 'Food (Canteens)',
      'description': 'Campus dining facilities',
      'imagePath': 'canteen',
    },
    {
      'serviceId': 2,
      'serviceName': 'Security',
      'description': 'Student security services',
      'imagePath': 'security',
    },
    {
      'serviceId': 3,
      'serviceName': 'Library',
      'description': 'University library facilities',
      'imagePath': 'library',
    },
    {
      'serviceId': 4,
      'serviceName': 'Lecture Halls',
      'description': 'Classroom and lecture hall conditions',
      'imagePath': 'lecture_hall',
    },
    {
      'serviceId': 5,
      'serviceName': 'Gardening',
      'description': 'Campus landscaping and environment',
      'imagePath': 'gardening',
    },
    {
      'serviceId': 6,
      'serviceName': 'Hostel Facilities',
      'description': 'Hostel facilities',
      'imagePath': 'hostel',
    },
    {
      'serviceId': 7,
      'serviceName': 'Sports',
      'description': 'Sports facilities and activities',
      'imagePath': 'sports',
    },
  ];

  IconData _getServiceIcon(String? imagePath) {
    switch (imagePath) {
      case 'canteen':
        return Icons.restaurant;
      case 'security':
        return Icons.security;
      case 'library':
        return Icons.library_books;
      case 'lecture_hall':
        return Icons.meeting_room;
      case 'gardening':
        return Icons.park;
      case 'hostel':
        return Icons.hotel;
      case 'sports':
        return Icons.sports_soccer;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('University of Ruhuna'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // Show confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                await authService.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Logo and Welcome
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // University Logo with fallback
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to icon if image not found
                          return Icon(
                            Icons.school,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Service Rating Portal',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Rate and improve university services',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Stats Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        Icons.category,
                        '${_services.length}',
                        'Services',
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      _buildStatItem(
                        context,
                        Icons.rate_review,
                        '30+',
                        'Aspects',
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      _buildStatItem(
                        context,
                        Icons.people,
                        'All',
                        'Stakeholders',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Trending Services Section
            if (_trendingServices.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.amber, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Trending Services',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_trendingServices.length, (index) {
                      final service = _trendingServices[index];
                      final medal = index == 0
                          ? '🥇'
                          : (index == 1 ? '🥈' : '🥉');
                      final stats = _serviceRatings[service['serviceId']];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            child: Text(
                              medal,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          title: Text(
                            service['serviceName'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(service['description']),
                          trailing: stats != null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${(stats['percentage'] as double).toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${stats['totalRatings']} ratings',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceDetailScreen(
                                  serviceId: service['serviceId'],
                                ),
                              ),
                            ).then((_) => _loadServiceRatings());
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

            // All Services Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.list_alt,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'All Services',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap any service to rate its aspects',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio:
                              0.85, // Further adjusted for shorter cards
                        ),
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final serviceData = _services[index];

                      return Card(
                        elevation: 2, // Reduced elevation
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Softer corners
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceDetailScreen(
                                  serviceId: serviceData['serviceId'],
                                ),
                              ),
                            ).then((_) => _loadServiceRatings());
                          },
                          child: Stack(
                            children: [
                              // Background Image with Blur
                              Positioned.fill(
                                child: Image.asset(
                                  'assets/images/${serviceData['imagePath']}.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback gradient if image not found
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(0.7),
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Blur Effect
                              Positioned.fill(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 1, // Reduced blur
                                    sigmaY: 1,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.2),
                                          Colors.black.withOpacity(0.5),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Content
                              Padding(
                                padding: const EdgeInsets.all(
                                  8,
                                ), // Reduced padding
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Service Icon
                                    Container(
                                      padding: const EdgeInsets.all(
                                        12,
                                      ), // Reduced padding
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.15,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _getServiceIcon(
                                          serviceData['imagePath'],
                                        ),
                                        size: 28, // Reduced icon size
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Service Name
                                    Text(
                                      serviceData['serviceName'],
                                      style: const TextStyle(
                                        fontSize: 13, // Reduced font size
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    // Rating display
                                    _buildRatingDisplay(
                                      serviceData['serviceId'],
                                    ),
                                    const Spacer(),
                                    // Rate button
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade600,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star_rate,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Rate', // Shortened text
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildRatingDisplay(int serviceId) {
    if (_isLoadingRatings) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    final stats = _serviceRatings[serviceId];
    if (stats == null || stats['totalRatings'] == 0) {
      return const Text(
        'No ratings yet',
        style: TextStyle(
          fontSize: 10,
          color: Colors.white70,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final percentage = stats['percentage'] as double;
    final totalRatings = stats['totalRatings'] as int;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($totalRatings)',
            style: const TextStyle(fontSize: 9, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
