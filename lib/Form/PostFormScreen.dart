// PostFormScreen.dart
import 'package:flutter/material.dart';
import 'package:app_02/network/network_request.dart';
import 'package:app_02/model/post.dart';

class PostFormScreen extends StatefulWidget {
  const PostFormScreen({super.key});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  Post? _editingPost; // Biến để lưu post nếu đang ở chế độ Sửa
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Kiểm tra xem có 'post' được gửi qua arguments không
    final arguments = ModalRoute.of(context)!.settings.arguments;
    if (arguments != null && arguments is Post) {
      _editingPost = arguments;
      // Nếu là chỉnh sửa, điền dữ liệu cũ vào form
      _titleController.text = _editingPost!.title ?? '';
      _bodyController.text = _editingPost!.body ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    // Kiểm tra form có hợp lệ không
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      final title = _titleController.text;
      final body = _bodyController.text;

      try {
        if (_editingPost != null) {
          // --- CHẾ ĐỘ CẬP NHẬT ---
          await NetworkRequest.updatePost(_editingPost!.id!, title, body);
        } else {
          // --- CHẾ ĐỘ THÊM MỚI ---
          await NetworkRequest.createPost(title, body);
        }

        // Nếu lưu thành công, quay về màn hình trước
        // và gửi 'true' để báo hiệu danh sách cần tải lại
        if (mounted) {
          Navigator.pop(context, true);
        }

      } catch (e) {
        // Hiển thị lỗi nếu có
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi lưu: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingPost == null ? 'Thêm mới Bài viết' : 'Chỉnh sửa Bài viết'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Nội dung'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Lưu'),
              )
            ],
          ),
        ),
      ),
    );
  }
}