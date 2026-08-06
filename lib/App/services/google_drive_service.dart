// lib/services/google_drive_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http; // ✅ THÊM IMPORT NÀY

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
    ],
  );

  // Kiểm tra kết nối mạng
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Đăng nhập Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      print('Lỗi đăng nhập Google: $e');
      return null;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  // Kiểm tra đã đăng nhập chưa
  bool get isSignedIn => _googleSignIn.currentUser != null;

  // Upload file lên Google Drive
  Future<String?> uploadFile({
    required String fileName,
    required Uint8List fileBytes,
    String mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  }) async {
    try {
      // 1. Đăng nhập nếu chưa đăng nhập
      GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account == null) {
        account = await signIn();
        if (account == null) {
          print('Người dùng hủy đăng nhập');
          return null;
        }
      }

      // 2. Lấy HTTP Client có xác thực
      final authHeaders = await account.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);

      // 3. Khởi tạo Drive API
      final driveApi = drive.DriveApi(authenticateClient);

      // 4. Tạo metadata file
      final driveFile = drive.File()
        ..name = fileName
        ..mimeType = mimeType;

      // 5. Upload file
      final media = drive.Media(
        Stream.value(fileBytes.toList()),
        fileBytes.length,
      );

      final response = await driveApi.files.create(
        driveFile,
        uploadMedia: media,
      );

      print('✅ File đã upload lên Drive: ${response.name} (ID: ${response.id})');
      return response.id;

    } catch (e, stack) {
      print('❌ Lỗi upload Google Drive: $e\n$stack');
      return null;
    }
  }

  // Lấy link xem file
  Future<String?> getFileWebViewLink(String fileId) async {
    try {
      final authHeaders = await _googleSignIn.currentUser!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      final file = await driveApi.files.get(
        fileId,
        $fields: 'webViewLink',
      ) as drive.File;

      return file.webViewLink;
    } catch (e) {
      print('Lỗi lấy link: $e');
      return null;
    }
  }
}

// ✅ SỬA LẠI: HTTP Client cho Google APIs
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}