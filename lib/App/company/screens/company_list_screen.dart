import 'package:flutter/material.dart';

// 1. Import các file cần thiết
import 'package:app_02/network/repository.dart';
import 'package:app_02/network/base_response.dart';

import '../../../model/company_response.dart';

// import 'company_detail_screen.dart'; // (Sẽ dùng khi bạn tạo trang chi tiết)

// 2. Sửa tên class cho đúng: CompanyListScreen
class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  // 3. Sửa tên State: _CompanyListScreenState
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  // 4. Tạo biến để gọi API
  final Repository _repository = Repository();

  // Đã chuyển URL vào file Repository

  // 5. Tạo các biến trạng thái
  bool _isLoading = true;
  String? _error;
  List<Company> _companies = []; // Danh sách rỗng ban đầu

  @override
  void initState() {
    super.initState();
    // 6. Gọi API ngay khi màn hình được tải
    _fetchCompanies();
  }

  // 7. Hàm gọi API
  // SỬA 3: CẬP NHẬT HÀM NÀY
  Future<void> _fetchCompanies() async {
    setState(() { _isLoading = true; _error = null; });

    try {
      // SỬA 4: Sửa kiểu response
      BaseResponse<List<Company>>? response = await _repository.getCompanies();

      if (mounted) {
        if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
          setState(() {
            // SỬA 5: 'response.data' BÂY GIỜ CHÍNH LÀ DANH SÁCH
            _companies = response.data;
            _isLoading = false;
          });
        } else {
          // LỖI TỪ API: Hiển thị message
          setState(() {
            _error = response?.message ?? "Không thể tải dữ liệu";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // LỖI MẠNG/PARSE: Hiển thị lỗi
      if (mounted) {
        setState(() {
          _error = "Đã xảy ra lỗi: $e";
          _isLoading = false;
        });
      }
    }
  }
  // 8. Hàm build() chính
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công ty'),
        actions: [
          // Nút để tải lại
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchCompanies,
          ),
        ],
      ),
      // 9. Dùng hàm build body để xử lý các trạng thái
      body: _buildBody(),
    );
  }

  // 10. Hàm riêng để build body (cho sạch code)
  Widget _buildBody() {
    if (_isLoading) {
      // Trạng thái Loading
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      // Trạng thái Lỗi
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Lỗi: $_error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (_companies.isEmpty) {
      // Trạng thái Rỗng
      return const Center(child: Text('Không có công ty nào.'));
    }

    // THÀNH CÔNG: Hiển thị ListView
    return ListView.builder(
      itemCount: _companies.length,
      itemBuilder: (context, index) {
        final company = _companies[index];
        // Gọi hàm build item
        return _buildCompanyItem(company);
      },
    );
  }

  // 11. Hàm build một item trong danh sách
  // ----- SỬA 2: CẬP NHẬT HÀM NÀY -----
  Widget _buildCompanyItem(Company company) {
    // Tạo URL đầy đủ cho logo
    // Lưu ý: Kiểm tra xem `company.logo` có rỗng không
    final String? logoUrl = company.logo.isNotEmpty
        ? _repository.buildImageUrl(company.logo)
        : null;

    // ----- BẠN YÊU CẦU LOG Ở ĐÂY -----
    print('Đang build item: ${company.name}');
    print('Đường dẫn logo gốc (từ API): ${company.logo}');
    print('Đường dẫn logo đầy đủ (đã xử lý): $logoUrl');
    print('---------------------------------'); // Thêm dòng phân cách cho dễ đọc
    // ------------------------------------

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        // Logo (có fallback icon)
        leading: CircleAvatar(
          backgroundColor: Colors.blue[50],
          // Dùng logoUrl (nếu nó không null)
          backgroundImage: logoUrl != null ? NetworkImage(logoUrl) : null,
          onBackgroundImageError: (e, s) {}, // Ẩn lỗi nếu ảnh hỏng
          // Chỉ hiển thị icon fallback NẾU logoUrl là null (tức là company.logo rỗng)
          child: logoUrl == null
              ? const Icon(Icons.business, color: Colors.blue) // Đổi icon cho hợp lý hơn
              : null,
        ),
        // Tên công ty
        title: Text(company.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        // Mô tả (giới hạn 2 dòng)
        subtitle: Text(
          company.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Mở trang chi tiết công ty
          print('Mở chi tiết của: ${company.name}');
          // (Tạm thời comment lại vì chưa tạo file)
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => CompanyDetailScreen(companyId: company.id),
          //   ),
          // );
        },
      ),
    );
  }
}