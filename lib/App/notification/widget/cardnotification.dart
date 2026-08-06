import 'package:flutter/material.dart';

class CardItemNotification extends StatelessWidget {
  final String title;
  final String content;
  final DateTime? dateTime; // Chấp nhận cả null để tương thích

  const CardItemNotification({
    super.key,
    required this.title,
    required this.dateTime,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDateTime = "Không có ngày";
    if (dateTime != null) {
      String time = "${dateTime!.hour.toString().padLeft(2, '0')}:${dateTime!.minute.toString().padLeft(2, '0')}";
      String date = "${dateTime!.day.toString().padLeft(2, '0')}/${dateTime!.month.toString().padLeft(2, '0')}/${dateTime!.year}";
      formattedDateTime = "$time\n$date";
    }

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.campaign_outlined,
            color: Colors.white,
            size: 30,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Text(
          formattedDateTime,
          textAlign: TextAlign.right,
          style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
              height: 1.4),
        ),
      ),
    );
  }
}