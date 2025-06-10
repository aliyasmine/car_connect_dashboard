import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../storage/shared/shared_pref.dart';

class HttpMethods {
  postMethod(String url, var body) async {
    http.Response response = await http.post(
      Uri.parse(url),
      body: body,
      headers: AppSharedPreferences.getToken().isNotEmpty
          ? {
              "Accept": "application/json",
              "Authorization": "Bearer ${AppSharedPreferences.getToken()}",
            }
          : {},
    );
    return response;
  }

  putMethod(String url, String id) async {
    print('$url/$id/');
    http.Response response = await http.put(
      Uri.parse('$url/$id/'),
      // body: body,

      headers: AppSharedPreferences.getToken().isNotEmpty
          ? {
              "Accept": "application/json",
              "Authorization": "Bearer ${AppSharedPreferences.getToken()}",
            }
          : {},
    );
    print(AppSharedPreferences.getToken());
    return response;
  }

  getMethod(String url, Map<String, dynamic>? params) async {
    if (params != null && params.isNotEmpty) {
      Uri uri = Uri.parse(url).replace(queryParameters: params);
      url = uri.toString();
    }

    http.Response response = await http.get(
      Uri.parse(url),
      headers: AppSharedPreferences.getToken().isNotEmpty
          ? {
              "Accept": "application/json",
              "Authorization": "Bearer ${AppSharedPreferences.getToken()}",
            }
          : {},
    );
    return response;
  }

  postWithMultiFile(
      String url, Map data, List<File> files, List<String> names) async {
    print(data);
    print(files);
    print(names);
    var headers = {
      "Accept": "application/json",
      "Authorization": "Bearer ${AppSharedPreferences.getToken()}"
    };
    var multipartrequest = http.MultipartRequest('POST', Uri.parse(url));
    for (int i = 0; i < files.length; i++) {
      var length = await files[i].length();
      var stream = http.ByteStream(files[i].openRead());
      var multipartfile = http.MultipartFile(names[i], stream, length,
          filename: basename(files[i].path));
      multipartrequest.files.add(multipartfile);
    }
    data.forEach((key, value) {
      multipartrequest.fields[key] = value;
    });

    http.StreamedResponse sresponce = await multipartrequest.send();
    http.Response response = await http.Response.fromStream(sresponce);
    // print(object)

    print(response.statusCode);
    print(response.body);
    // print(jsonDecode(response.body));
    return response;
  }

  static Future<dynamic> getById(String url, String id) async {
    try {
      final response = await http.get(
        Uri.parse('$url/$id/'),
        headers: {
          'Authorization': 'Bearer ${AppSharedPreferences.getToken()}',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }

  static Future<dynamic> getAll(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${AppSharedPreferences.getToken()}',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }

  static Future<dynamic> post(String url, Map<String, dynamic> data,
      {List<File>? files, List<String>? names}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] =
          'Bearer ${AppSharedPreferences.getToken()}';

      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (files != null && names != null) {
        for (var i = 0; i < files.length; i++) {
          var file = files[i];
          var stream = http.ByteStream(file.openRead());
          var length = await file.length();
          var multipartFile = http.MultipartFile(
            names[i],
            stream,
            length,
            filename: file.path.split('/').last,
          );
          request.files.add(multipartFile);
        }
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      return jsonDecode(responseData);
    } catch (e) {
      return null;
    }
  }
}
