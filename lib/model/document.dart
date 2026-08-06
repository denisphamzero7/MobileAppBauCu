import 'dart:convert';

// Helper function to decode the entire JSON string (giống hệt news)
DocumentListResponse documentListResponseFromJson(String str) =>
    DocumentListResponse.fromJson(json.decode(str));

// 1. Top-level API Response Wrapper (giống hệt NewsListResponse)
// Lớp này bọc toàn bộ phản hồi JSON
class DocumentListResponse {
  final int statusCode;
  final String message;
  final DocumentData data;

  DocumentListResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory DocumentListResponse.fromJson(Map<String, dynamic> json) =>
      DocumentListResponse(
        statusCode: json["statusCode"],
        message: json["message"],
        data: DocumentData.fromJson(json["data"]),
      );
}

// 2. Data object (giống hệt NewsData)
// Chứa danh sách và thông tin phân trang
class DocumentData {
  final List<Document> data;
  final Pagination pagination;

  DocumentData({
    required this.data,
    required this.pagination,
  });

  factory DocumentData.fromJson(Map<String, dynamic> json) => DocumentData(
    data: List<Document>.from(json["data"].map((x) => Document.fromJson(x))),
    pagination: Pagination.fromJson(json["pagination"]),
  );
}

// 3. Pagination Model (ĐÃ SAO CHÉP TỪ NEWS.DART)
// Lớp này bây giờ được định nghĩa ngay bên trong file
class Pagination {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int limit;

  Pagination({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    totalItems: json["totalItems"],
    totalPages: json["totalPages"],
    currentPage: json["currentPage"],
    limit: json["limit"],
  );
}

// 4. The core Document Model (sửa từ News)
class Document {
  final String id;
  final String title;
  final String description;
  final String status;
  final DocumentUser createBy;
  final bool isDeleted;
  final DateTime? deletedAt; // Nullable
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v; // Trường "__v"

  Document({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createBy,
    required this.isDeleted,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    id: json["_id"],
    title: json["title"],
    description: json["description"],
    status: json["status"],
    createBy: DocumentUser.fromJson(json["createBy"]),
    isDeleted: json["isDeleted"],
    deletedAt: json["deletedAt"] == null
        ? null
        : DateTime.parse(json["deletedAt"]),
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );
}

// 5. Sub-model for createBy (giống hệt NewsUser)
class DocumentUser {
  final String id;
  final String email;

  DocumentUser({
    required this.id,
    required this.email,
  });

  factory DocumentUser.fromJson(Map<String, dynamic> json) => DocumentUser(
    id: json["_id"],
    email: json["email"],
  );
}