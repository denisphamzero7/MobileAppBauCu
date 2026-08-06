


import 'package:app_02/network/repository.dart';
import 'package:flutter/cupertino.dart';
import 'dart:developer';
import '../../../model/document.dart';

class DocumentProvider with ChangeNotifier{
  final Repository _repository = Repository();

  // Trạng thái (state)
List<Document> _documents = [];
bool _isloading = false;
String? _error;
// 2. Getters ( để UI truy cập)
List<Document> get documents => _documents;
bool get isloading => _isloading;
String? get error => _error;
// 3. Contructor
DocumentProvider(){
  // Tải dữ liệu ngay khi provider được tạo
    fetchDocuments();
  }

  // 4. hàm fetch
  Future<void> fetchDocuments() async {
    if (_documents.isEmpty) {
      _isloading = true;
    }
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getDocuments(page: 1, limit: 10);

      if (response != null && response.statusCode == 200) {
        _documents = response.data.data;
        _error = null;
      } else {
        // SỬA 1: Dùng lỗi thật từ API
        _error = response?.message ?? "Lỗi không xác định từ API";
      }
    } catch (e) {
      // SỬA 2: Dùng lỗi thật từ Exception
      log("Lỗi khi tải văn bản: ", error: e); // Log lỗi ra console
      _error = "Không thể kết nối. Vui lòng thử lại."; // Hiển thị lỗi thân thiện
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }
}
