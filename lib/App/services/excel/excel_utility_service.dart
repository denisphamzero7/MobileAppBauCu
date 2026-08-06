// lib/services/excel_utility_service.dart
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart'; // Cần cho BuildContext và SnackBar
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';

// --- QUAN TRỌNG: CẦN IMPORT FILE DatabaseHelper CỦA BẠN ---
import '../../../network/database_helper.dart';


class ExcelUtilityService {
  final DatabaseHelper _dbHelper;

  // Khởi tạo và lấy instance của DatabaseHelper
  ExcelUtilityService() : _dbHelper = DatabaseHelper();

  // --- HÀM TIỆN ÍCH: XIN QUYỀN BỘ NHỚ ---
  Future<bool> _checkPermission() async {
    // Lấy thông tin phiên bản Android
    if (Platform.isAndroid) {
      final androidInfo = await Permission.storage.status;

      // Android 13+ (API 33+): Không cần quyền storage cho file_saver
      // Android 10-12 (API 29-32): Có thể cần quyền
      // Android 9 trở xuống (API 28-): Bắt buộc cần quyền

      // Với file_saver, thường KHÔNG CẦN xin quyền
      // Vì nó sử dụng SAF (Storage Access Framework)
      return true; // Trả về true trực tiếp
    }
    return true;
  }

  // =========================================================
  //                       1. CHỨC NĂNG EXPORT
  // =========================================================

  Future<void> exportCitizens(BuildContext context) async {
    try {
      final List<CitizenInfo> citizens = await _dbHelper.getCitizens();

      if (citizens.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có dữ liệu để xuất')),
        );
        return;
      }

      final excel = Excel.createExcel();
      final Sheet sheet = excel[excel.getDefaultSheet()!];

      // Hàng tiêu đề (Header Row)
      final List<String> headers = [
        'CCCD', 'Họ Tên', 'Ngày sinh', 'Quốc tịch', 'Nguyên quán', 'Nơi cư trú',
        'Giới tính', 'Ngày hết hạn', 'Đặc điểm nhận dạng', 'Ngày cấp',
        'Nơi cấp', 'Đã bầu (1=True, 0=False)'
      ];

      sheet.appendRow(headers);

      // Thêm dữ liệu (Data Rows)
      for (final citizen in citizens) {
        final List<dynamic> row = [
          citizen.idNumber,
          citizen.fullName,
          citizen.dob,
          citizen.nationality,
          citizen.placeOfOrigin,
          citizen.placeOfResidence,
          citizen.sex,
          citizen.dateOfExpiry,
          citizen.personalIdentification,
          citizen.dateOfIssue,
          citizen.placeOfIssue,
          citizen.hasVoted ? 1 : 0
        ];
        sheet.appendRow(row);
      }

      // Mã hóa (Encode) và Lưu file
      final List<int>? fileBytes = excel.encode();
      if (fileBytes != null) {
        String fileName = "danh_sach_cu_tri_${DateTime.now().toIso8601String().split('T').first}";

        // Lưu file
        final String savedPath = await FileSaver.instance.saveFile(
          name: fileName,
          bytes: Uint8List.fromList(fileBytes),
          mimeType: MimeType.microsoftExcel,
        );

        // ✅ THÊM DELAY ĐỂ ĐẢM BẢO FILE ĐÃ ĐƯỢC GHI XONG
        await Future.delayed(const Duration(milliseconds: 500));

        // ✅ MỞ FILE VỚI ERROR HANDLING
        try {
          final result = await OpenFile.open(savedPath);

          if (!context.mounted) return;

          // Kiểm tra kết quả mở file
          if (result.type == ResultType.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã xuất file $fileName.xlsx thành công!'),
                backgroundColor: Colors.green.shade700,
              ),
            );
          } else {
            // Nếu không mở được, vẫn thông báo file đã lưu
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File đã lưu tại: $savedPath\n${result.message}'),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        } catch (openError) {
          // Lỗi khi mở file, nhưng file đã được lưu
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File đã lưu nhưng không thể mở tự động.\nĐường dẫn: $savedPath'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }

    } catch (e, stack) {
      print('Lỗi EXPORT Excel: $e\n$stack');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xuất file: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  // =========================================================
  //                       2. CHỨC NĂNG IMPORT
  // =========================================================

//   Future<void> importCitizens(BuildContext context) async {
//     FilePickerResult? result;
//
//     try {
//       // 1. Mở trình chọn file
//       result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['xlsx', 'xls'],
//       );
//
//       if (result == null || result.files.single.path == null) {
//         return; // Người dùng hủy chọn file
//       }
//
//       // 2. Đọc file
//       final filePath = result.files.single.path!;
//       final bytes = File(filePath).readAsBytesSync();
//       final excel = Excel.decodeBytes(bytes);
//
//       final Sheet sheet = excel[excel.tables.keys.first]!;
//
//       int count = 0;
//       // 3. Lặp qua các hàng (bỏ qua hàng 0 - tiêu đề)
//       for (int i = 1; i < sheet.maxRows; i++) {
//         final row = sheet.row(i);
//
//         // Helper để lấy giá trị chuỗi an toàn
//         String getCellValue(int index) {
//           return row[index]?.value?.toString() ?? '';
//         }
//
//         // Helper để chuyển chuỗi thành bool
//         bool parseBool(int index) {
//           final value = getCellValue(index).toLowerCase();
//           return value == '1' || value == 'true';
//         }
//
//         // Kiểm tra CCCD (cột 0) phải có giá trị
//         if (getCellValue(0).isEmpty) continue;
//
//         // 4. Tạo đối tượng CitizenInfo (Thứ tự phải KHỚP chính xác với lúc Export)
//         final citizen = CitizenInfo(
//             idNumber: getCellValue(0),
//             fullName: getCellValue(1),
//             dob: getCellValue(2),
//             nationality: getCellValue(3),
//             placeOfOrigin: getCellValue(4),
//             placeOfResidence: getCellValue(5),
//             sex: getCellValue(6),
//             dateOfExpiry: getCellValue(7),
//             personalIdentification: getCellValue(8),
//             dateOfIssue: getCellValue(9),
//             placeOfIssue: getCellValue(10),
//             hasVoted: parseBool(11) // Cột 11 là 'Đã bầu'
//         );
//
//         // 5. Chèn vào DB
//         await _dbHelper.insertCitizen(citizen);
//         count++;
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Đã nhập thành công $count mục vào database.')),
//       );
//
//     } catch (e, stack) {
//       print('Lỗi IMPORT Excel: $e\n$stack');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Lỗi khi nhập file. Vui lòng kiểm tra định dạng.')),
//       );
//     }
//   }

// =========================================================
//                       2. CHỨC NĂNG IMPORT
// =========================================================

  Future<void> importCitizens(BuildContext context) async {
    FilePickerResult? result;

    try {
      // 1. Mở trình chọn file
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        return; // Người dùng hủy chọn file
      }

      // Hiển thị loading
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang nhập dữ liệu...'),
                ],
              ),
            ),
          ),
        ),
      );

      // 2. Đọc file
      final filePath = result.files.single.path!;
      final bytes = File(filePath).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        if (!context.mounted) return;
        Navigator.pop(context); // Đóng loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File Excel không chứa dữ liệu!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final Sheet sheet = excel[excel.tables.keys.first]!;

      // Kiểm tra file có dữ liệu không (ít nhất 2 hàng: header + 1 dòng data)
      if (sheet.maxRows < 2) {
        if (!context.mounted) return;
        Navigator.pop(context); // Đóng loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File Excel trống hoặc chỉ có tiêu đề!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      int successCount = 0;
      int errorCount = 0;
      List<String> errorMessages = [];

      // 3. Lặp qua các hàng (bỏ qua hàng 0 - tiêu đề)
      for (int i = 1; i < sheet.maxRows; i++) {
        try {
          final row = sheet.row(i);

          // Helper để lấy giá trị chuỗi an toàn
          String getCellValue(int index) {
            if (index >= row.length) return '';
            return row[index]?.value?.toString().trim() ?? '';
          }

          // Helper để chuyển chuỗi thành bool
          bool parseBool(int index) {
            final value = getCellValue(index).toLowerCase();
            return value == '1' || value == 'true' || value == 'có';
          }

          // Kiểm tra CCCD (cột 0) phải có giá trị
          final idNumber = getCellValue(0);
          if (idNumber.isEmpty) {
            errorCount++;
            errorMessages.add('Dòng ${i + 1}: CCCD trống');
            continue;
          }

          // Kiểm tra họ tên (cột 1) phải có giá trị
          final fullName = getCellValue(1);
          if (fullName.isEmpty) {
            errorCount++;
            errorMessages.add('Dòng ${i + 1}: Họ tên trống (CCCD: $idNumber)');
            continue;
          }

          // 4. Tạo đối tượng CitizenInfo
          final citizen = CitizenInfo(
            idNumber: idNumber,
            fullName: fullName,
            dob: getCellValue(2),
            nationality: getCellValue(3),
            placeOfOrigin: getCellValue(4),
            placeOfResidence: getCellValue(5),
            sex: getCellValue(6),
            dateOfExpiry: getCellValue(7),
            personalIdentification: getCellValue(8),
            dateOfIssue: getCellValue(9),
            placeOfIssue: getCellValue(10),
            hasVoted: parseBool(11), // Cột 11 là 'Đã bầu'
          );

          // 5. Chèn vào DB (hoặc cập nhật nếu đã tồn tại)
          await _dbHelper.insertCitizen(citizen);
          successCount++;

        } catch (rowError) {
          errorCount++;
          errorMessages.add('Dòng ${i + 1}: ${rowError.toString()}');
          print('Lỗi xử lý dòng ${i + 1}: $rowError');
        }
      }

      // Đóng loading dialog
      if (!context.mounted) return;
      Navigator.pop(context);

      // Hiển thị kết quả chi tiết
      if (successCount > 0 || errorCount > 0) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  successCount > 0 ? Icons.check_circle : Icons.warning,
                  color: successCount > 0 ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                const Text('Kết quả Import'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅ Thành công: $successCount mục',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (errorCount > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '❌ Lỗi: $errorCount mục',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Chi tiết lỗi:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    ...errorMessages.take(5).map((msg) => Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Text(
                        '• $msg',
                        style: const TextStyle(fontSize: 12),
                      ),
                    )),
                    if (errorMessages.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 4),
                        child: Text(
                          '... và ${errorMessages.length - 5} lỗi khác',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
              if (successCount > 0)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Gọi _loadVoters() từ VoterManagementScreen
                  },
                  child: const Text('Xem danh sách'),
                ),
            ],
          ),
        );
      }

    } catch (e, stack) {
      print('Lỗi IMPORT Excel: $e\n$stack');

      // Đóng loading nếu đang mở
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (!context.mounted) return;

      // Hiển thị lỗi chi tiết
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Lỗi Import'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Không thể nhập file. Vui lòng kiểm tra:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('• File có đúng định dạng Excel (.xlsx/.xls)?'),
                const Text('• Cấu trúc cột có khớp với template?'),
                const Text('• File có bị hỏng không?'),
                const SizedBox(height: 12),
                const Text(
                  'Chi tiết lỗi:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  e.toString(),
                  style: const TextStyle(fontSize: 11, color: Colors.red),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }
}