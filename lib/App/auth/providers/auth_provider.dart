// lib/App/auth/providers/auth_provider.dart
// (Sửa lại đường dẫn import của bạn nếu cần)

import 'package:app_02/network/repository.dart';
import 'package:app_02/model/login_response.dart'; // Cần import User
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- ONESIGNAL --- (Bước 1: Thêm 2 import)
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:developer'; // Dùng để in log

// Enum để quản lý trạng thái xác thực
enum AuthStatus {
  Uninitialized, // Mới mở app
  Authenticated, // Đã đăng nhập
  Authenticating, // Đang xử lý đăng nhập
  Unauthenticated, // Chưa đăng nhập
  Registering // Đang xử lý đăng ký
}

class AuthProvider with ChangeNotifier {
  final Repository _repository = Repository();

  // Trạng thái nội bộ
  AuthStatus _status = AuthStatus.Uninitialized;
  String? _token;
  User? _user;
  String _errorMessage = ''; // Để lưu lỗi khi đăng nhập/đăng ký

  // Getters để UI truy cập
  AuthStatus get status => _status;
  User? get user => _user;
  String? get token => _token;
  String get errorMessage => _errorMessage;

  // Dùng getter để kiểm tra trạng thái đăng nhập
  bool get isAuthenticated => _status == AuthStatus.Authenticated;

  AuthProvider() {
    // Khi AuthProvider được tạo, gọi hàm tự động kiểm tra đăng nhập
    tryAutoLogin();
  }

  // 1. Hàm đăng nhập
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.Authenticating;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _repository.login(email, password);

      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        // Lấy dữ liệu
        _token = response.data.accessToken;
        _user = response.data.user;

        // Lưu vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('userName', _user!.name);

        // --- ONESIGNAL --- (Bước 2: Login bằng user.id và lưu user.id)
        // Giả định _user.id tồn tại (thường là _id từ MongoDB)
        if (_user?.id != null && _user!.id.isNotEmpty) {
          OneSignal.login(_user!.id);
          log("OneSignal: Đã đăng nhập với External User ID (user.id): ${_user!.id}");
          // Lưu userId để tự động đăng nhập
          await prefs.setString('userId', _user!.id);
        } else {
          log("OneSignal LỖI: Không tìm thấy 'user.id' của user khi đăng nhập.");
        }
        // --- KẾT THÚC ONESIGNAL ---

        // Cập nhật trạng thái và thông báo
        _status = AuthStatus.Authenticated;
        notifyListeners();
        return true;
      } else {
        // Xử lý lỗi
        _errorMessage = response?.message ?? 'Đăng nhập thất bại.';
        _status = AuthStatus.Unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Có lỗi xảy ra: $e';
      _status = AuthStatus.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // 2. Hàm đăng ký (Không cần thay đổi)
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String age,
    required String gender,
    required String address,
    required String phone,
  }) async {
    _status = AuthStatus.Registering;
    _errorMessage = '';
    notifyListeners();

    try {
      var response = await _repository.register(
        name: name,
        email: email,
        password: password,
        age: age,
        gender: gender,
        address: address,
        phone: phone,
      );

      if (response != null) {
        _status = AuthStatus.Unauthenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Đăng ký thất bại. Vui lòng thử lại.';
        _status = AuthStatus.Unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Có lỗi xảy ra: $e';
      _status = AuthStatus.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // 3. Hàm kiểm tra tự động đăng nhập
  Future<void> tryAutoLogin() async {
    // Tạo khoảng dừng 2 giây để hiển thị màn hình Intro/Loading
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      _status = AuthStatus.Unauthenticated;
      notifyListeners();
      return;
    }

    _token = prefs.getString('token');
    final userName = prefs.getString('userName');

    // --- ONESIGNAL --- (Bước 3: Lấy userId đã lưu)
    final userId = prefs.getString('userId');

    // Tạo lại User object từ SharedPreferences
    if (userName != null) {
      // Giả định model User của bạn có 'id' và 'name'
      _user = User(
        id: userId ?? '', // <-- Quan trọng: dùng userId đã lưu
        email: '',
        role: Role(id: '', name: ''),
        name: userName,
      );
    }

    // --- ONESIGNAL --- (Bước 4: Login khi tự động đăng nhập)
    if (userId != null && userId.isNotEmpty) {
      OneSignal.login(userId);
      log("OneSignal: Tự động đăng nhập với External User ID (user.id): $userId");
    } else {
      log("OneSignal LỖI: Tự động đăng nhập nhưng không tìm thấy 'userId' đã lưu.");
    }
    // --- KẾT THÚC ONESIGNAL ---

    _status = AuthStatus.Authenticated;
    notifyListeners();
  }

  // 4. Hàm đăng xuất
  Future<void> logout() async {

    // *** BƯỚC MỚI: GỌI API LOGOUT TRƯỚC ***
    try {
      await _repository.logout();
      log("API Logout thành công.");
    } catch (e) {
      // Nếu API Logout thất bại (ví dụ: mất mạng, token hết hạn),
      // ta vẫn tiếp tục xóa dữ liệu local để đảm bảo người dùng đăng xuất ở client.
      log("Cảnh báo: API Logout thất bại, tiếp tục xóa dữ liệu local. Lỗi: $e");
    }
    // ***************************************

    // --- ONESIGNAL --- (Bước 5: Logout)
    OneSignal.logout();
    log("OneSignal: Đã đăng xuất.");
    // --- KẾT THÚC ONESIGNAL ---

    _token = null;
    _user = null;
    _status = AuthStatus.Unauthenticated;

    // Xóa khỏi SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userName');

    // --- ONESIGNAL --- (Bước 6: Xóa userId đã lưu)
    await prefs.remove('userId');

    notifyListeners();
  }
}