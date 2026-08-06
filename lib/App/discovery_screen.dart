// DiscoveryScreen.dart
import 'package:flutter/material.dart';
import '../model/post.dart';
import '../network/network_request.dart';
// Import class NetworkRequest

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {




  @override
  void initState() {
    super.initState();

  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }


  Widget _buildGridItem(IconData icon, String label) {
    // (Giữ nguyên 100% code hàm _buildGridItem của bạn)
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          height: 62,
          width: 62,
          decoration: BoxDecoration(
            color: Colors.lightBlue[50],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.blue.shade100,
              width: 1,
            ),
          ),
          child: Icon(icon, size: 30, color: Colors.blue[700],),
        ),
        const SizedBox(height: 6),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }


  Widget _buildSectionContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity, // Mở rộng hết mức có thể
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: child,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Khám phá'),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle("Thông tin danh bạ"),
            _buildSectionContainer(
              // SỬA: Thay Column bằng GridView.count
              GridView.count(
                crossAxisCount: 4, // Số cột bạn muốn (giống trong ảnh)
                shrinkWrap: true,   // BẮT BUỘC: Để vừa với nội dung
                physics: const NeverScrollableScrollPhysics(), // BẮT BUỘC: Tắt cuộn

                // Căn chỉnh khoảng cách
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,

                children: [
                  // Thêm các icon của bạn vào đây
                  _buildGridItem(Icons.sos, "Danh bạ khẩn cấp"),
                  _buildGridItem(Icons.contact_phone, "Danh bạ cơ quan"),
                  _buildGridItem(Icons.hotel, "Khách sạn"),
                  _buildGridItem(Icons.atm, "Trạm ATM"),
                  _buildGridItem(Icons.local_gas_station, "Cây xăng"),
                  // Thêm các mục khác nếu cần...
                ],
              ),
            ),
            SizedBox(height: 10,),
            _buildSectionTitle("Dịch vụ số"),
            _buildSectionContainer(
              // SỬA: Thay Column bằng GridView.count
              GridView.count(
                crossAxisCount: 4, // Số cột bạn muốn (giống trong ảnh)
                shrinkWrap: true,   // BẮT BUỘC: Để vừa với nội dung
                physics: const NeverScrollableScrollPhysics(), // BẮT BUỘC: Tắt cuộn

                // Căn chỉnh khoảng cách
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,

                children: [
                  // Thêm các icon của bạn vào đây
                  _buildGridItem(Icons.add_box, "Ahamove"),
                  _buildGridItem(Icons.contact_phone, "Momo"),
                  _buildGridItem(Icons.hotel, "VNPT SmartCA"),
                  _buildGridItem(Icons.atm, "Xây dựng chăm sóc nhà"),
                  _buildGridItem(Icons.local_gas_station, "Zalo Pay"),
                  _buildGridItem(Icons.sos, "VNPay"),
                  _buildGridItem(Icons.contact_phone, "Viettel Pay"),
                  _buildGridItem(Icons.hotel, "VietinBank IPay"),

                ],
              ),
            ),
          ],
      )

    );
  }
}