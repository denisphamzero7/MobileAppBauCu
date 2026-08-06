import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';


import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Dùng để lấy tên file từ path

class AddFeedbackScreen extends StatefulWidget {
  const AddFeedbackScreen({super.key});

  @override
  State<AddFeedbackScreen> createState() => _AddFeedbackScreenState();
}

class _AddFeedbackScreenState extends State<AddFeedbackScreen> {
  // 1. Khai báo các controller
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();

  // 2. Khai báo các biến State
  String? _selectedCategory;
  String? _selectedPriority = 'Medium';
  DateTime? _selectedDateTime;
  String? _pickedImageName;
  String? _takenPhotoName;
  String? _pickedVideoName;
  String? _pickedFileName;

  // 3. Khởi tạo ImagePicker
  final ImagePicker _picker = ImagePicker();

  // Dữ liệu giả cho Dropdown và Radio
  final List<String> _categories = [
    'An ninh trật tự',
    'An toàn giao thông',
    'Vệ sinh môi trường',
    'Khác'
  ];
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ----- (Các hàm build UI giữ nguyên, không thay đổi) -----
  // ----- HÀM BUILD MỘT Ô NHẬP LIỆU CÓ NHÃN (TEXT) -----
  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
          controller: controller,
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  // ----- HÀM BUILD Ô NHẬP LIỆU NỘI DUNG (TEXTAREA) -----
  Widget _buildContentTextField({
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Nội dung'),
        TextField(
          controller: controller,
          maxLines: 5,
          decoration: _inputDecoration(hint: hint),
        ),
      ],
    );
  }

  // ----- HÀM BUILD DROPDOWN (SELECT BOX) -----
  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Danh mục'),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          hint: const Text('Chọn danh mục'),
          decoration: _inputDecoration(),
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
        ),
      ],
    );
  }

  // ----- HÀM BUILD CÁC NÚT RADIO -----
  Widget _buildPriorityRadios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Mức độ ưu tiên'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: _priorities.map((priority) {
              return RadioListTile<String>(
                title: Text(priority),
                value: priority,
                groupValue: _selectedPriority,
                onChanged: (newValue) {
                  setState(() {
                    _selectedPriority = newValue;
                  });
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ----- HÀM BUILD TRƯỜNG CHỌN NGÀY GIỜ (DATETIME) -----
  Widget _buildDateTimePicker() {
    // SỬ DỤNG GÓI 'intl' ĐỂ FORMAT NGÀY
    final displayDate = _selectedDateTime == null
        ? 'Chọn ngày giờ'
        : DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Thời điểm diễn ra'),
        TextFormField(
          readOnly: true,
          decoration: _inputDecoration(
            hint: displayDate,
            suffixIcon: const Icon(Icons.calendar_month),
          ),
          onTap: _pickDateTime,
        ),
      ],
    );
  }

  // ----- HÀM BUILD CÁC NÚT CHỌN MEDIA (FILE, IMAGE, CAMERA...) -----
  Widget _buildMediaButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMediaButton(
                label: 'Hình ảnh',
                icon: Icons.image_outlined,
                fileName: _pickedImageName,
                onPressed: _pickImage,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMediaButton(
                label: 'Video',
                icon: Icons.videocam_outlined,
                fileName: _pickedVideoName,
                onPressed: _pickVideo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMediaButton(
                label: 'Camera',
                icon: Icons.camera_alt_outlined,
                fileName: _takenPhotoName,
                onPressed: _takePhoto,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMediaButton(
                label: 'Tệp đính kèm',
                icon: Icons.attach_file_outlined,
                fileName: _pickedFileName,
                onPressed: _pickFile,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ----- HÀM BUILD NÚT XÁC NHẬN -----
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        // In tất cả giá trị ra console
        print('----- GỬI PHẢN ÁNH -----');
        print('Tiêu đề: ${_titleController.text}');
        print('Nội dung: ${_contentController.text}');
        print('Địa điểm: ${_locationController.text}');
        print('Danh mục: $_selectedCategory');
        print('Ưu tiên: $_selectedPriority');
        print('Thời gian: $_selectedDateTime');
        print('Ảnh: $_pickedImageName');
        print('Video: $_pickedVideoName');
        print('Camera: $_takenPhotoName');
        print('File: $_pickedFileName');
        print('------------------------');

        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[400],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 0,
      ),
      child: const Text(
        'Xác nhận',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ----- HÀM BUILD CHÍNH CỦA MÀN HÌNH -----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm mới Góp ý - Phản ánh'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLabeledTextField(
                  label: 'Tiêu đề',
                  controller: _titleController,
                ),
                const SizedBox(height: 16),
                _buildContentTextField(
                  hint: 'Vui lòng nhập nội dung góp ý, phản ánh của bạn',
                  controller: _contentController,
                ),
                const SizedBox(height: 16),
                _buildCategoryDropdown(), // (SELECT BOX)
                const SizedBox(height: 16),
                _buildLabeledTextField(
                  label: 'Địa điểm diễn ra',
                  controller: _locationController,
                ),
                const SizedBox(height: 16),
                _buildDateTimePicker(), // (DATETIME)
                const SizedBox(height: 16),
                _buildPriorityRadios(), // (RADIO)
                const SizedBox(height: 24),
                _buildMediaButtons(), // (FILE, IMAGE, CAMERA...)
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // **********************************************
  // *********** CÁC HÀM TIỆN ÍCH (HELPER) **********
  // **********************************************

  // ----- Tiện ích: Build Nhãn -----
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ----- Tiện ích: Style chung cho InputDecoration -----
  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2.0),
      ),
    );
  }

  // ----- Tiện ích: Nút chọn media (có hiển thị tên file) -----
  Widget _buildMediaButton({
    required String label,
    required IconData icon,
    String? fileName,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.blue[700]),
      label: Flexible(
        child: Text(
          fileName ?? label,
          style: TextStyle(
            color: fileName != null ? Colors.blue[700] : Colors.grey[800],
            fontSize: 13,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  // **********************************************
  // ********** CÁC HÀM XỬ LÝ (LOGIC) *************
  // * (ĐÃ CẬP NHẬT) *
  // **********************************************

  // Hàm helper để lấy tên file từ Path (cho gọn)
  String _getFileName(String path) {
    return path.split('/').last;
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  // ----- HÀM CHỌN ẢNH TỪ THƯ VIỆN -----
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _pickedImageName = _getFileName(image.path);
        });
      }
    } catch (e) {
      print('Lỗi khi chọn ảnh: $e');
      // TODO: Hiển thị SnackBar hoặc thông báo lỗi cho người dùng
    }
  }

  // ----- HÀM CHỌN VIDEO TỪ THƯ VIỆN -----
  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _pickedVideoName = _getFileName(video.path);
        });
      }
    } catch (e) {
      print('Lỗi khi chọn video: $e');
    }
  }

  // ----- HÀM CHỤP ẢNH TỪ CAMERA -----
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _takenPhotoName = _getFileName(photo.path);
        });
      }
    } catch (e) {
      print('Lỗi khi chụp ảnh: $e');
    }
  }

  // ----- HÀM CHỌN FILE TỪ BỘ NHỚ -----
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single != null) {
        setState(() {
          _pickedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      print('Lỗi khi chọn file: $e');
    }
  }
}