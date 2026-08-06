import 'package:flutter/material.dart';

// ----- BƯỚC 1: TẠO MODEL CHO DỮ LIỆU -----
class LookupItem {
  final String title;
  final IconData? icon; // Icon, có thể null (không có)
  final Color iconBgColor; // Màu nền của icon

  LookupItem({
    required this.title,
    this.icon,
    this.iconBgColor = Colors.transparent, // Mặc định là trong suốt
  });
}

// ----- BƯỚC 2: MÀN HÌNH TRA CỨU -----
// Đổi tên class cho phù hợp với màn hình
class LookupScreen extends StatelessWidget {
  const LookupScreen({super.key});

  // ----- DỮ LIỆU TĨNH GIỐNG TRONG ẢNH -----
  static final List<LookupItem> _lookupItems = [
    LookupItem(
      title: 'Văn bản QPPL Đà Nẵng',
      icon: Icons.description_outlined,
      iconBgColor: Colors.blue.shade700,
    ),
    LookupItem(
      title: 'Mã khách hàng dịch vụ vệ sinh môi trường',
      icon: Icons.recycling_outlined,
      iconBgColor: Colors.green.shade700,
    ),
    LookupItem(
      title: 'Nợ phí đậu xe',
      icon: Icons.receipt_long_outlined,
      iconBgColor: Colors.red.shade400,
    ),
    LookupItem(
      title: 'Bãi đỗ xe tại Đà Nẵng',
      icon: Icons.directions_car_filled_outlined,
      iconBgColor: Colors.green.shade400,
    ),
    LookupItem(
      title: 'Thông tin tuyến xe buýt',
      icon: Icons.directions_car_filled_outlined,
      iconBgColor: Colors.green.shade400,
    ),
    LookupItem(
      title: 'Giá đất đô thị',
      icon: Icons.directions_car_filled_outlined,
      iconBgColor: Colors.green.shade400,
    ),
    LookupItem(
      title: 'Thông tin thửa đất tại Đà Nẵng',
      icon: Icons.map_outlined,
      iconBgColor: Colors.orange.shade700,
    ),
    LookupItem(
      title: 'Cơ sở đạt chuẩn an toàn thực phẩm',
      icon: Icons.verified_user_outlined,
      iconBgColor: Colors.teal.shade400,
    ),
    LookupItem(
      title: 'Cơ sở khám chữa bệnh',
      icon: Icons.local_hospital_outlined,
      iconBgColor: Colors.red.shade700,
    ),
    LookupItem(
      title: 'Cơ sở tiêm chủng',
      icon: Icons.vaccines_outlined,
      iconBgColor: Colors.blue.shade400,
    ),
    LookupItem(
      title: 'Trường học các cấp tại Đà Nẵng',
      icon: Icons.school_outlined,
      iconBgColor: Colors.purple.shade400,
    ),
    LookupItem(
      title: 'Trung tâm ngoại ngữ',
      icon: Icons.language_outlined,
      iconBgColor: Colors.indigo.shade400,
    ),
    LookupItem(
      title: 'SĐT vi phạm quảng cáo, rao vặt tại Đà Nẵng',
      icon: Icons.phone_forwarded_outlined,
      iconBgColor: Colors.blueGrey.shade400,
    ),
  ];

  // ----- HÀM BUILD ICON (Phần đầu dòng) -----
  Widget _buildLeadingIcon(LookupItem item) {
    // Nếu không có icon, trả về một Box rỗng
    // để giữ cho các dòng chữ được thẳng hàng
    if (item.icon == null) {
      // Kích thước 40.0 là kích thước tiêu chuẩn của CircleAvatar trong ListTile
      return const SizedBox(width: 40.0, height: 40.0);
    }

    // Nếu có icon, trả về CircleAvatar
    return CircleAvatar(
      radius: 20.0,
      backgroundColor: item.iconBgColor,
      child: Icon(
        item.icon,
        color: Colors.white,
        size: 22.0,
      ),
    );
  }

  // ----- HÀM BUILD CHÍNH CỦA MÀN HÌNH -----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. AppBar giống trong ảnh
      appBar: AppBar(
        title: const Text('Tra cứu thông tin'),
        backgroundColor: Colors.blue[700],// Màu xanh cyan giống ảnh
        foregroundColor: Colors.white,
        centerTitle: true, // Chữ ra giữa
        elevation: 0, // Không có bóng đổ
      ),

      // 2. Body dùng ListView.separated
      body: ListView.separated(
        padding: EdgeInsets.zero, // Xóa khoảng đệm mặc định
        itemCount: _lookupItems.length,

        // Hàm build một dòng
        itemBuilder: (context, index) {
          final item = _lookupItems[index];

          return ListTile(
            tileColor: Colors.white, // Nền trắng cho mỗi dòng
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0, // Thêm chút khoảng đệm dọc
            ),
            // Icon đầu dòng
            leading: _buildLeadingIcon(item),

            // Tiêu đề
            title: Text(
              item.title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),

            // Icon mũi tên cuối dòng
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[600],
            ),

            // Sự kiện khi nhấn
            onTap: () {
              // TODO: Xử lý sự kiện nhấn
              print('Nhấn vào: ${item.title}');
            },
          );
        },

        // Hàm build đường kẻ ngăn cách
        separatorBuilder: (context, index) {
          return Divider(
            height: 1.0,       // Chiều cao của đường kẻ
            thickness: 1.0,    // Độ dày
            color: Colors.grey[200], // Màu xám nhạt
            // indent: 16.0,      // Thụt vào từ bên trái (nếu muốn)
          );
        },
      ),
    );
  }
}