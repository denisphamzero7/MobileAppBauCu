import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/scan_voter_request.dart';
import '../../network/database_helper.dart';
import '../../network/repository.dart'; // Đảm bảo đường dẫn này đúng

// ... (Class CitizenInfo của bạn ở đây) ...


class VoteScanScreen extends StatefulWidget {
  final VoidCallback? onGoHome; // Thêm onGoHome
  const VoteScanScreen({super.key, this.onGoHome});

  @override
  State<VoteScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<VoteScanScreen> {
  File? _imageFile;
  String _extractedText = "Chưa có dữ liệu"; // Vẫn giữ biến này cho logic
  CitizenInfo? _parsedInfo;
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer =
  TextRecognizer(script: TextRecognitionScript.latin);
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Repository _repository = Repository();
  bool _isProcessing = false;

  // 1. Hàm chọn ảnh (Camera hoặc Gallery)
  Future<void> _pickImage(ImageSource source) async {
    if (_isProcessing) return;

    final XFile? pickedFile;
    try {
      pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null || !mounted) return;
    } catch (exception) {
      print("Lỗi khi chọn ảnh: $exception");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn ảnh: $exception')),
      );
      return;
    }

    _startProcessing(pickedFile.path);
  }
// vote_screen.dart (Thay thế _saveToDatabase bằng _confirmVoteAndSave)

// 5. Hàm xác nhận đi bầu (Gửi API và lưu SQLite)
  Future<void> _confirmVoteAndSave() async {
    if (_parsedInfo == null || !mounted || _isProcessing) return;

    final String cccdToConfirm = _parsedInfo!.idNumber;
    final requestData = ScanVoterRequest(cccd: cccdToConfirm);

    setState(() {
      _isProcessing = true;
    });

    try {
      // --- 1. KIỂM TRA & CHÈN VÀO SQLITE CỤC BỘ ---
      // Kiểm tra xem cử tri đã có chưa
      final existingCitizen = await _dbHelper.getCitizenByCCCD(cccdToConfirm);

      if (existingCitizen == null) {
        // Nếu CHƯA CÓ, chèn bản ghi đầy đủ từ thẻ quét vào SQLite
        await _dbHelper.insertCitizen(_parsedInfo!);
        print('Đã chèn bản ghi mới vào SQLite: ${cccdToConfirm}');
      } else {
        print('Bản ghi đã tồn tại trong SQLite. Bỏ qua chèn.');
      }

      // 2. GỌI API XÁC NHẬN ĐI BẦU
      final response = await _repository.scanVoter(requestData);

      // 3. Xử lý phản hồi API
      if (response != null && response.statusCode == 201) {

        // 4. CẬP NHẬT TRẠNG THÁI ĐÃ BẦU: Chỉ cập nhật cột hasVoted = true.
        // Bản ghi này đã tồn tại nhờ bước 1 (hoặc tồn tại sẵn).
        await _dbHelper.markVoterAsVoted(cccdToConfirm);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green.shade700,
          ),
        );

        // Reset trạng thái
        setState(() {
          _parsedInfo = null;
          _imageFile = null;
        });

      } else {
        // ... (Xử lý lỗi API)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.message ?? 'Lỗi xác nhận cử tri không xác định.'),
            backgroundColor: Colors.orange.shade700,
          ),
        );
      }
    } catch (e) {
      // ... (Xử lý lỗi Dio)
      print("Lỗi khi gọi API xác nhận: $e");
      String errorMessage = 'Lỗi kết nối hoặc thông tin cử tri không hợp lệ.';
      if (e is DioException && e.response != null) {
        errorMessage = e.response!.data['message'] ?? 'Lỗi từ máy chủ: ${e.response!.statusCode}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  /// 1c. Hàm chung để bắt đầu xử lý
  Future<void> _startProcessing(String imagePath) async {
    final file = File(imagePath);
    final int fileLength;
    try {
      fileLength = await file.length();
    } catch (e) {
      print("Lỗi khi kiểm tra độ dài tệp: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể truy cập tệp ảnh.')),
      );
      return;
    }

    if (fileLength == 0) {
      print("Lỗi: Tệp ảnh rỗng (0 byte).");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Tệp ảnh được chọn bị hỏng hoặc rỗng.')),
      );
      return;
    }

    setState(() {
      _imageFile = file;
      _extractedText = "Đang xử lý...";
      _parsedInfo = null;
      _isProcessing = true;
    });

    _processImage(imagePath);
  }

  // 2. Hàm xử lý ảnh bằng ML Kit
  Future<void> _processImage(String imagePath) async {
    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    RecognizedText recognizedText;

    try {
      recognizedText = await _textRecognizer.processImage(inputImage);
    } catch (e) {
      print("Lỗi khi xử lý ảnh ML Kit: $e");
      setState(() {
        _extractedText = "Lỗi khi xử lý ảnh: $e"; // Vẫn set lỗi (cho debug)
        _parsedInfo = null;
        _isProcessing = false;
      });
      return;
    }

    String fullText = recognizedText.text;

    // 3. Phân tích dữ liệu
    CitizenInfo parsedData = _parseCCCD(fullText);

    setState(() {
      _extractedText = fullText; // Vẫn set dữ liệu thô (cho debug)
      _parsedInfo = parsedData;
      _isProcessing = false;
    });
  }

  // 3. Hàm phân tích (Giữ nguyên logic của VoteScanScreen)
  CitizenInfo _parseCCCD(String rawText) {
    print("--- Dữ liệu thô từ ML Kit (Quét Thẻ Cử Tri) ---");
    print(rawText);
    print("-----------------------------");

    const String basePattern = r"\s*(?:\(\d\))?\s*:?\s*(?:[\s(),)]*)([^\n]*)";
    const String dobPattern = r"(\d{1,2}[\/\s-]\d{1,2}[\/\s-]\d{4})";

    String fullName = _findValue(rawText, r"H[ọo] và tên" + basePattern);
    String dob = _findValue(rawText, dobPattern);

    if (dob != "Không tìm thấy") {
      dob = dob
          .replaceAll(' ', '')
          .replaceAll('S', '8')
          .replaceAll('O', '0')
          .replaceAll('-', '/')
          .trim();
    }

    String sex = _findValue(rawText, r"Gi[ớó]i t[iíỉ]nh" + basePattern);
    if (sex != "Không tìm thấy") {
      sex = sex.trim();
    }

    String idNumber = _findValue(rawText,
        r"(?:S0|Số|So|S6I|SáI)[\s\S]*?(?:No)?:?[\s\S]*?(\d{8}[\s-]?\d{4})");
    if (idNumber == "Không tìm thấy") {
      idNumber = _findValue(rawText, r"(\d{8}[\s-]?\d{4})");
    }
    if (idNumber != "Không tìm thấy") {
      idNumber = idNumber.replaceAll(' ', '').replaceAll('-', '');
    }

    return CitizenInfo(
      idNumber: idNumber.trim(),
      fullName: fullName.trim(),
      dob: dob.trim(),
      sex: sex.trim(),
      placeOfResidence: "",
      nationality: 'Không quét',
      placeOfOrigin: 'Không quét',
      dateOfExpiry: 'Không quét',
      personalIdentification: 'Không quét',
      dateOfIssue: 'Không quét',
      placeOfIssue: 'Không quét',
    );
  }

  // 4. Hàm trợ giúp dùng RegEx (Không đổi)
  String _findValue(String text, String pattern) {
    final match = RegExp(
      pattern,
      caseSensitive: false,
      multiLine: true,
      dotAll: true,
    ).firstMatch(text);

    return match?.group(1)?.trim() ?? "Không tìm thấy";
  }

  // 5. Hàm lưu vào database (Giữ nguyên)
  Future<void> _saveToDatabase() async {
    if (_parsedInfo != null && mounted && !_isProcessing) {
      await _dbHelper.insertCitizen(_parsedInfo!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã lưu vào database!'),
          backgroundColor: Colors.green[700],
        ),
      );
    }
  }

  // 6. Hàm Build (ĐÃ XÓA DỮ LIỆU THÔ)
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Colors.blue;
    const Color whiteColor = Colors.white;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Quét Thẻ Cử Tri'),
        backgroundColor: Colors.blue[700],
        foregroundColor: whiteColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: whiteColor),
          onPressed: () {
            if (widget.onGoHome != null) {
              widget.onGoHome!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Khung hiển thị ảnh
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isProcessing
                    ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: primaryColor),
                        const SizedBox(height: 16),
                        Text("Đang phân tích ảnh...",
                            style: TextStyle(color: primaryColor)),
                      ],
                    ))
                    : (_imageFile != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(11.0),
                  child: Image.file(
                    _imageFile!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      print(
                          "Lỗi không thể hiển thị ảnh (errorBuilder): $error");
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey[400],
                                size: 50,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Lỗi hiển thị ảnh",
                                style:
                                TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
                    : Center(
                    child: Text(
                      'Bấm nút "Camera" hoặc "Chọn Ảnh"',
                      style: TextStyle(color: Colors.grey[600]),
                    ))),
              ),
              const SizedBox(height: 16),

              // Hàng nút bấm
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: whiteColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Chọn Ảnh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: whiteColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tiêu đề kết quả
              Text('Thông tin cử tri đi bầu cử:',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: primaryColor, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              if (_parsedInfo != null) ...[
                // InfoCard
                InfoCard(label: 'Số Căn cước', value: _parsedInfo!.idNumber),
                InfoCard(label: 'Họ tên', value: _parsedInfo!.fullName),
                InfoCard(label: 'Ngày sinh', value: _parsedInfo!.dob),
                InfoCard(label: 'Giới tính', value: _parsedInfo!.sex),
                const SizedBox(height: 16),

                // Nút Lưu
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _confirmVoteAndSave,
                  icon: const Icon(Icons.save_alt_outlined),
                  label: const Text('Xát nhận đi bầu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: whiteColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ] else if (!_isProcessing)
                const Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Chưa có thông tin...',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              // *** PHẦN DỮ LIỆU THÔ ĐÃ BỊ XÓA TỪ ĐÂY ***
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget InfoCard (Không đổi)
class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  const InfoCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 2,
      shadowColor: Colors.blue.withOpacity(0.1),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? "(Trống)" : value, // Thêm xử lý giá trị rỗng
                style: TextStyle(
                  fontSize: 15,
                  color: value.isEmpty ? Colors.grey.shade600 : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}