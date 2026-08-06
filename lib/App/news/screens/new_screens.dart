// new_screen.dart (Đã sửa)
import 'dart:developer';
import 'package:app_02/model/news.dart';
// SỬA 1: Import Provider
import 'package:provider/provider.dart';


import 'package:flutter/material.dart';
import 'package:app_02/network/repository.dart';

import '../providers/news_provider.dart'; // <-- Vẫn cần cho buildImageUrl

// --- SỬA 2: CHUYỂN THÀNH STATELESSWIDGET ---
class NewsListPage extends StatelessWidget {
  NewsListPage({super.key}); // <-- ĐÃ SỬA: Xóa const

  // SỬA 3: Vẫn giữ lại _repository...
  final Repository _repository = Repository();

  // --- SỬA 4: Bỏ tất cả State, initState, và _fetchNews ---
  // ...

  // --- HÀM HELPER: ĐỊNH DẠNG NGÀY THÁNG (Giữ nguyên) ---
  String _formatDate(DateTime dateTime) {
    try {
      return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
    } catch (e) {
      return "Ngày không hợp lệ";
    }
  }

  // --- HÀM HELPER: TẠO ẢNH PLACEHOLDER (Giữ nguyên) ---
  Widget _buildImagePlaceholder() {
    return Container(
      width: 100,
      height: 75,
      color: Colors.grey[200],
      child: Icon(Icons.image, color: Colors.grey[400]),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SỬA 5: Lắng nghe provider
    final provider = context.watch<NewsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin tức & Thông báo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            // SỬA 6: Gọi hàm fetchNews từ provider
            onPressed: provider.isLoading
                ? null
                : () => context.read<NewsProvider>().fetchNews(),
          ),
        ],
      ),
      // SỬA 7: Gọi _buildBody và truyền state từ provider
      body: _buildBody(
        isLoading: provider.isLoading,
        error: provider.error,
        newsList: provider.newsList,
      ),
    );
  }

  // --- SỬA 8: HÀM _buildBody (nhận tham số, không còn là state) ---
  Widget _buildBody({
    required bool isLoading,
    required String? error,
    required List<News> newsList,
  }) {
    // --- 1. TRẠNG THÁI ĐANG TẢI (chỉ khi list rỗng) ---
    if (isLoading && newsList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // --- 2. TRẠNG THÁI LỖI ---
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    // --- 3. TRẠNG THÁI THÀNH CÔNG (NHƯNG KHÔNG CÓ DATA) ---
    if (newsList.isEmpty) {
      return const Center(child: Text("Không có tin tức nào."));
    }

    // --- 4. TRẠNG THÁI THÀNH CÔNG (CÓ DATA) ---
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: newsList.length,
      itemBuilder: (context, index) {
        final news = newsList[index];

        // Dùng _repository (từ class) để build URL
        String imageUrl = _repository.buildImageUrl(
          news.imageUrl,
        );

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: InkWell(
            onTap: () {
              print('Nhấn vào tin: ${news.title}');
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: (imageUrl.isNotEmpty)
                        ? Image.network(
                      imageUrl,
                      width: 100,
                      height: 75,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        log("Lỗi tải ảnh: $imageUrl", error: error);
                        return _buildImagePlaceholder();
                      },
                    )
                        : _buildImagePlaceholder(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          news.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatDate(news.createdAt),
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}