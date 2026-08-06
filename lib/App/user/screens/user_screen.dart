import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart'; // Đảm bảo đường dẫn này chính xác
import '../widget/cardvoter.dart'; // Đảm bảo đường dẫn này chính xác

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách cử tri'),
        backgroundColor: Colors.blue[700], // <-- SỬA: Đổi thành màu xanh
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,// <-- SỬA: Đổi màu chữ thành trắng
      ),
      backgroundColor: Colors.grey[100],
      // Sử dụng Consumer để lắng nghe thay đổi từ UserProvider
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // 1. Trạng thái Đang tải (Loading)
          if (userProvider.isloading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 2. Trạng thái Lỗi (Error)
          if (userProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Lỗi: ${userProvider.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            );
          }

          // 3. Trạng thái Không có dữ liệu (Empty)
          if (userProvider.users.isEmpty) {
            return const Center(
              child: Text('Không tìm thấy cử tri nào.'),
            );
          }

          // 4. Trạng thái Thành công (Success)
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8.0),
            // Xây dựng danh sách dựa trên số lượng user từ provider
            itemCount: userProvider.users.length,
            itemBuilder: (context, index) {
              // Lấy voter từ provider
              final voter = userProvider.users[index];

              // STT sẽ là index + 1
              final stt = (index + 1).toString();

              // Dựa trên provider, 'hasVoted' và 'createdAt' sẽ là giá trị mặc định
              // (false, null) vì provider không cung cấp thông tin này.

              return CardVoter(
                voterId: stt, // STT
                name: voter.name ?? 'Không có tên', // Họ tên
                // Trạng thái 'đã bầu' và 'thời gian' sẽ do CardVoter tự quản lý
                // và mặc định là 'chưa bầu' (initialHasVoted: false)
                initialHasVoted: false,
                initialCreatedAt: null,
              );
            },
          );
        },
      ),
    );
  }
}