// PostDetailScreen.dart
import 'package:flutter/material.dart';
import '../model/post.dart';
import '../network/network_request.dart';
// Import class NetworkRequest

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<Post> _futurePost;
  int _postId = 0;

  @override
  void initState() {
    super.initState();
    // Đặt _futurePost ở đây sẽ gây lỗi vì 'context' chưa sẵn sàng
    // để gọi ModalRoute. Chúng ta dùng didChangeDependencies.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 1. Lấy postId (int) được gửi từ ListViewPage
    try {
      final postId = ModalRoute.of(context)!.settings.arguments as int;

      // Chỉ gọi API lần đầu tiên
      if (postId != _postId) {
        _postId = postId;
        // 2. Gọi API để lấy chi tiết bài post
        setState(() {
          _futurePost = NetworkRequest.fetchPostDetail(_postId);
        });
      }
    } catch (e) {
      print("LỖI: Không nhận được Post ID arguments. $e");
      // Xử lý lỗi nếu không nhận được ID
      setState(() {
        _futurePost = Future.error('Không tìm thấy ID bài post.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết (ID: $_postId)'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      // 3. Dùng FutureBuilder để xử lý 3 trạng thái: Đang tải, Lỗi, Thành công
      body: FutureBuilder<Post>(
        future: _futurePost,
        builder: (context, snapshot) {

          // ---- TRẠNG THÁI 1: ĐANG TẢI (Loading) ----
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ---- TRẠNG THÁI 2: BỊ LỖI (Error) ----
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi khi tải dữ liệu: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // ---- TRẠNG THÁI 3: THÀNH CÔNG (Success) ----
          if (snapshot.hasData) {
            // Lấy dữ liệu post thành công
            final Post post = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title ?? 'Không có tiêu đề',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    post.body ?? 'Không có nội dung chi tiết.',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }

          // Trạng thái mặc định (không nên xảy ra)
          return const Center(child: Text('Không có dữ liệu.'));
        },
      ),
    );
  }
}