// lib/model/profile_response.dart

class ProfileData {
  final String id;
  final String name;
  final String email;
  final Role role;
  final List<String> permissions; // Giả sử đây là List<String>

  ProfileData({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    // Chuyển đổi list<dynamic> thành list<String>
    var permsList = (json['permissions'] as List? ?? [])
        .map((item) => item.toString())
        .toList();

    return ProfileData(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      role: Role.fromJson(json['role']),
      permissions: permsList,
    );
  }
}

class Role {
  final String id;
  final String name;
  final List<String> permissions;

  Role({
    required this.id,
    required this.name,
    required this.permissions,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    // Chuyển đổi list<dynamic> thành list<String>
    var permsList = (json['permissions'] as List? ?? [])
        .map((item) => item.toString())
        .toList();

    return Role(
      id: json['_id'],
      name: json['name'],
      permissions: permsList,
    );
  }
}