import 'package:app_02/App/directory_search_bar.dart'; // Đảm bảo đường dẫn này đúng
import 'package:flutter/material.dart';

// ----- BƯỚC 1: TẠO MODEL MỚI (AgencyContact) -----
class AgencyContact {
  final String name;
  final String address;
  final String phone;
  final String website;
  final IconData icon; // Dùng IconData cho đơn giản

  AgencyContact({
    required this.name,
    required this.address,
    required this.phone,
    required this.website,
    required this.icon,
  });
}

// ----- BƯỚC 2: MÀN HÌNH DANH BẠ (Đã đổi tên) -----

class AgencyDirectoryScreen extends StatefulWidget { // Đổi tên class
  const AgencyDirectoryScreen({super.key});

  @override
  State<AgencyDirectoryScreen> createState() => _AgencyDirectoryScreenState();
}

class _AgencyDirectoryScreenState extends State<AgencyDirectoryScreen> {

  // ----- DỮ LIỆU TĨNH MỚI (GIỐNG TRONG ẢNH) -----
  final List<AgencyContact> _allContacts = [
    AgencyContact(
      name: 'Sở Tài chính',
      icon: Icons.contact_phone_outlined, // Icon giống trong ảnh
      address:
      '- Quầy số 14-15-16-17-18-19, Tầng 1, TTHC thành phố Đà Nẵng, 24 Trần Phú, phường Hải Châu\n- Tầng 6-7-8, TTHC thành phố Đà Nẵng, 24 Trần Phú, phường Hải Châu',
      phone: '0236 3881 888 (Số máy lẻ 419)',
      website: 'taichinh.danang.gov.vn',
    ),
    AgencyContact(
      name: 'Sở Nội vụ',
      icon: Icons.contact_phone_outlined,
      address:
      '- Quầy số 11-12, Tầng 1, TTHC thành phố Đà Nẵng, 24 Trần Phú, phường Hải Châu\n- Tầng 9-10, TTHC thành phố Đà Nẵng, 24 Trần Phú, phường Hải Châu',
      phone: '0236 3881 888 (Số máy lẻ 412)',
      website: 'noivu.danang.gov.vn',
    ),
    AgencyContact(
      name: 'Sở Xây dựng',
      icon: Icons.contact_phone_outlined,
      address:
      '- Quầy số 2-3, Tầng 1, TTHC thành phố Đà Nẵng, 24 Trần Phú, phường Hải Châu\n- Tầng 12-13-14 TTHC thành phố Đà Nẵng, 24 Trần Phú',
      phone: '0236 3881 888 (Số máy lẻ 424)',
      website: 'sxd.danang.gov.vn',
    ),
    AgencyContact(
      name: 'Sở Nông nghiệp và Môi trường',
      icon: Icons.contact_phone_outlined,
      address:
      '- Quầy số 20, Tầng 1, TTHC thành phố Đà Nẵng, 24 Trần Phú, phường Hải Châu',
      phone: '0236 3881 888 (Số máy lẻ 425)',
      website: 'nnptnt.danang.gov.vn',
    ),
  ];

  // Danh sách sẽ hiển thị (dùng cho chức năng tìm kiếm)
  List<AgencyContact> _filteredContacts = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Khởi tạo, danh sách hiển thị bằng danh sách đầy đủ
    _filteredContacts = _allContacts;
  }

  // ----- HÀM LỌC DANH BẠ (Cập nhật để tìm kiếm tất cả các trường) -----
  void _filterContacts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredContacts = _allContacts;
      });
      return;
    }

    final queryLower = query.toLowerCase();
    final filtered = _allContacts.where((contact) {
      final nameLower = contact.name.toLowerCase();
      final addressLower = contact.address.toLowerCase();
      final phoneLower = contact.phone.toLowerCase();
      final webLower = contact.website.toLowerCase();

      return nameLower.contains(queryLower) ||
          addressLower.contains(queryLower) ||
          phoneLower.contains(queryLower) ||
          webLower.contains(queryLower);
    }).toList();

    setState(() {
      _filteredContacts = filtered;
    });
  }

  // ----- HÀM BUILD MỘT DÒNG THÔNG TIN (Icon + Text) -----
  // (Đây là widget con để tái sử dụng cho Địa chỉ, SĐT, Web)
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0), // Khoảng cách giữa các dòng
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Căn trên khi text nhiều dòng
        children: [
          Icon(icon, color: Colors.blue[700], size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.4, // Giãn dòng cho dễ đọc
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----- HÀM BUILD MỘT CARD CƠ QUAN (Viết lại hoàn toàn) -----
  Widget _buildContactCard(AgencyContact contact) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Căn icon và text lên trên
          children: [
            // 1. Icon (Kiểu mới)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.teal[50], // Màu xanh xám nhạt
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(
                contact.icon,
                color: Colors.teal[700], // Màu xanh xám đậm
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // 2. Cụm thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên cơ quan
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 18, // Chữ to hơn
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8), // Khoảng cách

                  // 3. Các dòng thông tin (Dùng hàm _buildInfoRow)
                  _buildInfoRow(Icons.location_on, contact.address),
                  _buildInfoRow(Icons.call, contact.phone),
                  _buildInfoRow(Icons.info_outline, contact.website),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- HÀM BUILD CHÍNH CỦA MÀN HÌNH -----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. AppBar (Sửa tiêu đề)
      appBar: AppBar(
        title: const Text('Danh sách Danh bạ cơ quan'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // 2. Body
      body: Container(
        // Giữ ảnh nền
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/logo.png'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: Column(
          children: [
            // 3. Thanh tìm kiếm (Sửa lỗi: truyền đúng controller và hàm)
            DirectorySearchBar(
              controller: _searchController,
              onChanged: _filterContacts,
            ),

            // 4. Danh sách (Cập nhật để dùng hàm _buildContactCard mới)
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