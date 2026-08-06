// lib/main.dart

import 'package:app_02/App/MainShell.dart';
import 'package:app_02/App/PostDetailScreen.dart';
import 'package:app_02/App/camera/camera_scan_screen.dart';
import 'package:app_02/App/company/screens/company_list_screen.dart';
import 'package:app_02/App/create_feedback_screen.dart';
import 'package:app_02/App/auth/screens/login.dart';
import 'package:app_02/App/auth/screens/register.dart';
import 'package:app_02/App/profile/screens/profile_screen.dart';
import 'package:app_02/App/screen/board_loading.dart';
import 'package:app_02/App/user/provider/user_provider.dart';
import 'package:app_02/Form/PostFormScreen.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../network/repository.dart';
import 'auth/providers/auth_provider.dart';
import 'documents/provider/document_provider.dart';
import 'news/providers/news_provider.dart';
import 'onesignal/onesignal.dart';



void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await initOneSignal();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => DocumentProvider(),lazy: false),
        ChangeNotifierProvider(create: (context) => NewsProvider(),lazy: false,),
        ChangeNotifierProvider(create: (context) => UserProvider(),lazy: false,),
      ],
      child: const MyApp(),
    ),
  );
  // Enable verbose logging for debugging (remove in production)

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Theo dõi bầu cử',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,

      // SỬA 5: Dùng AuthWrapper làm home
      // Nó sẽ tự quyết định hiển thị LoginScreen hay MainShell
      home: const AuthWrapper(),

      // Giữ nguyên routes của bạn
      routes: {
        '/detail': (context) => const PostDetailScreen(),
        '/form': (context) => const PostFormScreen(),
        '/create-feedback': (context) => const AddFeedbackScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/company': (context) => const CompanyListScreen(),
        '/scanner_cccd': (context) => const CameraScanScreen(),
        '/profile': (context) => const ProfileScreen()
      },
    );
  }
}

// SỬA 6: Thêm AuthWrapper (Bạn có thể copy từ câu trả lời trước)
// SỬA 6: Thêm AuthWrapper
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.status) {
      case AuthStatus.Uninitialized:
      // SỬA ĐỔI QUAN TRỌNG: Hiển thị BoardLoadingScreen khi ứng dụng mới khởi tạo
        return const BoardLoadingScreen(); // <-- Thay thế CircularProgressIndicator

      case AuthStatus.Authenticated:
        return const MainShell();

      case AuthStatus.Unauthenticated:
      case AuthStatus.Authenticating:
      case AuthStatus.Registering:
      default:
        return const LoginScreen();
    }
  }
}