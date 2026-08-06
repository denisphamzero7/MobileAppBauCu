// ListViewPage.dart
import 'package:app_02/network/network_request.dart';
import 'package:flutter/material.dart';
import '../model/post.dart';

class ListViewPage extends StatefulWidget {
  // SỬA: Thêm key để MainShell có thể refresh
  const ListViewPage({super.key});
  @override
  State<ListViewPage> createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  List<Post> postData = List.empty();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Gọi hàm tải dữ liệu
  }

  // SỬA: Tách logic tải dữ liệu ra hàm riêng
  Future<void> _fetchData() async {
    setState(() { _isLoading = true; });
    try {
      final data = await NetworkRequest.fetchPost();
      if (mounted) {
        setState(() {
          postData = data;
          _isLoading = false;
        });
      }
    } catch (error) {
      print("===== ĐÃ XẢY RA LỖI =====");
      print(error.toString());
      print("===========================");
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  // Hàm xử lý khi bấm Sửa
  Future<void> _editPost(Post post) async {
    // 1. Điều hướng đến trang Form, gửi kèm 'post'
    // 2. Chờ kết quả trả về (là 'true' nếu lưu thành công)
    final result = await Navigator.pushNamed(
      context,
      '/form',
      arguments: post,
    );

    // 3. Nếu kết quả là 'true', tải lại danh sách
    if (result == true) {
      _fetchData();
    }
  }

  // Hàm xử lý khi bấm Xóa
  Future<void> _deletePost(int postId) async {
    // Hiển thị dialog xác nhận
    final bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bài viết này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Hủy
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Đồng ý
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    // Nếu người dùng xác nhận
    if (confirmed == true) {
      try {
        await NetworkRequest.deletePost(postId);
        _fetchData(); // Tải lại danh sách
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa: $e')),
          );
        }
      }
    }
  }

  /// Hàm này build danh sách post
  Widget _buildList() {
    if (_isLoading && postData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: postData.length,
      itemBuilder: (context, index) {
        final Post post = postData[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: InkWell(
            onTap: () {
              // (Giữ nguyên) Chuyển đến trang chi tiết
              Navigator.pushNamed(context, '/detail', arguments: post.id);
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title ?? 'Không có tiêu đề',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    post.body ?? 'Không có nội dung',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // SỬA: Thêm hàng chứa nút Sửa/Xóa
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue[700]),
                        onPressed: () => _editPost(post),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[700]),
                        onPressed: () => _deletePost(post.id!),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildList();
  }
}