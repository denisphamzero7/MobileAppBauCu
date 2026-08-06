// camera_scan_screen.dart
// PHIÊN BẢN CẬP NHẬT: ĐÃ FIX LỖI CRASH KHI ẢNH HỎNG
// ĐÃ XÓA TRƯỜNG "NƠI CƯ TRÚ" THEO YÊU CẦU

import 'dart:io';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';


import 'package:image_picker/image_picker.dart';

// Import model VoterInfo và DatabaseHelper của bạn
import '../../model/vote_info.dart';
import '../../network/database_vote_helper.dart';

class CameraScanScreen2 extends StatefulWidget {
  final VoidCallback? onGoHome;
  const CameraScanScreen2({super.key, this.onGoHome});

  @override
  State<CameraScanScreen2> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen2> {
  File? _imageFile;
  VoterInfo? _parsedInfo;

  final TextRecognizer _textRecognizer =
  TextRecognizer(script: TextRecognitionScript.latin);
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final ImagePicker _picker = ImagePicker();

  bool _isProcessing = false;

  /// 1. Hàm quét ảnh (Từ Camera)
  Future<void> _pickImage() async {
    if (_isProcessing) return;

    final List<String>? pictures;

    try {
      pictures = await CunningDocumentScanner.getPictures();
      if (pictures == null || pictures.isEmpty || !mounted) return;
    } catch (exception) {
      print("Lỗi khi quét tài liệu: $exception");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi quét: $exception')),
      );
      return;
    }

    final String imagePath = pictures.first;
    // SỬA: Gọi hàm xử lý đã được cập nhật
    _startProcessing(imagePath);
  }

  /// 1b. Hàm chọn ảnh (Từ Thư viện)
  Future<void> _pickImageFromGallery() async {
    if (_isProcessing) return;

    final XFile? image;
    try {
      image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) return;
    } catch (exception) {
      print("Lỗi khi chọn ảnh từ thư viện: $exception");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn ảnh: $exception')),
      );
      return;
    }

    final String imagePath = image.path;
    // SỬA: Gọi hàm xử lý đã được cập nhật
    _startProcessing(imagePath);
  }

  /// 1c. Hàm chung để bắt đầu xử lý (<<< ĐÃ CẬP NHẬT)
  Future<void> _startProcessing(String imagePath) async {
    // <<< SỬA: THÊM BƯỚC KIỂM TRA TỆP RỖNG (0-BYTE)
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
      return; // Không làm gì cả
    }
    // <<< KẾT THÚC KIỂM TRA

    setState(() {
      _imageFile = file; // Dùng file đã khởi tạo
      _parsedInfo = null;
      _isProcessing = true;
    });

    _processImage(imagePath);
  }

  /// 2. HÀM XỬ LÝ ẢNH (Không đổi logic ML Kit)
  Future<void> _processImage(String imagePath) async {
    // Gửi ảnh (ảnh gốc) cho ML Kit
    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    RecognizedText recognizedText;

    try {
      recognizedText = await _textRecognizer.processImage(inputImage);
    } catch (e) {
      print("Lỗi khi xử lý ảnh ML Kit: $e");
      setState(() {
        _parsedInfo = null;
        _isProcessing = false;
      });
      return;
    }

    String fullText = recognizedText.text;
    VoterInfo parsedData = _parseVoterCard(fullText);

    setState(() {
      _parsedInfo = parsedData;
      _isProcessing = false;
    });
  }

  // 3. Hàm phân tích THẺ CỬ TRI (<<< ĐÃ XÓA NƠI CƯ TRÚ)
  VoterInfo _parseVoterCard(String rawText) {
    print("--- Dữ liệu thô từ ML Kit (Thẻ Cử Tri) ---");
    print(rawText);
    print("---------------------------------------");

    String paddedText = "$rawText\nEND_OF_TEXT\n";

    // === CÁC MẪU REGEX VÀ CLEANUP RIÊNG BIỆT ===

    // 1. Họ tên
    String fullName = _findValue(
        paddedText,
        r"(?:H[ọo](?:\s*v[àaå])?\s*t[êeế]n):?\s*([^\n]*)") ??
        "Không tìm thấy";

    if (fullName != "Không tìm thấy") {
      fullName =
          fullName.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    }

    // 2. Ngày sinh
    String dob = _findValue(
        paddedText,
        r"(?:Ng[àa]y|Ngay)[\s,]*th[áa]ng[\s,]*n[ăâáấm].*sinh:?\s*(\d{2}[\/][\dSO]{2}[\/][\dSO]{4})") ??
        _findValue(paddedText, r"(\d{2}[\/][\dSO]{2}[\/][\dSO]{4})") ??
        "Không tìm thấy";
    if (dob != "Không tìm thấy") {
      dob = dob.replaceAll('S', '8').replaceAll('O', '0');
    }

    // 3. Giới tính
    String sex = _findValue(
        paddedText,
        r"(?:G[ií]ới|Giói|Gớn|Gidi).{1,5}?t[íi]nh:?\s*(Nam|N[ữ])") ??
        "Không tìm thấy";
    if (sex != "Không tìm thấy") {
      sex = sex.trim();
    }

    // 4. Nơi cư trú <<< ĐÃ XÓA LOGIC PARSING

    // 5. Số Căn cước
    String citizenIdNumber = _findValue(paddedText,
        r"(?:S[ốo]\s*C[ăa]n\s*c[ưou].{1,5}?c|S[ốo]\s*CCCD):?\s*(\d[\d\s-]{10,14}\d)") ??
        _findValue(paddedText, r"\b(\d{12})\b") ??
        "Không tìm thấy";

    if (citizenIdNumber != "Không tìm thấy") {
      citizenIdNumber =
          citizenIdNumber.replaceAll(' ', '').replaceAll('-', '').trim();
      if (citizenIdNumber.length > 12) {
        citizenIdNumber = citizenIdNumber.substring(0, 12);
      }
    }

    // Trả về đối tượng
    return VoterInfo(
      fullName: fullName,
      dob: dob,
      sex: sex,
      citizenIdNumber: citizenIdNumber,
      issuingAuthority: null,
      voterCardNumber: null,
      pollingAreaNumber: null,
      ward: null,
      city: null, placeOfResidence: '',
    );
  }

  // 4. Hàm trợ giúp dùng RegEx (Không đổi)
  String? _findValue(String text, String pattern) {
    final match = RegExp(
      pattern,
      caseSensitive: false,
      multiLine: true,
      dotAll: true,
    ).firstMatch(text);

    return match?.group(1)?.trim();
  }

  /// 6. Giao diện (Build method - <<< ĐÃ CẬP NHẬT IMAGE.FILE)
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Colors.blue;
    const Color whiteColor = Colors.white;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Quét Thẻ Cử Tri'),
        backgroundColor: primaryColor,
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
                  // <<< SỬA CHÍNH: BỌC LẠI IMAGE.FILE ĐỂ BẮT LỖI
                  child: Image.file(
                    _imageFile!,
                    fit: BoxFit.contain,
                    // THÊM CÁI NÀY ĐỂ TRÁNH CRASH
                    errorBuilder: (context, error, stackTrace) {
                      print("Lỗi không thể hiển thị ảnh (errorBuilder): $error");
                      // Hiển thị một widget thay thế
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey[400],
                                size: 50,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Lỗi hiển thị ảnh",
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // <<< KẾT THÚC SỬA
                )
                    : Center(
                    child: Text(
                      'Bấm nút "Quét Mới" hoặc "Chọn Ảnh"',
                      style: TextStyle(color: Colors.grey[600]),
                    ))),
              ),
              const SizedBox(height: 16),
              // (Các nút bấm không đổi)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _pickImage, // Camera
                      icon: const Icon(Icons.document_scanner_outlined),
                      label: const Text('Quét Mới'),
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
                      onPressed:
                      _isProcessing ? null : _pickImageFromGallery, // Gallery
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Chọn Ảnh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, // Màu khác
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
              Text('Thông tin đã phân tích:',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                      color: primaryColor, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (_parsedInfo != null) ...[
                InfoCard(label: 'Họ tên', value: _parsedInfo!.fullName),
                InfoCard(label: 'Ngày sinh', value: _parsedInfo!.dob),
                InfoCard(label: 'Giới tính', value: _parsedInfo!.sex),
                // <<< ĐÃ XÓA INFOCARD NƠI CƯ TRÚ
                InfoCard(
                    label: 'Số Căn cước',
                    value: _parsedInfo!.citizenIdNumber),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Chức năng "Xác nhận Bầu cử" chưa được cài đặt!'),
                          backgroundColor: primaryColor),
                    );
                  },
                  icon: const Icon(Icons.how_to_vote_outlined),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: whiteColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  label: const Text('Xác nhận Bầu cử'),
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
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget phụ trợ (Không đổi)
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
                value,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}