// MainShell.dart
import 'package:app_02/App/AppNew.dart';
import 'package:app_02/App/ListViewPage.dart';
import 'package:app_02/App/agency_directory_screen.dart';
// import 'package:app_02/App/app_header.dart'; // Bạn đã comment dòng này
import 'package:app_02/App/camera/camera_scan_screen2.dart';
import 'package:app_02/App/camera/scanner_new.dart';
import 'package:app_02/App/documents/screens/document_list_page.dart';
import 'package:app_02/App/emergency_contact_screen.dart';
import 'package:app_02/App/feedback_screen.dart';
import 'package:app_02/App/lookup_screen.dart';
import 'package:app_02/App/notification/screens/notification_screen.dart';
import 'package:app_02/App/text/test_db_screen.dart';
import 'package:app_02/App/user/screens/user_screen.dart';
import 'package:app_02/MyTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:marquee/marquee.dart'; // Không thấy dùng?
import 'package:app_02/Form/Formbase.dart';
import '../MyTextField2.dart';
import 'camera/camera_scan_screen.dart';
import 'camera/voter_scan_screen.dart';
import 'discovery_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  // <<< SỬA 1: Khai báo danh sách trang ở đây
  late final List<Widget> _danhSachTrang;

  // <<< SỬA 2: Di chuyển việc khởi tạo danh sách vào initState
  @override
  void initState() {
    super.initState();

    // Khởi tạo danh sách trang ở đây để có thể truy cập `this`
    _danhSachTrang = <Widget>[
      const AppNew(), // Index 0 -> Trang chủ
      const NotificationScreen(notifications: [],), // Index 1 -> Thông báo
      VoteScanScreen( onGoHome: () => _onItemTapped(0),), // Index 2 -> Tiến độ
      const DocumentListPage(), // Index 3 -> Tài liệu
      const UserScreen(), // Index 4 -> Cử tri
      
      // Các trang khác không nằm trên BottomNavigationBar chính
      const VoterManagementScreen(),
      const LookupScreen(),
      const FeedbackScreen(),
      const DiscoveryScreen(),
      const EmergencyContactScreen(),
      const AgencyDirectoryScreen(),
      const MyTextField(),

      MyTextField2(),
      FormDemo(),
      const ListViewPage(),
      const Center(child: Text('Trang Tra cứu')),
      const Center(child: Text('Trang Giới thiệu')),
      const Center(child: Text('Trang Tài khoản')),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          // const AppHeader(), // Bạn đã comment dòng này

          // 2. NỘI DUNG TRANG (thay đổi theo tab)
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              // <<< SỬA 4: Sử dụng biến instance _danhSachTrang
              children: _danhSachTrang,
            ),
          ),
        ],
      ),

      // 3. THANH ĐIỀU HƯỚNG CHUNG (Giữ nguyên)
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Trang chủ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: "Thông báo",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Tiến độ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: "Tài liệu",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: "Cử tri",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey[600],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
      ),
    );
  }
}