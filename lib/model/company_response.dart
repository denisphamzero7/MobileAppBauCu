// lib/model/company_model.dart
import 'dart:convert';

// 1. Lớp CompanyListData (Không thay đổi)
class CompanyListData {
  Map<String, dynamic> meta;
  List<Company> result;

  CompanyListData({
    required this.meta,
    required this.result,
  });

  factory CompanyListData.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<Company> companyList = list.map((i) => Company.fromJson(i)).toList();

    return CompanyListData(
      meta: json['meta'],
      result: companyList,
    );
  }
}

// 2. Lớp Company (Đã sửa)
class Company {
  String id;
  String name;
  String description;
  String logo;
  UserRef createdBy;
  UserRef? updatedBy;
  bool isDelete;
  DateTime? deleteAt;
  DateTime createdAt;
  DateTime updatedAt;

  Company({
    required this.id,
    required this.name,
    required this.description,
    required this.logo,
    required this.createdBy,
    this.updatedBy,
    required this.isDelete,
    this.deleteAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      // SỬA 1: Thêm '??' để gán giá trị mặc định (chuỗi rỗng)
      // nếu API trả về null cho các trường String
      id: json["_id"] ?? '',
      name: json["name"] ?? '',
      description: json["description"] ?? '',
      logo: json["logo"] ?? '',

      // SỬA 2: Xử lý trường hợp 'createdBy' có thể bị null
      // Bằng cách truyền {} rỗng vào UserRef.fromJson
      // (cần sửa cả UserRef.fromJson bên dưới)
      createdBy: UserRef.fromJson(json["createdBy"] ?? {}),

      // Xử lý 'updatedBy' (nullable) - Đã đúng
      updatedBy: json["updatedBy"] == null
          ? null
          : UserRef.fromJson(json["updatedBy"]),

      // Sửa 'isDelete' (bool) - Đã đúng
      isDelete: json["isDelete"] ?? false,

      // Xử lý 'deleteAt' (nullable DateTime) - Đã đúng
      deleteAt: json["deleteAt"] == null
          ? null
          : DateTime.parse(json["deleteAt"]),

      // SỬA 3: Xử lý null cho các trường DateTime không-nullable
      // Gán một giá trị mặc định (ví dụ: bây giờ) nếu API trả về null
      createdAt: json["createdAt"] == null
          ? DateTime.now()
          : DateTime.parse(json["createdAt"]),

      updatedAt: json["updatedAt"] == null
          ? DateTime.now()
          : DateTime.parse(json["updatedAt"]),

      // SỬA 4: XÓA DÒNG "createdBy" BỊ LẶP LẠI
    );
  }
}

// 3. Lớp UserRef (Đã sửa)
class UserRef {
  String id;
  String email;

  UserRef({
    required this.id,
    required this.email,
  });

  // SỬA 5: Thêm '??' cho các trường String
  // để xử lý trường hợp (json["createdBy"] ?? {}) ở trên
  factory UserRef.fromJson(Map<String, dynamic> json) => UserRef(
    id: json["_id"] ?? '',
    email: json["email"] ?? '',
  );
}