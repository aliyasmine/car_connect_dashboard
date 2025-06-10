import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car_model.dart';
import '../../../core/api/api_links.dart';

class CarService {
  Future<List<CarModel>> getCars() async {
    try {
      final response = await http.get(Uri.parse(ApiGetUrl.getCars));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> carsJson = data['cars'];
        
        return carsJson.map((json) => CarModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cars');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 