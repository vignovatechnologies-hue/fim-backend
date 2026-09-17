class UserModel {
  final int id;
  final String email;
  final String name;
  final String? phone;
  final bool verified;
  final bool premium;
  final bool remindersEnabled;
  final String? photoData;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.verified = false,
    this.premium = false,
    this.remindersEnabled = true,
    this.photoData,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      verified: json['verified'] ?? false,
      premium: json['premium'] ?? false,
      remindersEnabled: json['reminders_enabled'] ?? true,
      photoData: json['photo_data'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'verified': verified,
      'premium': premium,
      'reminders_enabled': remindersEnabled,
      'photo_data': photoData,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    bool? verified,
    bool? premium,
    bool? remindersEnabled,
    String? photoData,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      verified: verified ?? this.verified,
      premium: premium ?? this.premium,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      photoData: photoData ?? this.photoData,
      createdAt: createdAt,
    );
  }
}
