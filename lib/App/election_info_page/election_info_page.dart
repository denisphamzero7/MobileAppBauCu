// election_info_page.dart
import 'package:flutter/material.dart';

import '../news/screens/new_screens.dart';

// Import trang danh sách tin tức để có thể liên kết đến nó


class ElectionInfoPage extends StatelessWidget {
  const ElectionInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Tạo danh sách các mục thông tin
    final List<Map<String, dynamic>> infoItems = [
      {
        'title': 'Hướng dẫn bỏ phiếu',
        'icon': Icons.how_to_vote_outlined,
      },
      {
        'title': 'Danh sách ứng cử viên',
        'icon': Icons.people_outline,
      },
      {
        'title': 'Tra cứu thông tin cử tri',
        'icon': Icons.person_search_outlined,
      },
      {
        'title': 'Tra cứu địa điểm bỏ phiếu',
        'icon': Icons.location_on_outlined,
      },
      {
        'title': 'Quy định & Luật bầu cử',
        'icon': Icons.gavel_outlined,
      },
      {
        'title': 'Tin tức & Thông báo', // Mục này có thể dẫn lại trang tin tức
        'icon': Icons.campaign_outlined,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin Bầu cử'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      // 2. Thay thế Center bằng ListView.separated
      body: ListView.separated(
        itemCount: infoItems.length,
        // 3. Thêm dòng kẻ phân cách giữa các mục
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          indent: 16,  // Thụt lề cho dòng kẻ
          endIndent: 16,
        ),
        // 4. Xây dựng mỗi mục trong danh sách
        itemBuilder: (context, index) {
          final item = infoItems[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            leading: Icon(
              item['icon'] as IconData,
              color: Colors.blue[700], // Sử dụng màu chủ đạo
              size: 28,
            ),
            title: Text(
              item['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              // 5. Xử lý khi nhấn vào từng mục
              if (item['title'] == 'Tin tức & Thông báo') {
                // Nếu là mục Tin tức, mở trang NewsListPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  NewsListPage()),
                );
              } else {
                // Với các mục khác, tạm thời in ra console
                // TODO: Tạo các trang chi tiết tương ứng (ví dụ: CandidateListPage, VoterInfoPage, ...)
                print('Nhấn vào: ${item['title']}');
              }
            },
          );
        },
      ),
    );
  }
}