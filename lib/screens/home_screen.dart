import 'package:flutter/material.dart';
import 'service_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      'serviceName': 'Accommodation',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('University of Ruhuna Rating App'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
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
              padding: const EdgeInsets.all(24),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to University of Ruhuna!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rate and review university services',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // All Services
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'All Services',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final serviceData = _services[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceDetailScreen(
                                  serviceId: serviceData['serviceId'],
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Icon
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getServiceIcon(
                                        serviceData['imagePath']),
                                    size: 32,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Service Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        serviceData['serviceName'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (serviceData['description'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            serviceData['description'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Arrow
                                const Icon(Icons.arrow_forward_ios, size: 20),
                              ],
                            ),
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
}
