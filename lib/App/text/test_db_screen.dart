// lib/screens/voter_management_screen.dart (Hoặc file tương đương)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../network/database_helper.dart';
import '../services/excel/excel_utility_service.dart'; // Cần cho Provider
// SỬA ĐƯỜNG DẪN NẾU CẦN


// --- WIDGET CHÍNH ---

class VoterManagementScreen extends StatefulWidget {
  const VoterManagementScreen({super.key});

  @override
  State<VoterManagementScreen> createState() => _VoterManagementScreenState();
}

class _VoterManagementScreenState extends State<VoterManagementScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  // Khởi tạo Service tiện ích
  late final ExcelUtilityService _excelService;

  List<CitizenInfo> _voters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Khởi tạo Service Excel
    _excelService = ExcelUtilityService();
    _loadVoters();
  }

  // Tải danh sách cử tri từ SQLite
  Future<void> _loadVoters() async {
    setState(() {
      _isLoading = true;
    });
    final voters = await _dbHelper.getCitizens();
    setState(() {
      _voters = voters;
      _isLoading = false;
    });
  }

  // Hàm Xuất Excel (Export)
  Future<void> _exportData() async {
    // Gọi hàm Export trong ExcelUtilityService
    await _excelService.exportCitizens(context);
    // Không cần _loadVoters() vì Export không thay đổi dữ liệu
  }

  // Hàm Nhập Excel (Import)
  Future<void> _importData() async {
    // Gọi hàm Import trong ExcelUtilityService
    await _excelService.importCitizens(context);
    // Tải lại danh sách sau khi nhập xong để cập nhật UI
    _loadVoters();
  }

  // Hàm để thêm 1 cử tri test (Giữ nguyên)
  Future<void> _addTestData() async {
    final String cccd = DateTime.now().millisecondsSinceEpoch.toString().substring(5);

    CitizenInfo testCitizen = CitizenInfo(
        idNumber: cccd,
        fullName: "Cử Tri Test ${cccd}",
        dob: "01/01/2000",
        nationality: "Việt Nam",
        placeOfOrigin: "Test",
        placeOfResidence: "Hà Nội",
        sex: "Nam",
        dateOfExpiry: "01/01/2030",
        personalIdentification: "Không",
        dateOfIssue: "01/01/2020",
        placeOfIssue: "Hà Nội",
        hasVoted: false
    );

    await _dbHelper.insertCitizen(testCitizen);

    _loadVoters();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm cử tri test: ${cccd}')),
    );
  }

  // Hàm XÓA Cử tri (Giữ nguyên)
  Future<void> _deleteVoter(String cccd) async {
    final deletedRows = await _dbHelper.deleteCitizenByCCCD(cccd);

    if (deletedRows > 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa cử tri $cccd thành công.')),
      );
      _loadVoters();
    }
  }

  // Hàm SỬA (Cập nhật trạng thái Đã Bầu) (Giữ nguyên)
  Future<void> _toggleVotedStatus(String cccd, bool currentStatus) async {
    final db = await _dbHelper.database;
    final newStatus = !currentStatus;

    await db.update(
        'citizens',
        {'hasVoted': newStatus ? 1 : 0},
        where: 'idNumber = ?',
        whereArgs: [cccd]
    );

    _loadVoters();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã cập nhật trạng thái bầu cử cho cử tri $cccd.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Danh sách Cử Tri (SQLite)'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          // Nút NHẬP (IMPORT)
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Nhập dữ liệu từ Excel',
            onPressed: _importData,
          ),
          // Nút XUẤT (EXPORT)
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Xuất dữ liệu ra Excel',
            onPressed: _exportData,
          ),
          // Nút Tải lại
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVoters,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _voters.isEmpty
          ? const Center(child: Text('Không có cử tri nào trong danh sách cục bộ.'))
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _voters.length,
        itemBuilder: (context, index) {
          final voter = _voters[index];
          return VoterItem(
            voter: voter,
            onDelete: _deleteVoter,
            onToggleStatus: _toggleVotedStatus,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTestData,
        label: const Text('Thêm Cử Tri Test'),
        icon: const Icon(Icons.person_add_alt_1),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// --- WIDGET CON (Giữ nguyên) ---

class VoterItem extends StatelessWidget {
  final CitizenInfo voter;
  final Function(String cccd) onDelete;
  final Function(String cccd, bool currentStatus) onToggleStatus;

  const VoterItem({
    super.key,
    required this.voter,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: Icon(
          voter.hasVoted ? Icons.check_circle : Icons.timer,
          color: voter.hasVoted ? Colors.green : Colors.orange,
          size: 30,
        ),
        title: Text(
          voter.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('CCCD: ${voter.idNumber}'),
            Text('Ngày sinh: ${voter.dob}'),
            Text('Giới tính: ${voter.sex}'),
            Text('Trạng thái: ${voter.hasVoted ? "ĐÃ ĐI BẦU" : "CHƯA ĐI BẦU"}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nút SỬA (Cập nhật trạng thái bầu cử)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue.shade700),
              tooltip: 'Cập nhật trạng thái bầu cử',
              onPressed: () => onToggleStatus(voter.idNumber, voter.hasVoted),
            ),
            // Nút XÓA
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              tooltip: 'Xóa cử tri khỏi danh sách cục bộ',
              onPressed: () => onDelete(voter.idNumber),
            ),
          ],
        ),
      ),
    );
  }
}