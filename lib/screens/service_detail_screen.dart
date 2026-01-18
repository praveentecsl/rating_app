import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/service.dart';
import '../models/subservice.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  Service? _service;
  List<SubService> _subServices = [];
  Map<int, double> _ratings = {}; // subserviceId -> rating value
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadServiceDetails();
  }

  Future<void> _loadServiceDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final service = await DatabaseHelper.instance.getServiceById(
        widget.serviceId,
      );
      final subServices = await DatabaseHelper.instance
          .getSubServicesByServiceId(widget.serviceId);

      // Initialize ratings with default value of 5
      Map<int, double> ratings = {};

      for (var subService in subServices) {
        ratings[subService.subserviceId!] = 5.0; // Default to 5
      }

      setState(() {
        _service = service;
        _subServices = subServices;
        _ratings = ratings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading service: $e')));
      }
    }
  }

  Future<void> _saveRating(int subserviceId, double score) async {
    // For now, just update local state
    // In future, can add user authentication and save to database
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating updated'),
          duration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  Future<void> _saveAllRatings() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your ratings!'),
            duration: Duration(seconds: 2),
          ),
        );

        // Wait a moment then go back
        await Future.delayed(const Duration(seconds: 1));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Color _getRatingColor(double rating) {
    if (rating >= 8) return Colors.green;
    if (rating >= 6) return Colors.orange;
    if (rating >= 4) return Colors.deepOrange;
    return Colors.red;
  }

  String _getRatingLabel(double rating) {
    if (rating >= 9) return 'Excellent';
    if (rating >= 8) return 'Very Good';
    if (rating >= 7) return 'Good';
    if (rating >= 6) return 'Above Average';
    if (rating >= 5) return 'Average';
    if (rating >= 4) return 'Below Average';
    if (rating >= 3) return 'Poor';
    return 'Very Poor';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_service?.serviceName ?? 'Service Details')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _service == null
          ? const Center(child: Text('Service not found'))
          : Column(
              children: [
                // Service Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.rate_review,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _service!.serviceName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_service!.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _service!.description!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),

                // Sub-services List
                Expanded(
                  child: _subServices.isEmpty
                      ? const Center(child: Text('No sub-services available'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _subServices.length,
                          itemBuilder: (context, index) {
                            final subService = _subServices[index];
                            final subserviceId = subService.subserviceId!;
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
                                      subService.subserviceName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    // Description
                                    if (subService.description != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4,
                                          bottom: 8,
                                        ),
                                        child: Text(
                                          subService.description!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),

                                    const SizedBox(height: 16),

                                    // Rating value display
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _getRatingLabel(currentRating),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: _getRatingColor(
                                              currentRating,
                                            ),
                                            fontWeight: FontWeight.bold,
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '${currentRating.toStringAsFixed(0)}/10',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: _getRatingColor(
                                                currentRating,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Slider
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 8,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 12,
                                        ),
                                        overlayShape:
                                            const RoundSliderOverlayShape(
                                              overlayRadius: 20,
                                            ),
                                        valueIndicatorShape:
                                            const PaddleSliderValueIndicatorShape(),
                                        valueIndicatorTextStyle:
                                            const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                      ),
                                      child: Slider(
                                        value: currentRating,
                                        min: 0,
                                        max: 10,
                                        divisions: 10,
                                        label: currentRating.round().toString(),
                                        activeColor: _getRatingColor(
                                          currentRating,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _ratings[subserviceId] = value;
                                          });
                                        },
                                        onChangeEnd: (value) {
                                          _saveRating(subserviceId, value);
                                        },
                                      ),
                                    ),

                                    // Scale labels
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '0 - Poor',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          '10 - Excellent',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Save All Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveAllRatings,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'SAVE ALL RATINGS & RETURN',
                                style: TextStyle(fontSize: 16),
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
