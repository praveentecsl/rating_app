import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'service_detail_screen.dart';

class AdminMonitoringScreen extends StatefulWidget {
  const AdminMonitoringScreen({super.key});

  @override
  State<AdminMonitoringScreen> createState() => _AdminMonitoringScreenState();
}

class _AdminMonitoringScreenState extends State<AdminMonitoringScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _ratingDrops = [];
  List<Map<String, dynamic>> _trendingServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonitoringData();
  }

  Future<void> _loadMonitoringData() async {
    setState(() => _isLoading = true);

    try {
      // Detect services with significant rating drops in the last 24 hours
      // A drop of 2.0 or more is considered significant
      final drops = await _dbHelper.detectRatingDrops(2.0, 24);

      // Get trending services
      final trending = await _dbHelper.getTrendingServices();

      setState(() {
        _ratingDrops = drops;
        _trendingServices = trending;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading monitoring data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Monitoring'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadMonitoringData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMonitoringData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildAlertsSection(),
                  const SizedBox(height: 24),
                  _buildTrendingServicesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade700,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              'Rating Drop Alerts',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Services with significant rating drops in the last 24 hours',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        if (_ratingDrops.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.green[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No critical rating drops detected',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All services are maintaining stable ratings',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...(_ratingDrops.map((drop) => _buildAlertCard(drop))),
      ],
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> drop) {
    final serviceName = drop['service_name'] as String;
    final serviceId = drop['service_id'] as int;
    final recentAvg = (drop['recent_avg'] ?? 0.0) as num;
    final previousAvg = (drop['previous_avg'] ?? 0.0) as num;
    final recentCount = drop['recent_count'] as int;
    final dropAmount = previousAvg - recentAvg;

    // Determine severity
    Color severityColor;
    String severityLabel;
    IconData severityIcon;

    if (dropAmount >= 4.0) {
      severityColor = Colors.red;
      severityLabel = 'CRITICAL';
      severityIcon = Icons.error;
    } else if (dropAmount >= 3.0) {
      severityColor = Colors.orange;
      severityLabel = 'HIGH';
      severityIcon = Icons.warning;
    } else {
      severityColor = Colors.amber;
      severityLabel = 'MODERATE';
      severityIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailScreen(serviceId: serviceId),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: severityColor, width: 6)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: severityColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(severityIcon, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            severityLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        serviceName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatBox(
                        'Previous Avg',
                        previousAvg.toStringAsFixed(1),
                        Colors.blue.shade100,
                        Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatBox(
                        'Recent Avg',
                        recentAvg.toStringAsFixed(1),
                        severityColor.withOpacity(0.2),
                        severityColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_down,
                            color: severityColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Drop: ${dropAmount.toStringAsFixed(1)} points',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: severityColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$recentCount recent ratings',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Recommended Action: Investigate issues and take corrective measures immediately',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(
    String label,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_up, color: Colors.green.shade700, size: 32),
            const SizedBox(width: 12),
            const Text(
              'Service Rankings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Services ranked by average user ratings',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        if (_trendingServices.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('No rating data available')),
            ),
          )
        else
          ..._trendingServices.asMap().entries.map((entry) {
            final index = entry.key;
            final service = entry.value;
            return _buildServiceRankCard(service, index + 1);
          }),
      ],
    );
  }

  Widget _buildServiceRankCard(Map<String, dynamic> service, int rank) {
    final serviceName = service['service_name'] as String;
    final serviceId = service['service_id'] as int;
    final avgScore = (service['average_score'] ?? 0.0) as num;
    final ratingCount = service['rating_count'] as int;

    Color rankColor;
    if (rank <= 3) {
      rankColor = [Colors.amber, Colors.grey, Colors.brown][rank - 1];
    } else {
      rankColor = Colors.blue.shade700;
    }

    Color scoreColor;
    if (avgScore >= 8) {
      scoreColor = Colors.green;
    } else if (avgScore >= 6) {
      scoreColor = Colors.lightGreen;
    } else if (avgScore >= 4) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailScreen(serviceId: serviceId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: rankColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: rankColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$ratingCount ratings',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: scoreColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      avgScore.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
