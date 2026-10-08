import 'user_role.dart';

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? profilePhotoUrl;
  final bool isProfileCompleted;
  final String verificationStatus;

  String? get photoUrl => profilePhotoUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePhotoUrl,
    this.isProfileCompleted = false,
    this.verificationStatus = 'none',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>?;
    final isCompleted = json['isProfileCompleted'] ?? (profile != null && profile.isNotEmpty);

    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.customer,
      ),
      profilePhotoUrl: json['profilePhotoUrl'] ?? json['photoUrl'],
      isProfileCompleted: isCompleted,
      verificationStatus: json['verificationStatus'] ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'photoUrl': profilePhotoUrl,
      'isProfileCompleted': isProfileCompleted,
      'verificationStatus': verificationStatus,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? profilePhotoUrl,
    bool? isProfileCompleted,
    String? verificationStatus,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
}

typedef AppUser = User;
