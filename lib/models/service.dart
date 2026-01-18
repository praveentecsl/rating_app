class Service {
  final int? serviceId;
  final String serviceName;
  final String? description;
  final String? imagePath;

  Service({
    this.serviceId,
    required this.serviceName,
    this.description,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'service_id': serviceId,
      'service_name': serviceName,
      'description': description,
      'image_path': imagePath,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      serviceId: map['service_id'],
      serviceName: map['service_name'],
      description: map['description'],
      imagePath: map['image_path'],
    );
  }
}
