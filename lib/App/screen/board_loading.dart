import 'package:flutter/material.dart';

class BoardLoadingScreen extends StatelessWidget {
  const BoardLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình để đặt vị trí các hình tròn nền
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF272D5A), // Màu nền xanh đậm
      body: Stack(
        children: [
          // Hình tròn lớn ở góc trên bên trái
          Positioned(
            top: -screenSize.width * 0.4, // Đẩy lên trên và sang trái một phần
            left: -screenSize.width * 0.4,
            child: Container(
              width: screenSize.width * 0.8, // Kích thước hình tròn
              height: screenSize.width * 0.8,
              decoration: BoxDecoration(
                color: const Color(0xFF42476A).withOpacity(0.5), // Màu tím nhạt hơn
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Hình tròn lớn ở góc dưới bên phải
          Positioned(
            bottom: -screenSize.width * 0.5, // Đẩy xuống dưới và sang phải một phần
            right: -screenSize.width * 0.5,
            child: Container(
              width: screenSize.width * 0.9,
              height: screenSize.width * 0.9,
              decoration: BoxDecoration(
                color: const Color(0xFF42476A).withOpacity(0.5), // Màu tím nhạt hơn
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Nội dung chính giữa màn hình
          Center(
            child: Card(
              color: const Color(0xFF42476A), // Màu tím của card
              margin: const EdgeInsets.symmetric(horizontal: 24.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0), // Bo tròn góc card
              ),
              elevation: 8.0, // Độ nổi của card
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Giới hạn chiều cao của Column
                  children: [
                    // Logo 1022
                    // Nếu là ảnh, thay bằng Image.asset('assets/images/logo_1022.png')
                    Text(
                      '1022',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        // Nếu logo có màu gradient như hình, bạn có thể dùng ShaderMask
                        foreground: Paint()..shader = LinearGradient(
                          colors: <Color>[Color(0xFF00C6FF), Color(0xFF0072FF)],
                        ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tiêu đề Thành phố Đà Nẵng
                    Text(
                      'Thành phố Đà Nẵng',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Dân số
                    Text(
                      '3.065.628 dân số (người)',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),

                    // Tra cứu phường xã
                    Text(
                      'Tra cứu phường xã sau sắp xếp',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Biểu tượng đang tải
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C6FF)), // Màu của spinner
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 16),

                    // Dòng chữ đang tải
                    Text(
                      'Đang tải dữ liệu bản đồ...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Hiệu lực
                    Text(
                      'Hiệu lực từ ngày 01/07/2025',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),

                    // UBND
                    Text(
                      'UBND TP. Đà Nẵng',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}