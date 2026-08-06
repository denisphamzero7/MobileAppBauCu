import 'dart:convert';


import 'package:dio/dio.dart';

Dio getDio() {
  Dio dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        printValue(tag: 'API URL: ', s: options.uri);
        printValue(tag: 'HEADER: ', s: options.headers);
        // Kiểm tra data trước khi encode, vì FormData không thể encode sang JSON
        if (options.data is! FormData) {
          printValue(tag: 'REQUEST BODY: ', s: jsonEncode(options.data));
        } else {
          // Với FormData, chúng ta có thể in các trường của nó
          printValue(tag: 'REQUEST BODY (FormData): ', s: (options.data as FormData).fields);
        }
        return handler.next(options);
      },
      onResponse: (Response response, ResponseInterceptorHandler handler) {
        printValue(tag: 'RESPONSE BODY: ', s: jsonEncode(response.data));
        return handler.next(response);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) {
        // --- CẬP NHẬT LOG LỖI Ở ĐÂY ---
        if (error.response != null) {
          // Lỗi có phản hồi từ server (4xx, 5xx)
          printValue(tag: '--- DIO ERROR (CÓ PHẢN HỒI) ---', s: '');
          printValue(tag: 'STATUS CODE: ', s: '${error.response?.statusCode ?? ''}');
          printValue(tag: 'ERROR DATA: ', s: '${error.response?.data ?? ''}');
        } else {
          // Lỗi không có phản hồi (mất mạng, không thể kết nối, timeout)
          printValue(tag: '--- DIO ERROR (KHÔNG PHẢN HỒI) ---', s: '');
          printValue(tag: 'ERROR TYPE: ', s: error.type);
          printValue(tag: 'ERROR MESSAGE: ', s: error.message);
        }
        // --- KẾT THÚC CẬP NHẬT ---

        if (error.response?.statusCode == 401) {
          // navigate here
        } else if (error.response?.statusCode == 400) {
          // toast
        }
        return handler.next(error);
      },
    ),
  );
  return dio;
}

// Giả sử bạn có hàm printValue ở đâu đó, ví dụ:
void printValue({required String tag, required dynamic s}) {
  print('$tag $s');
}
