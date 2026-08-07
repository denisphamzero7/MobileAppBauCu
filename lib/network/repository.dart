import 'package:app_02/network/base_response.dart';
import 'package:dio/dio.dart';
import '../model/user_response.dart'  hide Company;
import '../model/company_response.dart';
import '../model/document.dart';
import '../model/news.dart';
import '../model/profile.dart';
import '../model/register_response.dart';
import 'dio_helper.dart';
import '../model/login_response.dart';
import '../model/news.dart'; // Đã thêm import cho News model
import '../model/scan_voter_request.dart';
class Repository {
  static final DioHelper _dioHelper = DioHelper();
  
  // CẤU HÌNH ĐỊA CHỈ IP MÁY CHỦ DUY NHẤT TẠI ĐÂY:
  static const String baseUrl = "https://backend-nestjs-qpdb.onrender.com";
  
  final String _apiBaseUrl = baseUrl;
  // URL cho Android Emulator
  static const String loginUrl = "$baseUrl/api/v1/auth/login";
  static const String logoutUrl = "$baseUrl/api/v1/auth/logout";
  static const String _registerUrl = "$baseUrl/api/v1/auth/register";
  static const String _companiesUrl = "$baseUrl/api/v1/companies";
  static const String _profileUrl = "$baseUrl/api/v1/users/profile";
  // SỬA LẠI: URL cho news (dựa theo NestJS Controller)
  static const String _newsUrl = "$baseUrl/api/v1/news";
  static const String _votersScanUrl = "$baseUrl/api/v1/voters/scan";
  static const String _documentsUrl = "$baseUrl/api/v1/documents";
  static const String refreshTokenUrl = "$baseUrl/api/v1/auth/refresh";
  // Nếu dùng iOS Simulator, bạn có thể dùng localhost:
  // static const String _loginUrl = "http://localhost:8080/api/v1/auth/login";
  static const String _usersUrl = "$baseUrl/api/v1/users";
  /// Hàm đăng nhập mới
  Future<BaseResponse<LoginData>?> login(String email, String password) async {
    var requestBody = {
      'username': email,
      'password': password,
    };

    try {
      var responseData = await _dioHelper.post(
        url: loginUrl,
        requestBody: requestBody,
        isAuthRequired: false,
      );

      // 3. Parse JSON và trả về
      if (responseData != null) {
        // BƯỚC 2: Dùng BaseResponse.fromJson, giống hệt hàm register
        return BaseResponse.fromJson(
            responseData,
                (json) =>
                LoginData.fromJson(json) // Truyền hàm parse cho LoginData
        );
      }
      return null;
    } catch (e) {
      print("Error in repository login: $e");
      return null;
    }
  }
  Future<BaseResponse<LoginData>?> refreshToken() async {
    // API Refresh Token của bạn KHÔNG cần request body (vì nó là GET và dùng Cookie)

    try {
      // 1. Gọi API GET /auth/refresh
      // Cần chắc chắn CookieManager trong DioHelper đã tự động đính kèm refresh_token
      var responseData = await _dioHelper.get(
        url: refreshTokenUrl,
        isAuthRequired: false, // API này không cần Access Token hợp lệ
        queryParameters: {},
      );

      // 2. Parse JSON và trả về
      if (responseData != null) {
        // Dùng BaseResponse.fromJson, sử dụng LoginData để parse
        return BaseResponse.fromJson(
            responseData, (json) => LoginData.fromJson(json));
      }
      return null;
    } on DioException catch (e) {
      // Xử lý lỗi Dio (401 nếu refresh token hết hạn)
      print("Error in repository refreshToken: ${e.response?.data ?? e.message}");
      // Quan trọng: Ném lỗi lại để AuthProvider biết làm mới thất bại và logout
      rethrow;
    } catch (e) {
      print("Error in repository refreshToken: $e");
      rethrow;
    }
  }
  Future<BaseResponse<dynamic>?> logout() async {
    try {
      // 1. Gọi API POST /auth/logout
      // API này yêu cầu Access Token hợp lệ (isAuthRequired: true)
      var responseData = await _dioHelper.post(
        url: logoutUrl,
        requestBody: null, // Không cần body
        isAuthRequired: true, // Quan trọng: Cần Access Token
      );

      // 2. Parse JSON và trả về
      if (responseData != null) {
        // Vì response data là 'true' hoặc 'false' (boolean),
        // ta chỉ cần parse lớp vỏ BaseResponse.
        return BaseResponse.fromJson(
          responseData,
              (json) => json, // Giữ nguyên phần 'data' (true)
        );
      }
      return null;
    } on DioException catch (e) {
      // Xử lý lỗi Dio (có thể xảy ra 401 nếu token đã hết hạn trước khi logout)
      print("Error in repository logout: ${e.response?.data ?? e.message}");

      // Nếu API logout thất bại (kể cả lỗi 401), chúng ta vẫn nên đăng xuất user
      // ở client (lớp Provider)
      rethrow;
    } catch (e) {
      print("Error in repository logout: $e");
      return null;
    }
  }
  // Hàm postApi chung của bạn (nên sửa lại để truyền url và auth)
  Future<dynamic> postApi(String url, Object reqModel,
      {bool isAuthRequired = false}) async {
    var response = await _dioHelper.post(
      url: url, // truyền url vào
      requestBody: reqModel,
      isAuthRequired: isAuthRequired, // truyền auth vào
    );
    return response;
  }

  Future<BaseResponse<RegisteredUserData>?> register({
    required String name,
    required String email,
    required String password,
    required String age,
    required String gender,
    required String address,
    required String phone,
  }) async {
    // 1. Tạo request body (Map)
    var requestBody = {
      'name': name,
      'email': email,
      'password': password,
      'age': age,
      'gender': gender,
      'address': address,
      'phone': phone,
    };

    try {
      // 2. Gọi API với đúng Content-Type
      var responseData = await _dioHelper.post(
        url: _registerUrl,
        requestBody: requestBody,
        isAuthRequired: false,
      );

      // 3. Parse JSON và trả về
      if (responseData != null) {
        // Dùng BaseResponse.fromJson và truyền hàm parse cho "RegisteredUserData"
        return BaseResponse.fromJson(
            responseData, (json) => RegisteredUserData.fromJson(json));
      }
      return null;
    } catch (e) {
      print("Error in repository register: $e");
      return null;
    }
  }

  Future<BaseResponse<List<Company>>?> getCompanies() async {
    try {
      var responseData = await _dioHelper.get(
        url: _companiesUrl,
        isAuthRequired: false, queryParameters: {}, // <-- Giữ 'true' để gửi token
      );
      print("data (getCompanies)");

      if (responseData != null) {
        // SỬA 2: Sửa logic parse
        return BaseResponse.fromJson(responseData,
            // 'json' ở đây là responseData['data'] (một Map)
                (json) {
              // SỬA LỖI: Lấy list từ key 'data' BÊN TRONG map 'json'
              var list = json['data'] as List;

              // Biến List<dynamic> thành List<Company>
              return list.map((item) => Company.fromJson(item)).toList();
            });
      }
      return null;
    } catch (e) {
      // Lỗi sẽ in ra ở đây
      print("Error in repository getCompanies: $e");
      return null;
    }
  }
  Future<BaseResponse<NewsData>?> getNews(
      {int page = 1, int limit = 10}) async {
    try {
      var responseData = await _dioHelper.get(
        url: _newsUrl,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        isAuthRequired: false, // API news là public (dựa theo controller)
      );

      if (responseData != null) {
        // Giả định BaseResponse.fromJson sẽ truyền responseData['data'] vào hàm parser
        // responseData['data'] là object { data: [...], pagination: {...} }
        // Class NewsData.fromJson được thiết kế để parse chính object này.
        return BaseResponse.fromJson(
            responseData, (json) => NewsData.fromJson(json));
      }
      return null;
    } catch (e) {
      print("Error in repository getNews: $e");
      return null;
    } }

  Future<BaseResponse<DocumentData>?> getDocuments(
      {int page = 1, int limit = 10}) async {
    try {
      var responseData = await _dioHelper.get(
        url: _documentsUrl, // <-- Dùng URL văn bản
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        isAuthRequired: false, // CÓ THỂ BẠN SẼ CẦN ĐỔI THÀNH 'true'
      );

      if (responseData != null) {
        // Dùng model DocumentData để parse
        return BaseResponse.fromJson(
            responseData, (json) => DocumentData.fromJson(json));
      }
      return null;
    } catch (e) {
      print("Error in repository getDocuments: $e"); // Sửa log lỗi
      return null;
    }
  }
  // profile
  Future<BaseResponse<ProfileData>?> getProfile() async {
    try {
      // Gọi API, yêu cầu xác thực (DioHelper sẽ tự đính kèm token)
      var responseData = await _dioHelper.get(
        url: _profileUrl,
        isAuthRequired: true, queryParameters: {}, // Quan trọng: API này cần token
      );

      if (responseData != null) {
        // Dùng BaseResponse.fromJson và truyền hàm parse cho ProfileData
        return BaseResponse.fromJson(
            responseData, (json) => ProfileData.fromJson(json));
      }
      return null;
    } catch (e) {
      print("Error in repository getProfile: $e");
      return null;
    }
  }

  Future<BaseResponse<dynamic>?> updateProfile({
    // SỬA 1: Đổi thành <dynamic>
    required String name,
    required String email,
    String? age,
    String? gender,
    String? address,
    String? phone,
  }) async {
    // (Phần xây dựng requestBody động giữ nguyên)
    Map<String, dynamic> requestBody = {};
    requestBody['name'] = name;
    requestBody['email'] = email;
    if (age != null && age.isNotEmpty) {
      requestBody['age'] = age;
    }
    if (gender != null && gender.isNotEmpty) {
      requestBody['gender'] = gender;
    }
    if (address != null && address.isNotEmpty) {
      requestBody['address'] = address;
    }
    if (phone != null && phone.isNotEmpty) {
      requestBody['phone'] = phone;
    }

    print("REQUEST BODY (ĐÃ LỌC): $requestBody");

    try {
      var responseData = await _dioHelper.patch(
        url: _profileUrl,
        requestBody: requestBody,
        isAuthRequired: true,
      );

      // 3. Parse kết quả trả về
      if (responseData != null) {
        // ----- SỬA 2: CHỈ PARSE LỚP VỎ, KHÔNG PARSE "data" -----
        // Chúng ta chỉ cần biết statusCode và message, không quan tâm `data`
        // Bằng cách truyền (json) => json, chúng ta giữ `data` ở dạng thô
        return BaseResponse.fromJson(
            responseData,
                (json) => json // Giữ nguyên "data" (không parse thành ProfileData)
        );
        // --------------------------------------------------------
      }
      return null;
    } catch (e) {
      print("Error in repository updateProfile: $e");
      rethrow;
    }
  }

  Future<void> changePassword(
      {required String oldPassword, required String newPassword}) async {
    print("changePassword");
  }

  // ----- HÀM MỚI ĐỂ LẤY TIN TỨC -----
  /// Hàm lấy danh sách tin tức (có phân trang)


  // HÀM NÀY BÂY GIỜ SẼ CHẠY ĐÚNG
  String buildImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return ""; // Trả về chuỗi rỗng nếu không có đường dẫn
    }

    // Xóa dấu / ở đầu nếu có
    final String path = relativePath.replaceFirst(RegExp(r'^/'), '');

    // Nối và trả về
    // Kết quả sẽ là: http://192.168.1.91:8080/images/tintuc/...jpg
    return "$_apiBaseUrl/$path";
  }
  Future<BaseResponse<List<Voter>>?> getUsers(
      {int page = 1, int limit = 10}) async {
    try {
      // 1. Gọi API
      var responseData = await _dioHelper.get(
        url: _usersUrl, // Dùng URL mới
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        isAuthRequired: true, // Lấy danh sách user thường yêu cầu quyền admin/xác thực
      );

      // 2. Parse kết quả
      if (responseData != null) {
        // Dùng BaseResponse.fromJson, giống hệt các hàm get khác
        return BaseResponse.fromJson(
            responseData,
            // 'json' ở đây chính là nội dung của key 'data' trong response
                (json) {

              // Dựa theo JSON bạn cung cấp, 'json' là một Map chứa key 'result'
              // Ví dụ: { "result": [...] }
              var list = json['result'] as List;

              // Biến List<dynamic> (từ JSON) thành List<User> (dùng model)
              return list.map((item) => Voter.fromJson(item)).toList();
            });
      }
      return null;
    } catch (e) {
      print("Error in repository getUsers: $e");
      return null;
    }
  }


  Future<BaseResponse<dynamic>?> scanVoter(ScanVoterRequest request) async {
    try {
      var responseData = await _dioHelper.post(
        url: _votersScanUrl,
        requestBody: request.toJson(), // Gửi request body
        isAuthRequired: true, // API này cần token, nếu không thì đổi thành false
      );

      if (responseData != null) {
        // Chỉ parse lớp vỏ BaseResponse, giữ nguyên phần 'data' (là object cập nhật)
        return BaseResponse.fromJson(
          responseData,
              (json) => json, // Giữ nguyên data ở dạng thô
        );
      }
      return null;
    } on DioException catch (e) {
      // Bắt lỗi Dio để in thông báo rõ ràng hơn
      print("Error in repository scanVoter: ${e.response?.data ?? e.message}");
      // Ném lỗi lại để có thể xử lý ở lớp UI
      rethrow;
    } catch (e) {
      print("Error in repository scanVoter: $e");
      return null;
    }
  }

}
