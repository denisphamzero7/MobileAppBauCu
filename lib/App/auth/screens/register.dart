
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';


import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // SỬA 3: Bỏ repository và isLoading
  // final _repository = Repository();
  // bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  bool _isPasswordObscure = true;

  // (Controllers giữ nguyên)
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // SỬA 4: Viết lại hoàn toàn hàm _handleRegister
  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Lấy provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      bool success = await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        age: _ageController.text.trim(),
        gender: _genderController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Quay lại trang đăng nhập
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage), // Lấy lỗi từ provider
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // (Các hàm helper _validateNotEmpty, _buildTextField, ... giữ nguyên)
  String? _validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng không để trống';
    }
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      validator: _validateNotEmpty,
      obscureText: _isPasswordObscure,
      decoration: InputDecoration(
        labelText: 'Mật khẩu (Password)',
        prefixIcon: Icon(Icons.lock_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordObscure ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _isPasswordObscure = !_isPasswordObscure;
            });
          },
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Đã có tài khoản? "),
        GestureDetector(
          onTap: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: Text(
            "Đăng nhập ngay",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // SỬA 5: Lấy trạng thái loading từ provider
    final authStatus = Provider.of<AuthProvider>(context).status;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: [
                  SizedBox(height: 30),
                  Icon(
                    Icons.person_add_outlined,
                    size: 80,
                    color: Colors.blue[700],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tạo tài khoản',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Tên (Name)',
                    icon: Icons.person_outline,
                    validator: _validateNotEmpty,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    validator: _validateNotEmpty,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  _buildPasswordField(),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _ageController,
                    label: 'Tuổi (Age)',
                    icon: Icons.cake_outlined,
                    validator: _validateNotEmpty,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _genderController,
                    label: 'Giới tính (Gender)',
                    icon: Icons.wc_outlined,
                    validator: _validateNotEmpty,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Địa chỉ (Address)',
                    icon: Icons.home_outlined,
                    validator: _validateNotEmpty,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Số điện thoại (Phone)',
                    icon: Icons.phone_outlined,
                    validator: _validateNotEmpty,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 32),

                  // SỬA 6: Nút Đăng ký dựa trên provider
                  (authStatus == AuthStatus.Registering)
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700]     ,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Đăng ký', style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(height: 24),
                  _buildLoginLink(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}