// document_list_page.dart
// SỬA 1: Bỏ import repository (không cần nữa)
// SỬA 2: Import provider
import 'package:provider/provider.dart';

import 'package:app_02/model/document.dart'; // Vẫn cần model
import 'package:flutter/material.dart';

import '../provider/document_provider.dart';

// --- SỬA 3: CHUYỂN THÀNH STATELESSWIDGET ---
class DocumentListPage extends StatelessWidget {
  const DocumentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SỬA 4: Lắng nghe provider
    // Dùng context.watch<...> để widget tự build lại khi data thay đổi
    final provider = context.watch<DocumentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Văn bản mới'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      // SỬA 6: Gọi _buildBody và truyền state từ provider vào
      body: _buildBody(
        isLoading: provider.isloading,
        error: provider.error,
        documents: provider.documents,
      ),
    );
  }

  // --- SỬA 7: HÀM _buildBody (giữ nguyên logic, chỉ nhận tham số) ---
  Widget _buildBody({
    required bool isLoading,
    required String? error,
    required List<Document> documents,
  }) {
    // --- 1. TRẠNG THÁI ĐANG TẢI ---
    // (Chỉ loading lần đầu, khi list rỗng)
    if (isLoading && documents.isEmpty) {
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
    if (documents.isEmpty) {
      return const Center(child: Text("Không có văn bản nào."));
    }

    // --- 4. TRẠNG THÁI THÀNH CÔNG (CÓ DATA) ---
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];

        return ListTile(
          leading: Icon(Icons.description_outlined, color: Colors.red[700]),
          title: Text(document.title),
          subtitle: Text(document.description),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            print('Nhấn vào văn bản: ${document.title}');
            // TODO: Xử lý khi nhấn vào một văn bản cụ thể
          },
        );
      },
    );
  }
}