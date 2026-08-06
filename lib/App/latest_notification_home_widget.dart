import 'package:app_02/App/notification/screens/notification_screen.dart';
import 'package:app_02/App/notification/widget/cardnotification.dart';
import 'package:app_02/model/notification_model.dart';
import 'package:flutter/material.dart';

class LatestNotificationHomeWidget extends StatelessWidget {
  final NotificationModel latestNotification;
  final List<NotificationModel> allNotifications; // Cần để chuyển qua trang sau

  const LatestNotificationHomeWidget({
    super.key,
    required this.latestNotification,
    required this.allNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- SỬA 1: GỘP TIÊU ĐỀ VÀ NÚT VÀO CHUNG 1 HÀNG ---
          Padding(
            // Căn lề trái cho tiêu đề và lề phải cho nút
            padding: const EdgeInsets.only(left: 12.0, right: 10.0, bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa 2 item
              children: [
                // 1. Tiêu đề "Thông báo mới"
                _buildSectionHeader("Thông báo"),

                // 2. Nút "Xem tất cả" (ĐƯỢC CHUYỂN TỪ DƯỚI LÊN ĐÂY)
                TextButton(
                  onPressed: () {
                    // Hành động điều hướng
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationScreen(
                          notifications: allNotifications,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Xem tất cả',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Hiển thị Card thông báo mới nhất (Giữ nguyên)
          CardItemNotification(
            title: latestNotification.title,
            content: latestNotification.content,
            dateTime: latestNotification.dateTime,
          ),

          // --- SỬA 2: XÓA NÚT "XEM TẤT CẢ" Ở VỊ TRÍ CŨ NÀY ĐI ---
          // (Không cần Align ở đây nữa)
        ],
      ),
    );
  }
  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    // ... (code bên trong giữ nguyên) ...
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              "Xem tất cả",
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );

  }
}