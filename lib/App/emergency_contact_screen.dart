import 'package:flutter/material.dart';

// ----- BƯỚC 1: TẠO MODEL CHO DỮ LIỆU -----
// (Bạn có thể tách class này ra file riêng)
class EmergencyContact {
  final String name;
  final String phone;
  final IconData icon; // Đường dẫn đến ảnh (ví dụ: 'assets/images/ic_sos.png')

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.icon,
  });
}

// ----- BƯỚC 2: MÀN HÌNH DANH BẠ -----

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  // ----- DỮ LIỆU TĨNH GIỐNG TRONG ẢNH -----
  // (Bạn cần thêm ảnh 'ic_sos.png' vào thư mục 'assets/images/' của project)
  final List<EmergencyContact> _allContacts = [
    EmergencyContact(name: 'Cấp cứu', phone: '115', icon: Icons.sos),
    EmergencyContact(name: 'Cứu hoả', phone: '114', icon: Icons.sos),
    EmergencyContact(name: 'Công an', phone: '113', icon: Icons.sos),
    EmergencyContact(name: 'Phòng thủ dân sự (cứu hộ, cứu nạn)', phone: '112', icon: Icons.sos),
    EmergencyContact(name: 'Bảo vệ trẻ em', phone: '111', icon: Icons.sos),
    EmergencyContact(name: 'Tổng đài 1022 Đã Nẵng', phone: '02361022', icon: Icons.call), // <-- Có thể đổi icon cho khác biệt
  ];

  // Danh sách sẽ hiển thị (dùng cho chức năng tìm kiếm)
  List<EmergencyContact> _filteredContacts = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Khởi tạo, danh sách hiển thị bằng danh sách đầy đủ
    _filteredContacts = _allContacts;
  }

  // ----- HÀM LỌC DANH BẠ KHI TÌM KIẾM -----
  void _filterContacts(String query) {
    // Nếu không gõ gì, hiển thị tất cả
    if (query.isEmpty) {
      setState(() {
        _filteredContacts = _allContacts;
      });
      return;
    }

    // Lọc theo tên hoặc số điện thoại
    final filtered = _allContacts.where((contact) {
      final nameLower = contact.name.toLowerCase();
      final phoneLower = contact.phone.toLowerCase();
      final queryLower = query.toLowerCase();
      return nameLower.contains(queryLower) || phoneLower.contains(queryLower);
    }).toList();

    setState(() {
      _filteredContacts = filtered;
    });
  }

  // ----- HÀM BUILD THANH TÌM KIẾM -----
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: TextField(
        controller: _searchController,
        onChanged: _filterContacts, // Gọi hàm lọc khi gõ
        decoration: InputDecoration(
          hintText: 'Nhập từ khóa tìm kiếm',
          suffixIcon: Icon(Icons.search, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
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

  // ----- HÀM BUILD MỘT CARD LIÊN HỆ -----
  Widget _buildContactCard(EmergencyContact contact) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 2.0, // Đổ bóng nhẹ
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Xử lý sự kiện nhấn để gọi điện
          // Bạn cần thêm package 'url_launcher' để chạy
          // launchUrl(Uri.parse('tel:${contact.phone}'));
          print('Gọi: ${contact.phone}');
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 1. Icon SOS (Bạn phải có ảnh này trong assets)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red, // Nền đỏ
                  borderRadius: BorderRadius.circular(10.0), // Bo góc vuông
                ),
                child: Icon(
                  contact.icon,     // Lấy icon từ model
                  color: Colors.white, // Icon màu trắng
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // 2. Cụm Tên và Số điện thoại
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên liên hệ
                    Text(
                      contact.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5), // Khoảng cách

                    // Số điện thoại
                    Row(
                      children: [
                        Icon(Icons.call, color: Colors.blue[700], size: 16),
                        const SizedBox(width: 6),
                        Text(
                          contact.phone,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----- HÀM BUILD CHÍNH CỦA MÀN HÌNH -----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. AppBar
      appBar: AppBar(
        title: const Text('Danh sách Danh bạ khẩn cấp'),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // 2. Body
      body: Container(
        // Thêm ảnh nền mờ (Tùy chọn)
        // Bạn cần có ảnh này trong assets, ví dụ: 'assets/images/bg_bridge.png'
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/logo.png'),
              fit: BoxFit.cover,
              opacity: 0.1, // Chỉnh độ mờ
            ),
          ),
        child: Column(
          children: [
            // 3. Thanh tìm kiếm
            _buildSearchBar(),

            // 4. Danh sách
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16.0),
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = _filteredContacts[index];
                  return _buildContactCard(contact);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}