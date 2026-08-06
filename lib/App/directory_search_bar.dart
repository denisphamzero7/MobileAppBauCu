import 'package:flutter/material.dart';

class DirectorySearchBar extends StatelessWidget {
  // 1. Khai báo các tham số mà widget này sẽ nhận từ bên ngoài
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText; // Thêm hintText để có thể tùy chỉnh

  const DirectorySearchBar({
    super.key,
    required this.controller, // Bắt buộc phải có controller
    required this.onChanged,  // Bắt buộc phải có hàm xử lý
    this.hintText = 'Nhập từ khóa tìm kiếm', // Đặt giá trị mặc định
  });

  @override
  Widget build(BuildContext context) {
    // 2. GỠ BỎ Scaffold
    // Widget tái sử dụng không bao giờ được chứa Scaffold
    // Chỉ trả về Padding chứa TextField
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: TextField(
        controller: controller, // 3. Dùng controller được truyền vào
        onChanged: onChanged,   // 4. Dùng hàm onChanged được truyền vào
        decoration: InputDecoration(
          hintText: hintText, // 5. Dùng hintText được truyền vào
          suffixIcon: Icon(Icons.search, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0), // Bo tròn
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2.0),
          ),
        ),
      ),
    );
  }
}