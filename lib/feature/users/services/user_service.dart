import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../../../core/api/api_links.dart';

class UserService {
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await http.get(Uri.parse(ApiGetUrl.getUsers));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> usersJson = data['users'];
        
        return usersJson.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 