// Thêm import cho widget search bar mới của bạn

import 'package:flutter/material.dart';

import 'directory_search_bar.dart';

// ----- BƯỚC 1: TẠO MODEL MỚI CHO PHẢN ÁNH -----
// (Không thay đổi)
class FeedbackItem {
  final String title;
  final String timestamp;
  final String category;
  final Color categoryColor; // Màu của nhãn danh mục
  final String status;
  final String? imageUrl; // Ảnh đại diện, có thể null

  FeedbackItem({
    required this.title,
    required this.timestamp,
    required this.category,
    required this.categoryColor,
    required this.status,
    this.imageUrl,
  });
}

// ----- BƯỚC 2: MÀN HÌNH GÓP Ý - PHẢN ÁNH -----

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  // ----- DỮ LIỆU TĨNH GIỐNG TRONG ẢNH -----
  // (Không thay đổi - Giả sử bạn đã thêm ảnh vào assets)
  final List<FeedbackItem> _allFeedbackItems = [
    FeedbackItem(
      title: 'Quán Phượng Đội 1267 Nguyễn Tất Thành mở nhạc gây ồn ào',
      timestamp: '07:41 17/10/2025',
      category: 'An ninh trật tự',
      categoryColor: Colors.red.shade700,
      status: 'Đã xử lý',
      imageUrl: 'assets/images/logo.png', // Ảnh logo 1022
    ),
    FeedbackItem(
      title: 'Biển báo ngang tầm người đi bộ tại 67-69 Trần Quốc Toản',
      timestamp: '13:52 30/09/2025',
      category: 'An toàn giao thông...',
      categoryColor: Colors.blue.shade700,
      status: 'Đã xử lý',
      imageUrl: 'assets/images/logo.png', // Ảnh chụp thực tế
    ),
    // ... (Các dữ liệu khác)
  ];

  List<FeedbackItem> _filteredFeedbackItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredFeedbackItems = _allFeedbackItems;
  }

  // ----- HÀM LỌC PHẢN ÁNH KHI TÌM KIẾM -----
  // (Không thay đổi)
  void _filterFeedback(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredFeedbackItems = _allFeedbackItems;
      });
      return;
    }
    final filtered = _allFeedbackItems.where((item) {
      final titleLower = item.title.toLowerCase();
      final queryLower = query.toLowerCase();
      return titleLower.contains(queryLower);
    }).toList();
    setState(() {
      _filteredFeedbackItems = filtered;
    });
  }

  // ----- HÀM BUILD THANH TÌM KIẾM (ĐÃ BỊ XÓA) -----
  // (Xóa bỏ hoàn toàn hàm _buildSearchBar() cũ ở đây)

  // ----- HÀM BUILD MỘT NHÃN (TAG) -----
  // (Không thay đổi)
  Widget _buildTag(String text, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ----- HÀM BUILD MỘT CARD PHẢN ÁNH -----
  // (Không thay đổi)
  Widget _buildFeedbackCard(FeedbackItem item) {
    // ... (Code của _buildFeedbackCard giữ nguyên)
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0, // Đổ bóng nhẹ
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: () {
          print('Xem chi tiết: ${item.title}');
        },
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      item.imageUrl ?? 'assets/images/logo.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/logo.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.timestamp,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTag(item.category, item.categoryColor),
                  const SizedBox(width: 8),
                  _buildTag(item.status, Colors.green.shade600),
                ],
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
      backgroundColor: Colors.grey[200], // Nền xám nhạt
      // 1. AppBar
      // (Không thay đổi)
      appBar: AppBar(
        title: const Text('Góp ý - Phản ánh'),
        backgroundColor: Colors.blue[700], // Màu xanh cyan
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, size: 26),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 26),
            onPressed: () {Navigator.pushNamed(context, '/create-feedback');},
          ),
        ],
      ),
      // 2. Body
      body: Column(
        children: [
          // 3. Thanh tìm kiếm (ĐÂY LÀ CHỖ THAY ĐỔI)
          // Gọi widget mới và truyền tham số vào
          DirectorySearchBar(
            controller: _searchController,
            onChanged: _filterFeedback,
            hintText: 'Nhập thông tin tìm kiếm', // Hint text cho phù hợp
          ),

          // 4. Danh sách
          // (Không thay đổi)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16.0),
              itemCount: _filteredFeedbackItems.length,
              itemBuilder: (context, index) {
                final item = _filteredFeedbackItems[index];
                return _buildFeedbackCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }
}