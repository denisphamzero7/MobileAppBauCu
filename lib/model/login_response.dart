// lib/model/login_response.dart
import 'dart:convert';

// BỎ HOÀN TOÀN CLASS LOGINRESPONSE

// BƯỚC 1: Đổi tên class 'Data' thành 'LoginData'
class LoginData {
  String accessToken;
  String refreshToken;
  User user;

  LoginData({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  // BƯỚC 2: Đổi tên factory 'Data.fromJson' thành 'LoginData.fromJson'
  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
    accessToken: json["access_token"],
    refreshToken: json["refresh_token"],
    user: User.fromJson(json["user"]),
  );
}


// --- CÁC CLASS BÊN DƯỚI GIỮ NGUYÊN ---

class Role {
  String id;
  String name;

  Role({
    required this.id,
    required this.name,
  });

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    id: json["_id"],
    name: json["name"],
  );
}

class User {
  String id;
  String email;
  Role role;
  String name;
  String? status;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    this.status,

  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    email: json["email"],
    role: Role.fromJson(json["role"]),
    name: json["name"],
    status: json["status"],

  );
}