import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../network/database_helper.dart'; // Đảm bảo đường dẫn này đúng

// ... (Class CitizenInfo của bạn ở đây) ...

class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  File? _imageFile;
  String _extractedText = "Chưa có dữ liệu";
  CitizenInfo? _parsedInfo;
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer =
  TextRecognizer(script: TextRecognitionScript.latin);
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isProcessing = false; // *** THÊM MỚI: Cờ trạng thái xử lý ***

  // 1. Hàm chọn ảnh
  Future<void> _pickImage(ImageSource source) async {
    // *** THÊM MỚI: Ngăn chặn xử lý chồng chéo ***
    if (_isProcessing) return;

    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _extractedText = "Đang xử lý...";
        _parsedInfo = null;
        _isProcessing = true; // *** THÊM MỚI: Bắt đầu xử lý ***
      });
      // *** THÊM MỚI: Đảm bảo await để bắt lỗi (nếu có) ***
      await _processImage(pickedFile.path);
    }
  }

  // 2. Hàm xử lý ảnh bằng ML Kit
  Future<void> _processImage(String imagePath) async {
    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    RecognizedText recognizedText;

    try {
      // *** THÊM MỚI: Khối try...catch ***
      recognizedText = await _textRecognizer.processImage(inputImage);
    } catch (e) {
      // *** THÊM MỚI: Xử lý lỗi nếu ML Kit thất bại ***
      setState(() {
        _extractedText = "Lỗi khi xử lý ảnh: $e";
        _parsedInfo = null;
        _isProcessing = false; // Kết thúc xử lý
      });
      return; // Dừng hàm
    }

    String fullText = recognizedText.text;

    // 3. Phân tích dữ liệu
    CitizenInfo parsedData = _parseCCCD(fullText);

    setState(() {
      _extractedText = fullText;
      _parsedInfo = parsedData;
      _isProcessing = false; // *** THÊM MỚI: Kết thúc xử lý ***
    });
  }
// 3. Hàm phân tích CCCD (ĐÃ CẬP NHẬT LẦN CUỐI)
  CitizenInfo _parseCCCD(String rawText) {
    print("--- Dữ liệu thô từ ML Kit (Đã sửa) ---");
    print(rawText);
    print("-----------------------------");

    // === CÁC MẪU REGEX HOÀN CHỈNH ===

    // 1. Số CCCD: (Giữ nguyên)
    String idNumber = _findValue(
        rawText, r"(?:S0|Số|So|S6I|SáI)[\s\S]*?(?:No)?:?[\s\S]*?(\d{8}[\s-]?\d{4})");
    if (idNumber == "Không tìm thấy") {
      idNumber = _findValue(rawText, r"(\d{8}[\s-]?\d{4})");
    }
    if (idNumber != "Không tìm thấy") {
      idNumber = idNumber.replaceAll(' ', '').replaceAll('-', '');
    }

    // 2. Họ tên: (Giữ nguyên)
    String fullName = _findValue(
        rawText, r"(?:H[ọo] và tên|Ho va ten):?\s*([^\n]*)") ??
        "Không tìm thấy";

    // Cleanup cho Họ Tên:
    if (fullName != "Không tìm thấy") {
      fullName = fullName.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    }

    // 3. Ngày sinh: (Giữ nguyên)
    String dob = _findValue(rawText,
        r"Ngày sinh[\s\S]*?Date of b[i]?[r]?th:?[\s\S]*?(\d{2}[\/I][\dO]{2}[\/I][\dO]{4})");
    if (dob != "Không tìm thấy") {
      dob = dob.replaceAll('O', '0').replaceAll('I', '/');
    }

    // 4. Giới tính: (Giữ nguyên)
    String sex =
    _findValue(rawText, r"Gi[ớo]i t[íi]nh[\s\S]*?Sex:?[\s\S]*?(Nam|N[ữM])");

    // 5. Quốc tịch: (Giữ nguyên)
    String nationality = _findValue(
        rawText, r"(?:Qu[ốô]c t[l]ch|Nat[i]?onality):?[\s\S]*?(Vi[ệe]t Nam)");

    // 6. Quê quán: (*** ĐÃ SỬA ĐIỀU KIỆN DỪNG ***)
    // Sửa lỗi: Chúng ta không thể tin "Nơi thường trú" là điểm dừng,
    // vì nó có thể bị lẫn. Chúng ta dừng ở "Giới tính" (Sex) hoặc "Quốc tịch".
    String placeOfOrigin = _findValue(rawText,
        r"(?:Quê (?:quán|quan|qun|quận)|Place of (?:origin|ogin|oigin|odgin/orgin/ongin)):?([\s\S]*?)(?=(?:N[oơ]i (?:thường|thưÒng) (?:tr[úù]|trủ[l]?))|(?:Gi[ớo]i t[íi]nh)|(?:Qu[ốô]c t[l]ch)|(?:Sex)|(?:Nationality)|(?:C[óo] gi[áa]))");

    if (placeOfOrigin != "Không tìm thấy") {
      placeOfOrigin = placeOfOrigin
          .replaceAll(RegExp(r'Place of origin[:;]?', caseSensitive: false), '')
          .replaceAll('\n', ', ')
          .replaceAll(RegExp(r'[, ]{2,}'), ', ')
          .replaceAll(RegExp(r'^[,\s]+'), '')
          .replaceAll(RegExp(r'[,\s]+$'), '')
          .trim();
    }

    // 7. Nơi thường trú: (*** ĐÃ SỬA LOGIC HOÀN TOÀN ***)
    // Chiến lược mới: Lấy MỌI THỨ sau "Nơi thường trú"
    // và sau đó dọn dẹp bằng tay.

    // Bước 7.1: Lấy MỌI THỨ (greedy) từ "Nơi thường trú" đến hết chuỗi
    String placeOfResidenceRaw = _findValue(rawText,
        r"(?:N[oơ]i (?:thường|thưÒng) (?:tr[úù]|trủ[l]?)|Place (?:af residence|of residence|ofesidence)):?([\s\S]*)");

    String placeOfResidence = "Không tìm thấy";
    if (placeOfResidenceRaw != "Không tìm thấy") {

      // Bước 7.2: Xóa các label tiếng Anh có thể bị dính
      placeOfResidenceRaw = placeOfResidenceRaw.replaceAll(
          RegExp(r'Place (?:af residence|of residence|ofesidence)[:;]?',
              caseSensitive: false),
          '');

      // Bước 7.3: Tách thành các dòng
      List<String> lines = placeOfResidenceRaw.split('\n');
      List<String> cleanLines = [];

      // Bước 7.4: Duyệt qua từng dòng và *dừng lại* nếu gặp rác
      for (String line in lines) {
        String lowerLine = line.toLowerCase().trim();

        if (lowerLine.isEmpty) continue;

        // Đây là ĐIỀU KIỆN DỪNG MỚI: Nếu gặp bất kỳ
        // văn bản nào KHÔNG liên quan đến địa chỉ, DỪNG LẠI.
        if (lowerLine.contains('date of') ||
            lowerLine.contains('expiry') ||
            lowerLine.contains('giá trị') ||
            lowerLine.contains('đến') ||
            lowerLine.contains('08/10') || // Dừng nếu gặp ngày tháng
            lowerLine.contains('co giá') ||
            lowerLine.contains('xem ẩn') ||
            lowerLine.contains('le') ||
            lowerLine.contains('date afbrpg')) {
          break; // Thoát khỏi vòng lặp
        }

        // Nếu dòng này OK, thêm vào danh sách
        cleanLines.add(line);
      }

      // Bước 7.5: Ghép các dòng sạch lại
      placeOfResidence = cleanLines.join(', ');

      // Bước 7.6: Dọn dẹp cuối cùng
      placeOfResidence = placeOfResidence
          .replaceAll(RegExp(r'^\s*[\/\\-]\s*'), '')
          .replaceAll(RegExp(r'[, ]{2,}'), ', ')
          .replaceAll(RegExp(r'^[,\s]+'), '')
          .replaceAll(RegExp(r'[,\s]+$'), '')
          .trim();
    }

    // 8. Có giá trị đến: (Giữ nguyên, vẫn tìm trong TOÀN BỘ văn bản)
    String dateOfExpiry = _findValue(rawText,
        r"(?:C[óo] gi[áa] (?:tr[ịi]|erị) (?:[đđ][ếe]n|đồn)|Date ofexpiry|Date ofxpiry|co glá ut bn|Co giá tt đến):?[\s\S]*?(\d{2}[\/I][\dO]{2}[\/I][\dO]{4})");

    if (dateOfExpiry != "Không tìm thấy") {
      dateOfExpiry = dateOfExpiry.replaceAll('O', '0').replaceAll('I', '/').replaceAll('r', '');
    }

    // Trả về đối tượng "chuẩn"
    return CitizenInfo(
      idNumber: idNumber.trim(),
      fullName: fullName.trim(),
      dob: dob.trim(),
      nationality: nationality.trim(),
      placeOfOrigin: placeOfOrigin.trim(),
      placeOfResidence: placeOfResidence.trim(), // Đã được sửa
      sex: sex.trim(),
      dateOfExpiry: dateOfExpiry.trim(),
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



  // 5. Hàm lưu vào database
  Future<void> _saveToDatabase() async {
    // *** THÊM MỚI: Ngăn chặn lưu khi đang xử lý ***
    if (_parsedInfo != null && mounted && !_isProcessing) {
      await _dbHelper.insertCitizen(_parsedInfo!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu vào database!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét Căn cước công dân'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // *** CẬP NHẬT: Hiển thị ảnh HOẶC vòng tải ***
              Container(
                height: 200,
                color: Colors.grey[300],
                child: _isProcessing
                    ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Đang phân tích ảnh..."),
                      ],
                    ))
                    : (_imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : const Center(child: Text('Chọn ảnh để quét'))),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // *** CẬP NHẬT: Vô hiệu hóa nút khi đang xử lý ***
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.image),
                    label: const Text('Gallery'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Thông tin đã phân tích:',
                  style: Theme.of(context).textTheme.headlineSmall),
              if (_parsedInfo != null) ...[
                InfoCard(label: 'Số CCCD', value: _parsedInfo!.idNumber),
                InfoCard(label: 'Họ tên', value: _parsedInfo!.fullName),
                InfoCard(label: 'Ngày sinh', value: _parsedInfo!.dob),
                InfoCard(label: 'Quốc tịch', value: _parsedInfo!.nationality),
                InfoCard(label: 'Quê quán', value: _parsedInfo!.placeOfOrigin),
                InfoCard(
                    label: 'Nơi thường trú',
                    value: _parsedInfo!.placeOfResidence),
                const SizedBox(height: 16),
                // *** CẬP NHẬT: Vô hiệu hóa nút khi đang xử lý ***
                ElevatedButton(
                  onPressed: _isProcessing ? null : _saveToDatabase,
                  style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Lưu vào Database'),
                ),
              ] else if (!_isProcessing) // Chỉ hiển thị nếu không đang tải
                const Text('Chưa có thông tin...'),

              const SizedBox(height: 24),
              Text('Dữ liệu thô từ ML Kit:',
                  style: Theme.of(context).textTheme.headlineSmall),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey[100],
                child: Text(_extractedText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget phụ trợ (Không đổi)
class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  const InfoCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Text('$label: ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: Text(value)),
          ],
        ),
      ),
    );
  }
}