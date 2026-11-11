import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 10.0.2.2 = machine hôte vue depuis l'émulateur Android.
/// Autre cas : flutter run --dart-define=API_URL=http://IP_DU_PC:3000/api
const baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:3000/api');

class ApiError implements Exception {
  final String message;
  ApiError(this.message);
  @override
  String toString() => message;
}

class Api {
  static String? token;

  static Future<dynamic> call(String method, String path, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('$baseUrl$path');
    final h = {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
    final b = body == null ? null : jsonEncode(body);
    try {
      final http.Response r = switch (method) {
        'POST' => await http.post(uri, headers: h, body: b),
        'PUT' => await http.put(uri, headers: h, body: b),
        'PATCH' => await http.patch(uri, headers: h, body: b),
        _ => await http.get(uri, headers: h),
      }.timeout(const Duration(seconds: 15));
      final data = r.body.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
      if (r.statusCode >= 400) throw ApiError((data is Map ? data['error'] : null) ?? 'Erreur ${r.statusCode}');
      return data;
    } on ApiError {
      rethrow;
    } catch (_) {
      throw ApiError('Serveur injoignable. Vérifiez la connexion.');
    }
  }

  static Future<void> saveToken(String? t) async {
    token = t;
    final p = await SharedPreferences.getInstance();
    if (t == null) {
      await p.remove('token');
    } else {
      await p.setString('token', t);
    }
  }

  static Future<void> loadToken() async {
    token = (await SharedPreferences.getInstance()).getString('token');
  }
}
