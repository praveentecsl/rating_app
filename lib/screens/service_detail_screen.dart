import 'package:flutter/material.dart';
import '../models/rating.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/rating_service.dart';
import 'login_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> service;
  final bool isGuest;

  const ServiceDetailScreen({
    super.key,
    required this.service,
    this.isGuest = false,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final Map<String, double> _ratings = {}; // criteriaName -> rating value
  bool _isSaving = false;
  final RatingService _ratingService = RatingService();
  final AuthService _authService = AuthService();
  User? _currentUser;

  // Rating pool data
  Map<String, dynamic> _commonPoolStats = {};
  Map<String, dynamic> _userContribution = {};
  bool _isLoadingStats = true;

  // Hardcoded sub-services data
  static final Map<int, List<Map<String, dynamic>>> _subServicesData = {
    1: [
      {
        'id': 1,
        'name': 'Food Quality',
        'description': 'Quality and taste of food',
      },
      {
        'id': 2,
        'name': 'Seating Availability',
        'description': 'Availability of seats',
      },
      {
        'id': 3,
        'name': 'Queue Management',
        'description': 'Waiting time and queue efficiency',
      },
      {
        'id': 4,
        'name': 'Comfortability',
        'description': 'Overall comfort and ambiance',
      },
      {
        'id': 5,
        'name': 'Animal Interruptions',
        'description': 'Issues with animals in dining areas',
      },
    ],
    2: [
      {
        'id': 6,
        'name': 'Response Time',
        'description': 'Speed of security response',
      },
      {
        'id': 7,
        'name': 'Visibility',
        'description': 'Security presence on campus',
      },
      {
        'id': 8,
        'name': 'Safety Feeling',
        'description': 'How safe students feel',
      },
      {
        'id': 9,
        'name': 'Equipment Quality',
        'description': 'Quality of security equipment',
      },
    ],
    3: [
      {
        'id': 10,
        'name': 'Book Availability',
        'description': 'Availability of required books',
      },
      {
        'id': 11,
        'name': 'Study Space',
        'description': 'Quality and availability of study areas',
      },
      {
        'id': 12,
        'name': 'Noise Level',
        'description': 'Quietness of the library',
      },
      {
        'id': 13,
        'name': 'Staff Helpfulness',
        'description': 'Library staff assistance',
      },
      {
        'id': 14,
        'name': 'Internet Access',
        'description': 'WiFi and computer access',
      },
    ],
    4: [
      {
        'id': 15,
        'name': 'Seating Comfort',
        'description': 'Comfort of chairs and desks',
      },
      {
        'id': 16,
        'name': 'Audio/Visual Equipment',
        'description': 'Quality of AV equipment',
      },
      {'id': 17, 'name': 'Cleanliness', 'description': 'Cleanliness of halls'},
      {
        'id': 18,
        'name': 'Ventilation',
        'description': 'Air quality and temperature',
      },
    ],
    5: [
      {
        'id': 19,
        'name': 'Maintenance',
        'description': 'Regular upkeep of gardens',
      },
      {
        'id': 20,
        'name': 'Aesthetic Appeal',
        'description': 'Visual beauty of campus',
      },
      {
        'id': 21,
        'name': 'Cleanliness',
        'description': 'Cleanliness of outdoor areas',
      },
    ],
    6: [
      {
        'id': 22,
        'name': 'Room Condition',
        'description': 'State of hostel rooms',
      },
      {
        'id': 23,
        'name': 'Bathroom Facilities',
        'description': 'Quality of bathrooms',
      },
      {
        'id': 24,
        'name': 'Common Areas',
        'description': 'Quality of shared spaces',
      },
      {'id': 25, 'name': 'Security', 'description': 'Hostel security measures'},
      {
        'id': 26,
        'name': 'Internet Connection',
        'description': 'WiFi availability and speed',
      },
    ],
    7: [
      {
        'id': 27,
        'name': 'Equipment Quality',
        'description': 'Quality of sports equipment',
      },
      {
        'id': 28,
        'name': 'Facility Condition',
        'description': 'State of sports facilities',
      },
      {
        'id': 29,
        'name': 'Availability',
        'description': 'Access to sports facilities',
      },
      {
        'id': 30,
        'name': 'Coaching Support',
        'description': 'Quality of coaching',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeRatings();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!widget.isGuest) {
      final user = await _authService.getCurrentUserData();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    }
    _loadRatingStats();
  }

  Future<void> _loadRatingStats() async {
    setState(() => _isLoadingStats = true);

    try {
      final serviceId = widget.service['serviceId'] as int;
      final commonStats = await _ratingService.getServiceRatingStats(serviceId);

      Map<String, dynamic> userStats = {};
      if (!widget.isGuest && _currentUser?.userId != null) {
        userStats = await _ratingService.getUserServiceRating(
          _currentUser!.userId!,
          serviceId,
        );
      }

      if (mounted) {
        setState(() {
          _commonPoolStats = commonStats;
          _userContribution = userStats;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('Error loading rating stats: $e');
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  void _initializeRatings() {
    final subServices = _subServicesData[widget.service['serviceId']] ?? [];
    for (var subService in subServices) {
      _ratings[subService['name']] = 5.0; // Default rating is 5
    }
  }

  Future<void> _saveAllRatings() async {
    if (widget.isGuest || _currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to submit ratings.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final serviceId = widget.service['serviceId'] as int;
      final subServices = _subServicesData[serviceId] ?? [];

      for (var entry in _ratings.entries) {
        final subserviceName = entry.key;
        final score = entry.value.round();

        final subservice = subServices.firstWhere(
          (s) => s['name'] == subserviceName,
          orElse: () => {},
        );

        if (subservice.isEmpty) {
          print('Could not find subservice with name: $subserviceName');
          continue;
        }

        final rating = Rating(
          userId: _currentUser!.userId!,
          serviceId: serviceId,
          subserviceId: subservice['id'],
          score: score,
          timestamp: DateTime.now(),
        );

        await _ratingService.submitRating(rating);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✓ Thank you for your ratings! Your contribution helps improve services.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        setState(() {
          _isSaving = false;
        });

        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      print('Error saving ratings: $e');
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving ratings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getRatingColor(double rating) {
    if (rating >= 8) return Colors.green;
    if (rating >= 6) return Colors.lightGreen;
    if (rating >= 4) return Colors.orange;
    if (rating >= 2) return Colors.deepOrange;
    return Colors.red;
  }

  String _getRatingLabel(double rating) {
    if (rating >= 9) return 'Excellent';
    if (rating >= 7) return 'Good';
    if (rating >= 5) return 'Average';
    if (rating >= 3) return 'Below Average';
    return 'Poor';
  }

  Widget _buildRatingPoolsCard() {
    final commonAvg = (_commonPoolStats['averageRating'] ?? 0.0) as num;
    final totalRatings = (_commonPoolStats['ratingCount'] ?? 0) as int;
    final userRatingsGiven = (_userContribution['ratings_given'] ?? 0) as int;
    final userAvg = _userContribution['user_average'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade200, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pool, color: Colors.indigo.shade700, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Rating Pools',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoadingStats)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPoolItem(
                    'Overall Average',
                    commonAvg.toStringAsFixed(1),
                    Icons.public,
                    Colors.indigo,
                  ),
                  _buildPoolItem(
                    'Total Ratings',
                    totalRatings.toString(),
                    Icons.bar_chart,
                    Colors.teal,
                  ),
                  if (!widget.isGuest)
                    _buildPoolItem(
                      'Your Average',
                      userAvg != null ? userAvg.toStringAsFixed(1) : 'N/A',
                      Icons.person,
                      Colors.amber,
                    ),
                ],
              ),
            if (!widget.isGuest && userRatingsGiven > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  'You have contributed $userRatingsGiven ratings to this service.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoolItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceName = widget.service['serviceName'] as String;
    final serviceId = widget.service['serviceId'] as int;
    final subServices = _subServicesData[serviceId] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(serviceName), elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildRatingPoolsCard(),
                const SizedBox(height: 16),
                Text(
                  widget.isGuest
                      ? 'Rating Criteria'
                      : 'Rate the following criteria:',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.isGuest)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'This is a read-only view for guests.',
                                style: TextStyle(color: Colors.blue.shade800),
                              ),
                              InkWell(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                ),
                                child: Text(
                                  'Login to rate these criteria and contribute.',
                                  style: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                ...subServices.map((sub) {
                  final subName = sub['name'] as String;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sub['description'] as String,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: _getRatingColor(
                                _ratings[subName]!,
                              ),
                              inactiveTrackColor: _getRatingColor(
                                _ratings[subName]!,
                              ).withOpacity(0.3),
                              thumbColor: _getRatingColor(_ratings[subName]!),
                            ),
                            child: Slider(
                              value: _ratings[subName]!,
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: _getRatingLabel(_ratings[subName]!),
                              onChanged: widget.isGuest
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _ratings[subName] = value;
                                      });
                                    },
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${_ratings[subName]!.toStringAsFixed(0)} / 10',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          if (!widget.isGuest)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAllRatings,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : const Text('Submit All Ratings'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
