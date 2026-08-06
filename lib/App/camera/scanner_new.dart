import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomeScanner extends StatefulWidget {
  const HomeScanner({super.key});

  @override
  State<HomeScanner> createState() => _HomeScannerState();
}

class _HomeScannerState extends State<HomeScanner> {
  late ImagePicker imagePicker;
  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }
  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: EdgeInsets.only(top:50, bottom: 15, left: 5,right: 5),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:[
        Card(
          color: Colors.blueAccent,
          child: SizedBox(height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  child:  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.scanner,size: 25, color: Colors.white,),
                      Text('scan',style: TextStyle(color: Colors.white,),)
                    ],
                  ),onTap:(){} ,

                ),
                InkWell(
                  child:  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.document_scanner,size: 25, color: Colors.white,),
                      Text('Recognize',style: TextStyle(color: Colors.white,),)
                    ],
                  ),onTap:(){} ,

                ),
                InkWell(
                  child:  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assessment_sharp,size: 25, color: Colors.white,),
                      Text('Enchance',style: TextStyle(color: Colors.white,),)
                    ],
                  ),onTap:(){} ,

                ),
              ],),),
        ),

        // --- PHẦN ĐÃ SỬA ---
        Expanded(
          child: Card(
            color: Colors.black,
            child: Container(), // Bỏ height đi để Expanded tự lấp đầy
          ),
        ),
        // --- HẾT PHẦN SỬA ---

        Card(
          color: Colors.blueAccent,
          child: Container(height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  child:  Icon(Icons.rotate_left,size: 50, color: Colors.white,),onTap:(){} ,
                ),
                InkWell(
                  child:  Icon(Icons.image_outlined,size: 50, color: Colors.white,),onTap:() async{XFile? xfile = await imagePicker.pickImage(source: ImageSource.gallery);} ,
                ),
                InkWell(
                  child:  Icon(Icons.camera,size: 50, color: Colors.white,),onTap:(){} ,
                ),
              ],),),
        ),
      ],
    ),
  );
}