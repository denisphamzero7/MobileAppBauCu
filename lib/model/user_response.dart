class Voter {
  final String? lastSeen;
  final String id; // Ánh xạ từ "_id"
  final String? email; // <-- SỬA 1: Thêm ?
  final String? name; // <-- SỬA 2: Thêm ?
  final int? age;
  final String? password;
  final String? gender;
  final String? role;
  final int? phone;
  final String? address;
  final Company? company;
  final bool? isDeleted;
  final String? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Voter({
    this.lastSeen,
    required this.id, // id vẫn bắt buộc
    this.email, // <-- SỬA 3: Bỏ required
    this.name, // <-- SỬA 4: Bỏ required
    this.age, // <-- SỬA 5: Bỏ required
    this.password,
    this.gender,
    this.role,
    this.phone,
    this.address,
    this.company,
    this.isDeleted,
    this.deletedAt,
    required this.createdAt, // createdAt vẫn bắt buộc
    required this.updatedAt, // updatedAt vẫn bắt buộc
    required this.v, // v vẫn bắt buộc
  });

  factory Voter.fromJson(Map<String, dynamic> json) => Voter(
    // Xử lý các trường có thể null
    lastSeen: json["lastSeen"],
    deletedAt: json["deletedAt"],
    company: json["company"] == null
        ? null
        : Company.fromJson(json["company"]),
    email: json["email"], // Giờ đã an toàn
    name: json["name"], // Giờ đã an toàn
    age: json["age"],
    password: json["password"],
    gender: json["gender"],
    role: json["role"],
    phone: json["phone"],
    address: json["address"],
    isDeleted: json["isDeleted"],

    // Ánh xạ các trường đặc biệt
    id: json["_id"],
    v: json["__v"],

    // Phân tích cú pháp ngày tháng (Giả định createdAt/updatedAt không bao giờ null)
    // Nếu chúng CÓ THỂ null, bạn cũng cần thêm ? cho chúng
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "lastSeen": lastSeen,
    "_id": id,
    "email": email,
    "name": name,
    "age": age,
    "password": password,
    "gender": gender,
    "role": role,
    "phone": phone,
    "address": address,
    "company": company?.toJson(),
    "isDeleted": isDeleted,
    "deletedAt": deletedAt,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}

// Class Company giữ nguyên
class Company {
  final String id;
  final String name;

  Company({
    required this.id,
    required this.name,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    id: json["_id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}