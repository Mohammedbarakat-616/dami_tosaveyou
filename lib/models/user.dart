class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String bloodType;
  final String lastDonationDate;
  final String phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.bloodType,
    required this.lastDonationDate,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'bloodType': bloodType,
      'lastDonationDate': lastDonationDate,
      'phone': phone,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
      bloodType: map['bloodType'],
      lastDonationDate: map['lastDonationDate'],
      phone: map['phone'],
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? bloodType,
    String? lastDonationDate,
    String? phone,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      bloodType: bloodType ?? this.bloodType,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      phone: phone ?? this.phone,
    );
  }
}
