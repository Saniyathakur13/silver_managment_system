import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost/silver_jewellery_api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Auth
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user_email', email);
        await prefs.setBool('is_logged_in', true);
      }
      return data;
    }
    return {'error': 'Login failed'};
  }

  static Future<Map<String, dynamic>> register(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  // Products
  static Future<List<dynamic>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<Map<String, dynamic>> addProduct(Map<String, dynamic> product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      body: jsonEncode(product),
      headers: await getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteProduct(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: await getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Customers
  static Future<List<dynamic>> getCustomers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/customers'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<Map<String, dynamic>> addCustomer(Map<String, dynamic> customer) async {
    final response = await http.post(
      Uri.parse('$baseUrl/customers'),
      body: jsonEncode(customer),
      headers: await getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> recordPayment(String customerId, double amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/customers/payment/$customerId'),
      body: jsonEncode({'amount': amount}),
      headers: await getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteCustomer(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/customers/$id'),
      headers: await getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Sales
  static Future<Map<String, dynamic>> createSale(Map<String, dynamic> sale) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sales'),
      body: jsonEncode(sale),
      headers: await getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Dashboard
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {};
  }
}