class SubService {
  final int? subserviceId;
  final int serviceId;
  final String subserviceName;
  final String? description;

  SubService({
    this.subserviceId,
    required this.serviceId,
    required this.subserviceName,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'subservice_id': subserviceId,
      'service_id': serviceId,
      'subservice_name': subserviceName,
      'description': description,
    };
  }

  factory SubService.fromMap(Map<String, dynamic> map) {
    return SubService(
      subserviceId: map['subservice_id'],
      serviceId: map['service_id'],
      subserviceName: map['subservice_name'],
      description: map['description'],
    );
  }
}
