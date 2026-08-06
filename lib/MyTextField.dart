import 'package:flutter/material.dart';
class MyTextField extends StatelessWidget{
  const MyTextField({super.key}); // constructor trùng với class
  // ctrl +  space : ra được override
  @override
  Widget build(BuildContext context) {
    // trả về scaffold - widget cung cấp bố cục material design cơ bản
    // màn hình
    return Scaffold(
      // tiêu đề của ứng dụng
      // appBar: AppBar(
      //   // tiêu đề
      //   title: Text("app của tôi"),
      //   //màu nền
      //   backgroundColor: Colors.blue,
      //   // do nặng/ độ bóng appbar
      //   elevation: 4,
      //   actions: [
      //     IconButton(onPressed: (){print("b2");},
      //         icon: Icon(Icons.search)),
      //     IconButton(onPressed: (){print("b3");},
      //         icon: Icon(Icons.abc)),
      //     IconButton(onPressed: (){print("b4");},
      //         icon: Icon(Icons.more_vert))
      //   ],
      //
      // ),

      body: Padding(padding: EdgeInsets.symmetric(horizontal: 16.0),
        // có thể cuộn dùng column không cuộn được
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50,),
              TextField(
                decoration: InputDecoration(
                  labelText: "Họ và tên",
                  hintText: " Nhập họ và tên",
                  border: OutlineInputBorder()
                ),
              ),
              SizedBox(height: 50,),
              TextField(
                decoration: InputDecoration(
                    labelText: "Email",
                    hintText: " Nhập email cá nhân",
                    prefixIcon: Icon(Icons.email),
                    suffixIcon: Icon(Icons.clear),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)
                    ),
                  // tô màu nền
                  filled: true,
                  fillColor: Colors.blue
                ),
              ),
              SizedBox(height: 50,),
              TextField(
                decoration: InputDecoration(
                    labelText: "Số điện thoại",
                    hintText: " Nhập số điện thoại",
                    prefixIcon: Icon(Icons.phone),
                    suffixIcon: Icon(Icons.clear),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    // tô màu nền
                    filled: true,
                    fillColor: Colors.blue,
                ),
                // định dạng bàn phím quyết định
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 50,),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          labelText: "Ngày sinh",
                          hintText: " Nhập vào ngày sinh của bạn",
                          border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                          ),
                      ),
                        keyboardType: TextInputType.datetime,
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                  Expanded(
                    child: TextField(
                        decoration: InputDecoration(
                          labelText: "Giới tính",
                          hintText: " Nhập giới tính",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)
                          ),
                          // tô màu nền
                          filled: true,
                          fillColor: Colors.blue,
                        )
                    ),

                  ),
                ],
              ),
              SizedBox(height: 50,),
              TextField(
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  hintText: " Nhập số mật khẩu",
                  prefixIcon: Icon(Icons.password),
                  suffixIcon: Icon(Icons.clear),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)
                  ),
                  // tô màu nền
                  filled: true,
                  fillColor: Colors.blue,
                ),
                // định dạng bàn phím quyết định
                keyboardType: TextInputType.phone,
                // ẩn mật khẩu
                obscureText: true,
                obscuringCharacter: "*",
              ),
              SizedBox(height: 50,),
              TextField(
                onChanged: (value){
                  print("Cau hoi $value");
                },
                decoration: InputDecoration(
                  labelText: "Câu hỏi bí mật",

                  prefixIcon: Icon(Icons.phone),
                  suffixIcon: Icon(Icons.clear),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)
                  ),
                  // tô màu nền
                  filled: true,
                  fillColor: Colors.blue,
                ),
                // định dạng bàn phím quyết định
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: (){},
      //   child: const Icon(Icons.add_ic_call),),
      // // thanh điều hướng ở dưới
      // bottomNavigationBar:BottomNavigationBar (items:[
      //   BottomNavigationBarItem(icon: Icon(Icons.home),label:"trang chủ"),
      //   BottomNavigationBarItem(icon: Icon(Icons.search),label:"Tìm kiếm"),
      //   BottomNavigationBarItem(icon: Icon(Icons.person),label:"Cá nhân"),
      // ]),
    );
  }
}
