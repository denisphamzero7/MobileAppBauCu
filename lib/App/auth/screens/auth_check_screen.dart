// auth_check_screen.dart

import 'package:app_02/App/MainShell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ----- SỬA: Không cần SharedPreferences hoặc LoginScreen ở đây nữa -----
// import 'package:shared_preferences/shared_preferences.dart';
// import 'login.dart';

class AuthCheckScreen extends StatefulWidget{
  const AuthCheckScreen({Key? key}) : super(key: key);
  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    // ----- SỬA: Gọi hàm điều hướng đơn giản -----
    _navigateToShell();
  }

  // ----- SỬA: Hàm này giờ chỉ điều hướng đến MainShell -----
  Future<void> _navigateToShell() async {
    // Chúng ta dùng Future.delayed(Duration.zero) để đảm bảo Navigator
    // được gọi một cách an toàn sau khi widget đã build xong frame đầu tiên.
    await Future.delayed(Duration.zero);

    if(!mounted) return;

    // Luôn luôn chuyển hướng đến MainShell
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context)=> const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Màn hình loading này vẫn giữ nguyên, rất tốt cho trải nghiệm người dùng
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),);
  }
}