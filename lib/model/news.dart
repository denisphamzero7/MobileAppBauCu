import 'dart:convert';

// Helper function to decode the entire JSON string
NewsListResponse newsListResponseFromJson(String str) =>
    NewsListResponse.fromJson(json.decode(str));

// 1. Top-level API Response Wrapper
// This class wraps the entire JSON response
class NewsListResponse {
  final int statusCode;
  final String message;
  final NewsData data;

  NewsListResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory NewsListResponse.fromJson(Map<String, dynamic> json) =>
      NewsListResponse(
        statusCode: json["statusCode"],
        message: json["message"],
        data: NewsData.fromJson(json["data"]),
      );
}

// 2. Data object (contains the list and pagination)
class NewsData {
  final List<News> data;
  final Pagination pagination;

  NewsData({
    required this.data,
    required this.pagination,
  });

  factory NewsData.fromJson(Map<String, dynamic> json) => NewsData(
    data: List<News>.from(json["data"].map((x) => News.fromJson(x))),
    pagination: Pagination.fromJson(json["pagination"]),
  );
}

// 3. Pagination Model
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

// 4. The core News Model
class News {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final NewsUser createBy;
  final bool isDeleted;
  final DateTime? deletedAt; // Nullable
  final DateTime createdAt;
  final DateTime updatedAt;
  final NewsUser? updatedBy; // Nullable (based on your JSON)

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.createBy,
    required this.isDeleted,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.updatedBy,
  });

  factory News.fromJson(Map<String, dynamic> json) => News(
    id: json["_id"],
    title: json["title"],
    content: json["content"],
    imageUrl: json["imageUrl"],
    createBy: NewsUser.fromJson(json["createBy"]),
    isDeleted: json["isDeleted"],
    deletedAt: json["deletedAt"] == null
        ? null
        : DateTime.parse(json["deletedAt"]),
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    updatedBy: json["updatedBy"] == null
        ? null
        : NewsUser.fromJson(json["updatedBy"]),
  );
}

// 5. Sub-model for createBy and updatedBy
class NewsUser {
  final String id;
  final String email;

  NewsUser({
    required this.id,
    required this.email,
  });

  factory NewsUser.fromJson(Map<String, dynamic> json) => NewsUser(
    id: json["_id"],
    email: json["email"],
  );
}
