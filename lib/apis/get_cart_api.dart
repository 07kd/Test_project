import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test_project/url/urls.dart';

class GetCartApi {
  static Future<Map<String, dynamic>> GetCartData() async {
    try {
      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final response = await http.get(
        Uri.parse(cartItem),
        headers: headers,
      );
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 400) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        return {"error": "Unauthorized access - session expired."};
      } else {
        throw Exception("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      return {"error": e.toString()};
    }
  }
}
