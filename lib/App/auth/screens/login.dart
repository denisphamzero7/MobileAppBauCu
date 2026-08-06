// lib/App/login.dart

import 'package:app_02/App/auth/screens/register.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';


import '../providers/auth_provider.dart';




class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // SỬA 4: Bỏ repository và isLoading
  // final _repository = Repository();
  // bool _isLoading = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'phuong123@gmail.com';
    _passwordController.text = '123456';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // SỬA 5: Viết lại hoàn toàn hàm _handleLogin
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Lấy AuthProvider (listen: false vì ở trong 1 hàm)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      bool success = await authProvider.login(email, password);

      if (!mounted) return;

      if (success) {
        // Đăng nhập thành công!
        // AuthWrapper sẽ tự động chuyển màn hình
        // Không cần Navigator.pushReplacement ở đây
      } else {
        // Đăng nhập thất bại, provider đã set lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage), // Lấy lỗi từ provider
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Lỗi (hiếm khi xảy ra vì provider đã catch)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _goToRegister() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const RegisterScreen())
    );
  }

  // SỬA 6: Cập nhật lại giao diện (BUILD)
  @override
  Widget build(BuildContext context) {
    // SỬA 7: Lấy trạng thái loading từ provider
    final authStatus = Provider.of<AuthProvider>(context).status;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 80,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Đăng nhập',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // TextField Email
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Username (Email)',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  // TextField Password
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureText,
                  ),
                  const SizedBox(height: 32),

                  // SỬA 8: Nút Đăng nhập dựa trên provider
                  (authStatus == AuthStatus.Authenticating)
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nút Đăng ký
                  TextButton(
                    onPressed: _goToRegister,
                    child: Text(
                      'Chưa có tài khoản? Đăng ký ngay',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}