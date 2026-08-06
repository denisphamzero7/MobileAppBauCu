// lib/App/app_header.dart

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
// SỬA 1: Import Provider và AuthProvider
import 'package:provider/provider.dart';


import 'auth/providers/auth_provider.dart'; // Đảm bảo đường dẫn này đúng

// SỬA 2: Chuyển thành StatelessWidget (không cần State nữa)
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(220); // Giữ nguyên

  // SỬA 3: HÀM XỬ LÝ CLICK ICON USER MỚI (Dùng Provider)
  // (Không cần 'async' nữa)
  void _handleProfileIconTap(BuildContext context) {
    // Lấy provider (listen: false vì ta ở trong 1 hàm callback)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      // ĐÃ ĐĂNG NHẬP: Đi đến trang Profile
      Navigator.of(context).pushNamed('/profile');
    } else {
      // CHƯA ĐĂNG NHẬP: Đi đến trang Login
      Navigator.of(context).pushNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color blueTextColor = Colors.blue.shade800;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 16, 16, 16),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.black12, width: 1))),

      // SỬA 4: GIẢI QUYẾT LỖI CRASH
      // Bọc toàn bộ nội dung bằng Material để cung cấp "bề mặt"
      // cho các IconButton bên trong.
      child: Material(
        color: Colors.transparent, // Dùng màu trắng từ Container bên ngoài
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // (Logo giữ nguyên)
                CircleAvatar(
                  backgroundColor: Colors.blue[50],
                  radius: 22,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(
                      'assets/images/logo.png',
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error, color: Colors.red);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // (Tên App giữ nguyên)
                Text(
                  "Bầu cử Đà Nẵng",
                  style: TextStyle(
                    color: blueTextColor,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),

                // (Icon Thông báo giữ nguyên)
                IconButton(
                  icon: Icon(Icons.notifications_none,
                      color: blueTextColor, size: 28),
                  onPressed: () {
                    // TODO: Thêm hành động cho nút thông báo
                  },
                ),

                // (Icon User giữ nguyên)
                IconButton(
                  icon: Icon(Icons.account_circle_outlined,
                      color: blueTextColor, size: 28),
                  onPressed: () {
                    // SỬA 5: Gọi hàm xử lý mới (truyền context)
                    _handleProfileIconTap(context);
                  },
                ),
              ],
            ),

            // (Phần còn lại của header: Marquee, Vị trí, Thời tiết... giữ nguyên)
            const SizedBox(height: 18),
            SizedBox(
              height: 20,
              child: Marquee(
                text:
                "ng vận động người dân tháo dỡ các tấm đậy, khơi thông hố thu...",
                style: TextStyle(color: blueTextColor.withOpacity(0.9), fontSize: 14),
                velocity: 35.0,
                blankSpace: 20.0,
                pauseAfterRound: const Duration(seconds: 1),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.location_on, color: blueTextColor, size: 18),
                const SizedBox(width: 4),
                Text(
                  "Thành phố Đà Nẵng",
                  style: TextStyle(color: blueTextColor, fontSize: 14),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, color: blueTextColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  "30/10/2025",
                  style: TextStyle(color: blueTextColor, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.cloud_outlined, color: blueTextColor, size: 32),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "26°C",
                      style: TextStyle(
                        color: blueTextColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      "Mây cụm",
                      style: TextStyle(
                          color: blueTextColor.withOpacity(0.9),
                          fontSize: 16,
                          height: 1.1),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}