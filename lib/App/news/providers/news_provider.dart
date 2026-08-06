// lib/providers/news_provider.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:app_02/model/news.dart';
import 'package:app_02/network/repository.dart';

class NewsProvider with ChangeNotifier {
  final Repository _repository = Repository();

  // 1. Trạng thái (State) - Giống hệt _NewsListPageState
  List<News> _newsList = [];
  bool _isLoading = false;
  String? _error;

  // 2. Getters (để UI truy cập)
  List<News> get newsList => _newsList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 3. Constructor
  NewsProvider() {
    // Tải dữ liệu ngay khi provider được tạo (giống initState)
    fetchNews();
  }

  // 4. Hàm fetch (Logic được chuyển từ _fetchNews của UI)
  Future<void> fetchNews() async {
    // Chỉ bật loading xoay tròn cho lần tải đầu
    if (_newsList.isEmpty) {
      _isLoading = true;
    }
    _error = null;
    notifyListeners(); // Thông báo cho UI (hiển thị spinner)

    try {
      // 2. Gọi API
      final response = await _repository.getNews(page: 1, limit: 10);

      // 3. Xử lý kết quả
      if (response != null && response.statusCode == 200) {
        // 4. THÀNH CÔNG: Cập nhật danh sách
        _newsList = response.data.data;
        _error = null;
      } else {
        // 5. LỖI TỪ API
        _error = response?.message ?? "Lỗi không xác định từ API";
      }
    } catch (e) {
      // 6. LỖI MẠNG/PARSE
      log("Lỗi khi tải tin tức: ", error: e);
      _error = "Không thể tải danh sách tin tức. Vui lòng thử lại.";
    } finally {
      // 7. Dọn dẹp
      _isLoading = false;
      notifyListeners(); // Thông báo cho UI (ẩn spinner, hiển thị data/lỗi)
    }
  }

// 5. Hàm helper (Chuyển từ UI sang đây)
// Lưu ý: Hàm này không còn cần thiết ở đây
// vì nó được gọi từ Repository bên trong _buildBody của UI
// String buildImageUrl(String? path) => _repository.buildImageUrl(path);
}