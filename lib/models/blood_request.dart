class BloodRequest {
  final String id;
  final String bloodType;
  final String status;
  final String createdBy;
  final String createdAt;
  final String location;
  final String urgency;
  final String description;

  BloodRequest({
    required this.id,
    required this.bloodType,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.location,
    required this.urgency,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bloodType': bloodType,
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'location': location,
      'urgency': urgency,
      'description': description,
    };
  }

  static BloodRequest fromMap(Map<String, dynamic> map) {
    return BloodRequest(
      id: map['id'],
      bloodType: map['bloodType'],
      status: map['status'],
      createdBy: map['createdBy'],
      createdAt: map['createdAt'],
      location: map['location'],
      urgency: map['urgency'],
      description: map['description'],
    );
  }

  BloodRequest copyWith({
    String? id,
    String? bloodType,
    String? status,
    String? createdBy,
    String? createdAt,
    String? location,
    String? urgency,
    String? description,
  }) {
    return BloodRequest(
      id: id ?? this.id,
      bloodType: bloodType ?? this.bloodType,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      urgency: urgency ?? this.urgency,
      description: description ?? this.description,
    );
  }
}
