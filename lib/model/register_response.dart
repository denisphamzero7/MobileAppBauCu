

// (File này CHỈ chứa class cho data của response register)
// Lớp vỏ bọc BaseResponse<T> sẽ được dùng chung

/// Lớp chứa thông tin User trả về sau khi đăng ký
/// (Dựa trên ảnh Postman 'image_c8cc16.png')
class RegisteredUserData {
  String email;
  dynamic lastname; // Trong JSON là null
  String name;
  int age;
  String password; // Password đã được hash
  String gender;
  String address;
  String role; // QUAN TRỌNG: API Register trả về role là String (ID)
  bool isDelete;
  String id;
  String phone;
  DateTime createdAt;
  DateTime updatedAt;

  RegisteredUserData({
    required this.email,
    this.lastname,
    required this.name,
    required this.age,
    required this.password,
    required this.gender,
    required this.address,
    required this.role,
    required this.isDelete,
    required this.id,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Hàm factory để parse từ JSON
  factory RegisteredUserData.fromJson(Map<String, dynamic> json) => RegisteredUserData(
    email: json["email"],
    lastname: json["lastname"],
    name: json["name"],
    age: json["age"],
    password: json["password"],
    gender: json["gender"],
    address: json["address"],
    role: json["role"], // Chỉ lấy String ID
    isDelete: json["isDelete"],
    id: json["_id"], // Lấy _id
    phone: json["phone"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );
}

