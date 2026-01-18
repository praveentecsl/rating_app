import 'package:flutter/material.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  Map<int, double> _ratings = {}; // subserviceId -> rating value
  bool _isSaving = false;

  // Hardcoded services and sub-services data
  static final Map<int, Map<String, dynamic>> _servicesData = {
    1: {
      'serviceName': 'Food (Canteens)',
      'description': 'Campus dining facilities',
      'subServices': [
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
    },
    2: {
      'serviceName': 'Security',
      'description': 'Student security services',
      'subServices': [
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
    },
    3: {
      'serviceName': 'Library',
      'description': 'University library facilities',
      'subServices': [
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
    },
    4: {
      'serviceName': 'Lecture Halls',
      'description': 'Classroom and lecture hall conditions',
      'subServices': [
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
        {
          'id': 17,
          'name': 'Cleanliness',
          'description': 'Cleanliness of halls',
        },
        {
          'id': 18,
          'name': 'Ventilation',
          'description': 'Air quality and temperature',
        },
      ],
    },
    5: {
      'serviceName': 'Gardening',
      'description': 'Campus landscaping and environment',
      'subServices': [
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
    },
    6: {
      'serviceName': 'Accommodation',
      'description': 'Hostel facilities',
      'subServices': [
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
        {
          'id': 25,
          'name': 'Security',
          'description': 'Hostel security measures',
        },
        {
          'id': 26,
          'name': 'Internet Connection',
          'description': 'WiFi availability and speed',
        },
      ],
    },
    7: {
      'serviceName': 'Sports',
      'description': 'Sports facilities and activities',
      'subServices': [
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
    },
  };

  @override
  void initState() {
    super.initState();
    _initializeRatings();
  }

  void _initializeRatings() {
    final serviceData = _servicesData[widget.serviceId];
    if (serviceData != null) {
      final subServices = serviceData['subServices'] as List;
      for (var subService in subServices) {
        _ratings[subService['id']] = 5.0; // Default rating is 5
      }
    }
  }

  Future<void> _saveAllRatings() async {
    setState(() {
      _isSaving = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Thank you for your ratings!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        _isSaving = false;
      });

      // Wait a moment then go back
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Navigator.of(context).pop(true);
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

  @override
  Widget build(BuildContext context) {
    final serviceData = _servicesData[widget.serviceId];

    if (serviceData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Service Not Found')),
        body: const Center(child: Text('Service not found')),
      );
    }

    final serviceName = serviceData['serviceName'] as String;
    final description = serviceData['description'] as String;
    final subServices = serviceData['subServices'] as List;

    return Scaffold(
      appBar: AppBar(title: Text(serviceName)),
      body: Column(
        children: [
          // Service Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Rate each aspect from 0 (Poor) to 10 (Excellent)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sub-services list with sliders
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subServices.length,
              itemBuilder: (context, index) {
                final subService = subServices[index];
                final subserviceId = subService['id'] as int;
                final subserviceName = subService['name'] as String;
                final subserviceDescription =
                    subService['description'] as String;
                final currentRating = _ratings[subserviceId] ?? 5.0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sub-service name
                        Text(
                          subserviceName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Description
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 8),
                          child: Text(
                            subserviceDescription,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Rating display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rating: ${currentRating.toStringAsFixed(1)}/10',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getRatingColor(currentRating),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getRatingColor(
                                  currentRating,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getRatingLabel(currentRating),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _getRatingColor(currentRating),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: _getRatingColor(currentRating),
                            inactiveTrackColor: Colors.grey[300],
                            thumbColor: _getRatingColor(currentRating),
                            overlayColor: _getRatingColor(
                              currentRating,
                            ).withOpacity(0.2),
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 12,
                            ),
                          ),
                          child: Slider(
                            value: currentRating,
                            min: 0,
                            max: 10,
                            divisions: 100,
                            label: currentRating.toStringAsFixed(1),
                            onChanged: (value) {
                              setState(() {
                                _ratings[subserviceId] = value;
                              });
                            },
                          ),
                        ),

                        // Min/Max labels
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Poor (0)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Excellent (10)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
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
          ),

          // Save Button
          // Save Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAllRatings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Submit Ratings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
