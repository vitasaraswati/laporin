import 'package:laporin/models/enums.dart';

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? nim; // For Mahasiswa
  final String? nip; // For Dosen
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.nim,
    this.nip,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.mahasiswa,
      ),
      nim: json['nim'] as String?,
      nip: json['nip'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'nim': nim,
      'nip': nip,
      'phone': phone,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? nim,
    String? nip,
    String? phone,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      nim: nim ?? this.nim,
      nip: nip ?? this.nip,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get identifier {
    if (role == UserRole.mahasiswa && nim != null) {
      return nim!;
    } else if (role == UserRole.dosen && nip != null) {
      return nip!;
    }
    return email;
  }
}
