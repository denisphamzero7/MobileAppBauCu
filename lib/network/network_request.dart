// NetworkRequest.dart
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../model/post.dart';

class NetworkRequest {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8', // Quan trọng cho POST/PUT
        'Accept': 'application/json',
      },
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  // --- HÀM LẤY DANH SÁCH (Giữ nguyên) ---
  static List<Post> parsePostList(List<dynamic> list) {
    List<Post> posts = list.map((model) => Post.fromJson(model)).toList();
    return posts;
  }

  static Future<List<Post>> fetchPost({int page = 1}) async {
    // ... (Giữ nguyên code fetchPost của bạn)
    const String unencodedPath = '/posts';
    final Map<String, dynamic> queryParameters = { '_page': page, };
    try {
      final response = await _dio.get(unencodedPath, queryParameters: queryParameters);
      return compute(parsePostList, response.data as List<dynamic>);
    } on DioException catch (e) {
      print("ĐÃ XẢY RA LỖI DIO: ${e.message}");
      throw Exception('Failed to load posts. Lỗi: ${e.message}');
    }
  }

  // --- HÀM LẤY CHI TIẾT (Giữ nguyên) ---
  static Post parsePostDetail(Map<String, dynamic> json) {
    return Post.fromJson(json);
  }

  static Future<Post> fetchPostDetail(int postId) async {
    // ... (Giữ nguyên code fetchPostDetail của bạn)
    final String unencodedPath = '/posts/$postId';
    try {
      final response = await _dio.get(unencodedPath);
      return compute(parsePostDetail, response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print("ĐÃ XẢY RA LỖI DIO: ${e.message}");
      throw Exception('Failed to load post detail. Lỗi: ${e.message}');
    }
  }

  // === HÀM MỚI 1: THÊM MỚI POST ===
  static Future<Post> createPost(String title, String body) async {
    final String unencodedPath = '/posts';
    try {
      final response = await _dio.post(
        unencodedPath,
        data: {
          'title': title,
          'body': body,
          'userId': 1, // API yêu cầu, gửi tạm userId 1
        },
      );
      // API sẽ trả về object vừa tạo
      return Post.fromJson(response.data);
    } on DioException catch (e) {
      print("Lỗi khi tạo post: ${e.message}");
      throw Exception('Failed to create post.');
    }
  }

  // === HÀM MỚI 2: CẬP NHẬT POST ===
  static Future<Post> updatePost(int id, String title, String body) async {
    final String unencodedPath = '/posts/$id';
    try {
      final response = await _dio.put(
        unencodedPath,
        data: {
          'id': id,
          'title': title,
          'body': body,
          'userId': 1,
        },
      );
      // API sẽ trả về object vừa cập nhật
      return Post.fromJson(response.data);
    } on DioException catch (e) {
      print("Lỗi khi cập nhật post: ${e.message}");
      throw Exception('Failed to update post.');
    }
  }

  // === HÀM MỚI 3: XÓA POST ===
  static Future<void> deletePost(int id) async {
    final String unencodedPath = '/posts/$id';
    try {
      // API xóa sẽ trả về status 200 OK và data rỗng
      await _dio.delete(unencodedPath);
      print("Đã xóa post $id thành công");
    } on DioException catch (e) {
      print("Lỗi khi xóa post: ${e.message}");
      throw Exception('Failed to delete post.');
    }
  }
}