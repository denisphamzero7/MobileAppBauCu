import 'package:flutter/cupertino.dart'; // Sửa: Giống DocumentProvider
import 'dart:developer'; // Thêm: Giống DocumentProvider để dùng log

import '../../../model/user_response.dart';
import '../../../network/base_response.dart';
import '../../../network/repository.dart';

class UserProvider with ChangeNotifier { // Sửa: Dùng "with" giống DocumentProvider
  final Repository _repository = Repository(); // Sửa: Khởi tạo repository bên trong

  // 1. Trạng thái (state) private
  List<Voter> _users = [];
  bool _isloading = false;
  String? _error;

  // 2. Getters (để UI truy cập)
  List<Voter> get users => _users;
  bool get isloading => _isloading;
  String? get error => _error;

  // 3. Constructor
  UserProvider() {
    // Tự động gọi API khi provider được khởi tạo
    fetchUsers();
  }

  /// Hàm gọi API để lấy danh sách người dùng
  Future<void> fetchUsers() async {
    // Sửa: Dùng logic của DocumentProvider
    if (_users.isEmpty) {
      _isloading = true;
    }
    _error = null;
    notifyListeners(); // Thông báo cho UI "đang tải"

    try {
      // Gọi hàm từ repository
      BaseResponse<List<Voter>>? response =
      await _repository.getUsers(limit: 10, page: 1);

      if (response != null && response.statusCode == 200) {
        // Thành công: Gán dữ liệu
        _users = response.data;
        _error = null; // Sửa: Đảm bảo lỗi được clear khi thành công
      } else {
        // Lỗi từ server (null hoặc status != 200)
        // Sửa: Dùng lỗi thật từ API (giống SỬA 1)
        _error = response?.message ?? "Không thể tải danh sách người dùng.";
      }
    } catch (e) {
      // Lỗi kết nối, v.v.
      // Sửa: Dùng lỗi thật từ Exception (giống SỬA 2)
      log("Lỗi khi tải người dùng: ", error: e); // Log lỗi ra console
      _error = "Không thể kết nối. Vui lòng thử lại."; // Hiển thị lỗi thân thiện
    } finally {
      // Dù thành công hay thất bại, cũng dừng loading
      _isloading = false;
      notifyListeners(); // Thông báo cho UI "tải xong"
    }
  }
}