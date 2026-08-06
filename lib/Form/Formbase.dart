import 'package:flutter/material.dart';
//StatefulWidget có the thay đổi
class FormDemo extends StatefulWidget{
  const FormDemo({super.key});

  @override
  State<StatefulWidget> createState() => _FormDemoState();

}

class _FormDemoState extends State<FormDemo> {
  // global key truy cập  form
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: Padding(padding: EdgeInsets.all(16.0),
       // nhập dữ liệu,
       // key: sử dụng đẻ truy cập vào trạng thái của form,
       // validate()
       // save()
       // reset()
       child: Form(
         key: _formKey,
         child: Column(
           children: [
             TextFormField(
               decoration: InputDecoration(
                 hintText: 'Nhập tên',
                 labelText: 'Tên',
               ),
               validator: (value) {
                 if (value == null || value.isEmpty) {
                   return 'Vui lòng nhập tên';
                 }
                 return null;
               },
             ),
             SizedBox(height: 16.0),
             Row(
               children: [
                 ElevatedButton(onPressed: (){}, child: Text('Lưu')),
                 SizedBox(width: 16.0),
                 ElevatedButton(onPressed: (){}, child: Text('Hủy')),
               ],
             )
           ]
         )
       ),
     ),
    );
  }
}
