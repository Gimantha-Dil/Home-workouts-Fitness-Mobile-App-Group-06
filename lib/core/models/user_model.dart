import 'user_role.dart';

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? profilePhotoUrl;
  final bool isProfileCompleted;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePhotoUrl,
    this.isProfileCompleted = false,
  });

  User copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? profilePhotoUrl,
    bool? isProfileCompleted,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.customer,
      ),
      profilePhotoUrl: json['profile_photo_url'],
      isProfileCompleted: json['profileCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'profile_photo_url': profilePhotoUrl,
      'profileCompleted': isProfileCompleted,
    };
  }
}

typedef AppUser = User;
