import 'package:flutter/material.dart';
class MyTextField2 extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => _MyTextField2State();
  
}

class _MyTextField2State extends State<MyTextField2>{

  final _textController = TextEditingController();
  String _inputText = '';
  bool _isPassword = false;

 // hàm build là hàm chính, xây dựng giao diện
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     body: Padding(padding: EdgeInsets.symmetric(horizontal: 16.0),
     child: Column(
         children: [
           SizedBox(height: 50),
           TextField(
             controller: _textController,
             decoration: InputDecoration(
               labelText: "nhập thông tin",
               hintText: "nhập thông tin",
               border: OutlineInputBorder(),
               prefixIcon: Icon(Icons.person),
               suffixIcon: IconButton(
                   onPressed: (){
                    print("Xóa thông tin");
                    _textController.clear();
                    },
                   icon: Icon(Icons.clear))
             ),
             // thay đổi dữ liệu
             onChanged: (value){
               setState(() {
                 _inputText = value;
               });
             },

           ),
           SizedBox(height: 20,),
           Text("Thông tin nhập vào: $_inputText"),
         ],
     )),
   );
  }

  



}