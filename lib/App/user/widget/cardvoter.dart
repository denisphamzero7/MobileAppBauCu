import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần thêm intl vào pubspec.yaml để format giờ

/// A card widget to display voter information.
///
/// This widget takes a [voterId] (used as STT) and [name] from the initial data.
/// It manages its own voting state (hasVoted) internally.
class CardVoter extends StatefulWidget {
  /// Creates a voter card.
  ///
  /// The [voterId] (STT) and [name] parameters are required.
  const CardVoter({
    super.key,
    required this.voterId, // This will be used as STT
   this.name,
    this.initialHasVoted = false, // Thêm: Trạng thái ban đầu
    this.initialCreatedAt, // Thêm: Thời gian ban đầu
  });

  /// ID của cử tri (sử dụng làm STT)
  final String voterId;

  /// Họ tên
  final String? name;

  /// Trạng thái bầu ban đầu
  final bool initialHasVoted;

  /// Thời gian bầu ban đầu (nếu initialHasVoted là true)
  final DateTime? initialCreatedAt;

  @override
  State<CardVoter> createState() => _CardVoterState();
}

class _CardVoterState extends State<CardVoter> {
  /// Trạng thái nội bộ của thẻ
  late bool _hasVoted; // Sửa: Dùng 'late'
  DateTime? _createdAt; // Sửa: Không khởi tạo ở đây

  @override
  void initState() {
    super.initState();
    // Khởi tạo trạng thái từ các tham số của widget
    _hasVoted = widget.initialHasVoted;
    _createdAt = widget.initialCreatedAt;
  }

  /// Hàm xử lý khi nhấn vào thẻ
  void _toggleVoteStatus() {
    setState(() {
      _hasVoted = !_hasVoted;

      if (_hasVoted) {
        // Ghi lại thời gian khi bầu
        _createdAt = DateTime.now();
      } else {
        // Xóa thời gian khi hủy bầu
        _createdAt = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the color scheme from the current theme
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      // Add a slight elevation for a "floating" effect
      elevation: 2.0,
      // Add rounded corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      // Add margin around the card
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      // Use InkWell to make the whole card tappable
      child: InkWell(
        onTap: _toggleVoteStatus,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          // Add internal padding for the content
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Middle section with voter details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Voter Name (Họ tên)
                    Text(
                      widget.name ?? 'Không có tên',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                    const SizedBox(height: 4.0),

                    // STT (Số thứ tự)
                    _buildInfoRow(
                      context: context,
                      icon: Icons.format_list_numbered, // Đổi icon
                      text: 'STT: ${widget.voterId}', // Đổi text
                    ),
                    const SizedBox(height: 4.0),

                    // Show voting time if the user has voted (Thời gian)
                    if (_hasVoted && _createdAt != null)
                      _buildInfoRow(
                        context: context,
                        icon: Icons.access_time_outlined,
                        text:
                        'Thời gian: ${DateFormat('HH:mm').format(_createdAt!)}',
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),

              // Status chip on the right (Đã đi bầu)
              Chip(
                label: Text(
                  _hasVoted ? 'Đã bầu' : 'Chưa bầu',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _hasVoted
                        ? colors.onSecondaryContainer
                        : colors.onErrorContainer,
                  ),
                ),
                backgroundColor:
                _hasVoted ? colors.secondaryContainer : colors.errorContainer,
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                side: BorderSide.none,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper widget to build a small info row with an icon and text.
  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
        ),
        const SizedBox(width: 6.0),
        // Use Flexible to allow text to wrap if it's too long
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodySmall,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}

