

import 'package:app_02/network/repository.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Đây là một hàm/logic giả định để báo hiệu đăng xuất
typedef VoidCallback = void Function();

class AuthInterceptor extends Interceptor {
  // Cần một instance của Dio để gọi API Refresh Token độc lập
  final Dio dio;
  final Repository repository;
  final VoidCallback onLogout; // Hàm callback để báo hiệu cho AuthProvider

  // Biến cờ để ngăn chặn nhiều yêu cầu làm mới cùng lúc
  bool isRefreshing = false;
  // Hàng đợi cho các yêu cầu bị chặn trong khi đang refresh
  final List<ResponseWrapper> _requestsQueue = [];

  AuthInterceptor(this.dio, this.repository, this.onLogout);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 1. Thêm Access Token vào Header
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('token'); // Lấy Access Token từ SharedPreferences

    // Nếu token tồn tại và yêu cầu không phải là API Login
    if (accessToken != null && options.path != Repository.loginUrl) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final originalRequest = err.requestOptions;

    // 2. Bắt lỗi 401 Unauthorized
    if (err.response?.statusCode == 401) {
      // Kiểm tra xem yêu cầu gốc có phải là API Refresh Token không
      if (originalRequest.path.contains(Repository.refreshTokenUrl)) {
        // Refresh Token hết hạn -> Đăng xuất người dùng
        onLogout();
        return handler.reject(err);
      }

      // 3. Nếu đang trong quá trình Refresh Token, thêm yêu cầu gốc vào hàng đợi
      if (isRefreshing) {
        final wrapper = ResponseWrapper(originalRequest, handler);
        _requestsQueue.add(wrapper);
        return; // Đợi đến khi refresh xong
      }

      // 4. Bắt đầu quá trình Refresh Token
      isRefreshing = true;
      try {
        final refreshResponse = await repository.refreshToken();

        if (refreshResponse != null && refreshResponse.statusCode == 200) {
          final newAccessToken = refreshResponse.data.accessToken;

          // 5. Lưu Access Token mới vào SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', newAccessToken);

          // 6. Cập nhật và thử lại yêu cầu gốc (lần đầu)
          originalRequest.headers['Authorization'] = 'Bearer $newAccessToken';
          final response = await dio.fetch(originalRequest);

          // 7. Giải phóng và thử lại tất cả yêu cầu trong hàng đợi
          _processQueue(newAccessToken);

          return handler.resolve(response); // Giải quyết yêu cầu gốc
        } else {
          // Refresh Token thất bại (response lỗi khác 200)
          onLogout();
          return handler.reject(err);
        }
      } on DioException catch (e) {
        // Refresh Token thất bại (gặp exception)
        onLogout();
        // Giải phóng hàng đợi với lỗi
        _processQueue(null, error: e);
        return handler.reject(err);
      } finally {
        isRefreshing = false;
      }
    }
    // Đối với các lỗi khác 401, chuyển tiếp lỗi
    super.onError(err, handler);
  }

  // Xử lý hàng đợi
  void _processQueue(String? newAccessToken, {DioException? error}) {
    if (error != null) {
      // Nếu có lỗi, trả về lỗi cho tất cả các yêu cầu trong hàng đợi
      for (var wrapper in _requestsQueue) {
        wrapper.handler.reject(error);
      }
    } else if (newAccessToken != null) {
      // Nếu thành công, thử lại từng yêu cầu
      for (var wrapper in _requestsQueue) {
        final request = wrapper.options;
        request.headers['Authorization'] = 'Bearer $newAccessToken';
        dio.fetch(request)
            .then(wrapper.handler.resolve)
            .catchError(wrapper.handler.reject);
      }
    }
    _requestsQueue.clear();
  }
}

// Class wrapper để giữ RequestOptions và ErrorInterceptorHandler
class ResponseWrapper {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;

  ResponseWrapper(this.options, this.handler);
}