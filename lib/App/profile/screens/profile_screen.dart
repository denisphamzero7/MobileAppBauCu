// lib/App/auth/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../model/profile.dart'; // Đảm bảo đường dẫn này đúng

import '../../../network/repository.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// ----- SỬA 1: THÊM SingleTickerProviderStateMixin ĐỂ QUẢN LÝ TAB -----
class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {

  final Repository _repository = Repository();
  bool _isLoading = true;
  String _errorMessage = "";
  ProfileData? _profile;

  late TabController _tabController; // Biến quản lý các tab

  // Controller cho Tab "Chỉnh sửa"
  final _editFormKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isSavingProfile = false;

  // Controller cho Tab "Bảo mật"
  final _passwordFormKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSavingPassword = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Khởi tạo 3 tab
    _fetchProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // (Hàm _fetchProfile giữ nguyên)
  Future<void> _fetchProfile() async {
    // Chỉ set _isLoading nếu chưa ở trạng thái loading
    if (!_isLoading) {
      setState(() { _isLoading = true; });
    }

    try {
      final response = await _repository.getProfile();
      if (response != null && mounted) {
        setState(() {
          _profile = response.data;
          // ----- SỬA 2: KHỞI TẠO CONTROLLER SAU KHI CÓ DATA -----
          _nameController = TextEditingController(text: _profile!.name);
          _emailController = TextEditingController(text: _profile!.email);
          _isLoading = false;
        });
      } else if (mounted) {
        // Xử lý trường hợp response là null
        setState(() {
          _errorMessage = "Không thể tải dữ liệu.";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Lỗi kết nối: $e";
          _isLoading = false;
        });
      }
    }
  }

  // (Hàm _handleLogout giữ nguyên)
  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Đăng xuất'),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Đóng Dialog
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(); // Thoát khỏi ProfileScreen quay về Home (giờ là LoginScreen)
              }
            },
          ),
        ],
      ),
    );
  }

  // ----- SỬA 3: LOGIC LƯU PROFILE (ĐÃ SỬA LẠI ĐỂ REFRESH) -----
  Future<void> _handleSaveProfile() async {
    if (_editFormKey.currentState!.validate()) {
      setState(() { _isSavingProfile = true; });
      try {
        final response = await _repository.updateProfile(
          name: _nameController.text,
          email: _emailController.text,
        );
        print("cập nhật: $response");

        if (response != null && mounted) {

          // ----- SỬA LẠI TẠI ĐÂY -----
          // Gọi lại _fetchProfile() để "refresh" data sạch từ API GET
          await _fetchProfile();

          // _fetchProfile() đã set _isLoading = false,
          // chúng ta chỉ cần tắt _isSavingProfile
          setState(() {
            _isSavingProfile = false;
          });
          // ------------------------

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green),
          );
          _tabController.animateTo(0); // Chuyển về tab Thông tin

        } else {
          // Xử lý trường hợp response là null (nếu có thể)
          setState(() { _isSavingProfile = false; });
        }
      } catch (e) {
        if (mounted) {
          setState(() { _isSavingProfile = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // ----- SỬA 4: LOGIC LƯU MẬT KHẨU (Từ ChangePasswordScreen cũ) -----
  Future<void> _handleChangePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới không khớp!'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() { _isSavingPassword = true; });
    try {
      // SỬA: BẮT LỖI TỪ REPOSITORY
      await _repository.changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      // Chỉ chạy khi không có lỗi
      if (mounted) {
        setState(() { _isSavingPassword = false; });
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đổi mật khẩu thành công!'), backgroundColor: Colors.green),
        );
        _tabController.animateTo(0); // Chuyển về tab Thông tin
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isSavingPassword = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          // Hiển thị lỗi từ server (ví dụ: "Mật khẩu cũ không đúng")
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tài khoản của tôi"),
        backgroundColor: Colors.blue[700],
        actions: [
          // Nút Đăng xuất giờ nằm trên AppBar
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Đăng xuất',
          ),
        ],
        // ----- SỬA 5: THÊM TABBAR VÀO APPBAR -----
        bottom: _isLoading
            ? PreferredSize( // Hiển thị thanh loading
          preferredSize: Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            backgroundColor: Colors.blue[800],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Thông tin'),
            Tab(icon: Icon(Icons.edit), text: 'Chỉnh sửa'),
            Tab(icon: Icon(Icons.security), text: 'Bảo mật'),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  // ----- SỬA 6: HÀM BUILD BODY CHÍNH -----
  Widget _buildBody() {
    // Sửa: Luôn hiển thị TabBarView, kể cả khi đang loading
    // Chỉ nội dung bên trong TabBarView bị ảnh hưởng
    return TabBarView(
      controller: _tabController,
      children: [
        // Tab 0
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
            : _profile == null
            ? const Center(child: Text("Không có dữ liệu."))
            : _buildInfoTab(_profile!),

        // Tab 1
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
            : _profile == null
            ? const Center(child: Text("Không có dữ liệu."))
            : _buildEditTab(_profile!),

        // Tab 2
        _buildSecurityTab(),
      ],
    );
  }

  // --- CÁC WIDGET CHO TỪNG TAB ---

  // Tab 0: Chỉ hiển thị thông tin
  Widget _buildInfoTab(ProfileData profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[50],
              child: Icon(Icons.person, size: 50, color: Colors.blue[700]),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              profile.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              profile.email,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Chip(
              label: Text(
                "Vai trò: ${profile.role.name}",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 1: Form chỉnh sửa
  Widget _buildEditTab(ProfileData profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(

        key: _editFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
              validator: (val) => val!.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (val) => val!.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            Text(
              "Vai trò: ${profile.role.name} (Không thể thay đổi)",
              style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 32),
            _isSavingProfile
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _handleSaveProfile,
              child: const Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );
  }

  // Tab 2: Form đổi mật khẩu
  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu cũ'),
              validator: (val) => val!.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
              validator: (val) => val!.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
              validator: (val) => val!.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 32),
            _isSavingPassword
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _handleChangePassword,
              child: const Text('Đổi mật khẩu'),
            ),
          ],
        ),
      ),
    );
  }
}