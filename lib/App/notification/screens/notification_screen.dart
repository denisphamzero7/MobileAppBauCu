import 'package:app_02/App/notification/widget/cardnotification.dart';
import 'package:app_02/model/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key, required List<NotificationModel> notifications});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) =>Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blue[700],
      foregroundColor: Colors.white,
      title: const Text('Thông báo'),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ),
    body: ListView(
      children: [
        CardItemNotification(title: 'thông Báo mới nhất',content: 'Thông báo về  tình hình bầu cử khóa VI',dateTime:null,),
        CardItemNotification(title: 'thông Báo mới nhất',content: 'Thông báo về  tình hình bầu cử khóa I',dateTime:null,),
        CardItemNotification(title: 'thông Báo mới nhất',content: 'Thông báo về  tình hình bầu cử khóa II',dateTime:null,),
        CardItemNotification(title: 'thông Báo mới nhất',content: 'Thông báo về  tình hình bầu cử khóa III',dateTime:null,),
        CardItemNotification(title: 'thông Báo mới nhất',content: 'Thông báo về  tình hình bầu cử khóa V',dateTime:null,),
      ],
    ),
  );
}
