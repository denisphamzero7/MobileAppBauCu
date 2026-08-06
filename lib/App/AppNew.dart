

import 'dart:developer';
import 'package:app_02/App/camera/voter_scan_screen.dart';
import 'package:app_02/App/notification/widget/cardnotification.dart';
import 'package:app_02/App/user/provider/user_provider.dart';
import 'package:app_02/App/user/screens/user_screen.dart';
import 'package:app_02/App/user/widget/cardvoter.dart';
import 'package:app_02/model/news.dart';
import 'package:app_02/model/document.dart';
import 'package:app_02/network/repository.dart';

// SỬA 1: IMPORT PROVIDERS
import 'package:provider/provider.dart';


import 'package:app_02/App/company/screens/company_list_screen.dart';
import 'package:app_02/App/documents/screens/document_list_page.dart';
import 'package:app_02/App/election_info_page/election_info_page.dart';
import 'package:app_02/App/news/screens/new_screens.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../model/notification_model.dart';
import 'app_header.dart';
import 'documents/provider/document_provider.dart';
import 'latest_notification_home_widget.dart';
import 'news/providers/news_provider.dart';


class AppNew extends StatelessWidget {
  const AppNew({super.key});

  // SỬA 3: VẪN CẦN REPO (CHỈ ĐỂ DÙNG buildImageUrl)
  // (Đây là một cách làm, cách khác là đưa hàm đó sang Provider)
  Repository get _repository => Repository();



  // SỬA 4: BỎ TẤT CẢ STATE, INITSTATE, VÀ CÁC HÀM FETCH
  // (Vì Provider đã làm hết)

  // (Các hàm helper _formatDate và _buildImagePlaceholder giữ nguyên)
  String _formatDate(DateTime dateTime) {
    try {
      return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
    } catch (e) {
      return "Ngày không hợp lệ";
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 100,
      height: 75,
      color: Colors.grey[200],
      child: Icon(Icons.image, color: Colors.grey[400]),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SỬA 5: LẤY DỮ LIỆU TỪ PROVIDER
    final newsProvider = context.watch<NewsProvider>();
    final docProvider = context.watch<DocumentProvider>();
    final userProvider = context.watch<UserProvider>();

    final List<NotificationModel> allNotifications = [
      NotificationModel(
        title: 'Thông báo mới nhất (Khóa VI)',
        content: 'Thông báo về tình hình bầu cử khóa VI. Đã có kết quả.',
        dateTime: DateTime(2025, 11, 12, 14, 30), // Mới nhất
      ),
      NotificationModel(
        title: 'Thông báo (Khóa I)',
        content: 'Thông báo về tình hình bầu cử khóa I',
        dateTime: DateTime(2025, 11, 11, 9, 00),
      ),
      NotificationModel(
        title: 'Thông báo (Khóa II)',
        content: 'Thông báo về tình hình bầu cử khóa II',
        dateTime: DateTime(2025, 11, 10, 17, 15),
      ),
      NotificationModel(
        title: 'Thông báo (Khóa III)',
        content: 'Thông báo về tình hình bầu cử khóa III',
        dateTime: DateTime(2025, 11, 9, 8, 00),
      ),
      NotificationModel(
        title: 'Thông báo (Khóa V)',
        content: 'Thông báo về tình hình bầu cử khóa V',
        dateTime: DateTime(2025, 11, 8, 12, 45),
      ),
    ];
    // --- KHỞI TẠO GIÁ TRỊ ---
    final List<NotificationModel> sortedList = List.from(allNotifications);
    sortedList.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // 'latest' ở đây là kiểu 'NotificationModel?' (có thể null)
    final NotificationModel? latest = sortedList.isNotEmpty ? sortedList.first : null;

    return ListView(
      padding: EdgeInsets.zero,
      children: [

        const AppHeader(),
        if (latest != null)
          LatestNotificationHomeWidget(
            latestNotification: latest,   // OK!
            allNotifications: sortedList, // OK!
          ),

        _buildElectionGrid(context),
        Container(
          color: Colors.grey[100],
          // SỬA 7: Biểu đồ là StatefulWidget, cần bọc riêng
          child: _ChartSection(),
        ),
        _buildUserSection(context, userProvider),
        Container(
          color: Colors.grey[100],
          child: _buildDocumentSection(context, docProvider), // Truyền provider
        ),
        // _buildFaqSection(),
        const SizedBox(height: 20),
      ],
    );
  }



  // SỬA 8: Thêm (context)
  Widget _buildElectionGrid(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Chức năng Bầu cử"),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.9,
            children: [
              _buildGridItem(
                  Icons.contacts_outlined, "Thông tin\nliên hệ", null),
              _buildGridItem(
                Icons.how_to_vote_outlined,
                "Thông tin\nBầu cử",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ElectionInfoPage()),
                  );
                },
              ),
              _buildGridItem(
                  Icons.trending_up_outlined, "Cập nhật\ntiến độ", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const VoteScanScreen()),
                );
              }),

              _buildGridItem(
                  Icons.ballot_outlined, "Tổng hợp\ntiến độ", null),
            ],
          ),
        ],
      ),
    );
  }

  // (Hàm _buildFaqSection giữ nguyên)
  // Widget _buildFaqSection() {
  //   // ... (code bên trong giữ nguyên) ...
  //   return Container(
  //     color: Colors.white,
  //     padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
  //     child: Column(
  //       children: [
  //         _buildSectionHeader("Hỏi đáp thường gặp", onSeeAll: () {}),
  //         const SizedBox(height: 8),
  //         ExpansionTile(
  //           backgroundColor: Colors.white,
  //           collapsedBackgroundColor: Colors.white,
  //           shape:
  //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //           collapsedShape:
  //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //           leading:
  //           Icon(Icons.question_answer_outlined, color: Colors.blue[700]),
  //           title: Text('Nguyên tắc chung trong bầu cử là gì?',
  //               style: TextStyle(fontWeight: FontWeight.w500)),
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.all(16.0),
  //               child: Text(
  //                   'Việc bầu cử đại biểu Quốc hội và đại biểu Hội đồng nhân dân được tiến hành theo nguyên tắc phổ thông, bình đẳng, trực tiếp và bỏ phiếu kín.'),
  //             )
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         ExpansionTile(
  //           backgroundColor: Colors.white,
  //           collapsedBackgroundColor: Colors.white,
  //           shape:
  //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //           collapsedShape:
  //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //           leading:
  //           Icon(Icons.question_answer_outlined, color: Colors.blue[700]),
  //           title: Text('Quyền bầu cử của công dân là gì?',
  //               style: TextStyle(fontWeight: FontWeight.w500)),
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.all(16.0),
  //               child: Text(
  //                   'Tính đến ngày bầu cử, công dân nước Cộng hòa xã hội chủ nghĩa Việt Nam đủ mười tám tuổi trở lên và có đủ các điều kiện theo quy định của pháp luật đều có quyền bầu cử.'),
  //             )
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // (Hàm _buildGridItem giữ nguyên)
  Widget _buildGridItem(IconData icon, String label, VoidCallback? onTap) {
    // ... (code bên trong giữ nguyên) ...
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
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
            child: Icon(
              icon,
              size: 30,
              color: Colors.blue[700],
            ),
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
      ),
    );
  }

  // (Hàm _buildSectionHeader giữ nguyên)
  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    // ... (code bên trong giữ nguyên) ...
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              "Xem tất cả",
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );

  }
  Widget _buildUserSection(BuildContext context,  UserProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
      child: Column(
        children: [
          // Thêm nút "Xem tất cả"
          _buildSectionHeader("Danh sách cử tri", onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserScreen()),
            );
          }),
          const SizedBox(height: 12),
          _buildHomeUserList(provider),
        ],
      ),
    );
  }
  Widget _buildHomeUserList(UserProvider provider) {
    // 1. TRẠNG THÁI ĐANG TẢI
    if (provider.isloading && provider.users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. TRẠNG THÁI LỖI
    if (provider.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
            child: Text(provider.error!, style: const TextStyle(color: Colors.red))),
      );
    }

    // 3. TRẠNG THÁI THÀNH CÔNG (NHƯNG RỖNG)
    if (provider.users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(child: Text("Không có cử tri nào.")),
      );
    }

    // 4. TRẠNG THÁI THÀNH CÔNG (CÓ DATA)
    // Lấy 2 cử tri đầu tiên (theo yêu cầu "2 item")
    final homeUserList = provider.users.take(2).toList();

    return Column(
      children: homeUserList.map((userItem) {
        // Giả định model 'Voter' của bạn có các trường này
        return CardVoter(
          key: ValueKey(userItem.id), // Rất quan trọng để Flutter nhận diện
          voterId: userItem.id.toString(),
          initialHasVoted:  false,
          name: userItem.name ?? 'Không có tên',
          initialCreatedAt: userItem.createdAt,
        );
      }).toList(),
    );
  }

  // (Hàm _buildNewsItem giữ nguyên)
  Widget _buildNewsItem({
    required String imageUrl,
    required String title,
    required String date,
    bool isNetworkImage = false,
    VoidCallback? onTap,
  }) {

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: isNetworkImage
                  ? Image.network(
                imageUrl,
                width: 100,
                height: 75,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  log("Lỗi tải ảnh tin tức: $imageUrl", error: error);
                  return _buildImagePlaceholder();
                },
              )
                  : Image.asset(
                imageUrl,
                width: 100,
                height: 75,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- SỬA 9: CẬP NHẬT HÀM _buildNewsSection -----
  Widget _buildNewsSection(BuildContext context, NewsProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
      child: Column(
        children: [
          _buildSectionHeader("Trang tin tức và thông báo ", onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewsListPage()),
            );
          }),
          const SizedBox(height: 12),
          // SỬA: Gọi hàm build list mới
          _buildHomeNewsList(provider),
        ],
      ),
    );
  }

  // ----- SỬA 10: CẬP NHẬT HÀM _buildHomeNewsList -----
  Widget _buildHomeNewsList(NewsProvider provider) {
    // 1. TRẠNG THÁI ĐANG TẢI (chỉ khi list rỗng)
    if (provider.isLoading && provider.newsList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. TRẠNG THÁI LỖI
    if (provider.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
            child: Text(provider.error!, style: const TextStyle(color: Colors.red))),
      );
    }

    // 3. TRẠNG THÁI THÀNH CÔNG (NHƯNG RỖNG)
    if (provider.newsList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(child: Text("Không có tin tức nào.")),
      );
    }

    // 4. TRẠNG THÁI THÀNH CÔNG (CÓ DATA)
    // SỬA: Lấy 2 tin tức đầu tiên từ provider
    final homeNewsList = provider.newsList.take(2).toList();

    return Column(
      children: homeNewsList.map((newsItem) {
        String imageUrl = _repository.buildImageUrl(newsItem.imageUrl);
        return _buildNewsItem(
          imageUrl: imageUrl,
          title: newsItem.title,
          date: _formatDate(newsItem.createdAt),
          isNetworkImage: true,
          onTap: () {
            print('Nhấn vào tin: ${newsItem.title}');
          },
        );
      }).toList(),
    );
  }

  // ----- SỬA 11: CẬP NHẬT HÀM _buildDocumentSection -----
  Widget _buildDocumentSection(BuildContext context, DocumentProvider provider) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      child: Column(
        children: [
          _buildSectionHeader("Văn bản mới", onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DocumentListPage()),
            );
          }),
          const SizedBox(height: 8),
          _buildHomeDocumentList(provider),
        ],
      ),
    );
  }

  // ----- SỬA 12: CẬP NHẬT HÀM _buildHomeDocumentList -----
  Widget _buildHomeDocumentList(DocumentProvider provider) {
    // 1. TRẠNG THÁI ĐANG TẢI (chỉ khi list rỗng)
    // (Giả sử DocumentProvider dùng `isLoading`)
    if (provider.isloading && provider.documents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. TRẠNG THÁI LỖI
    if (provider.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
            child: Text(provider.error!, style: const TextStyle(color: Colors.red))),
      );
    }

    // 3. TRẠNG THÁI THÀNH CÔNG (NHƯNG RỖNG)
    if (provider.documents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(child: Text("Không có văn bản nào.")),
      );
    }

    // 4. TRẠNG THÁI THÀNH CÔNG (CÓ DATA)
    // SỬA: Lấy 2 văn bản đầu tiên từ provider
    final homeDocumentList = provider.documents.take(2).toList();

    return Column(
      children: homeDocumentList.map((document) {
        return ListTile(
          leading: Icon(Icons.description_outlined, color: Colors.red[700]),
          title: Text(document.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(document.description, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            print('Nhấn vào văn bản: ${document.title}');
          },
        );
      }).toList(),
    );
  }
}

// ----- SỬA 13: TÁCH BIỂU ĐỒ RA WIDGET RIÊNG -----
// (Vì nó cần quản lý state riêng `_touchedIndex`)
class _ChartSection extends StatefulWidget {
  @override
  _ChartSectionState createState() => _ChartSectionState();
}

class _ChartSectionState extends State<_ChartSection> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    double votedPercent = 70.0;
    double notVotedPercent = 30.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SỬA: Phải gọi hàm helper từ bên ngoài,
          // vì nó không còn trong class _AppNewState
          _buildSectionHeader("Tổng hợp tiến độ Bầu cử"),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections:
                      _buildPieChartSections(votedPercent, notVotedPercent),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _buildChartLegend(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // (Các hàm con của Biểu đồ được copy y hệt)
  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              "Xem tất cả",
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
      double votedPercent, double notVotedPercent) {
    return [
      PieChartSectionData(
        color: Colors.blue[700],
        value: votedPercent,
        title: '${votedPercent.toInt()}%',
        radius: _touchedIndex == 0 ? 60.0 : 50.0,
        titleStyle: TextStyle(
          fontSize: _touchedIndex == 0 ? 16 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2)],
        ),
      ),
      PieChartSectionData(
        color: Colors.grey[300],
        value: notVotedPercent,
        title: '${notVotedPercent.toInt()}%',
        radius: _touchedIndex == 1 ? 60.0 : 50.0,
        titleStyle: TextStyle(
          fontSize: _touchedIndex == 1 ? 16 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    ];
  }

  Widget _buildChartLegend() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem(Colors.blue[700]!, "Đã bỏ phiếu"),
        const SizedBox(height: 8),
        _buildLegendItem(Colors.grey[300]!, "Chưa bỏ phiếu"),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(4),
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}