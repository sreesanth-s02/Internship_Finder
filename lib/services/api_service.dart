// lib/services/api_service.dart
import 'dart:convert';
// used only when a local path is passed (native platforms)
import 'package:http/http.dart' as http;

/// ApiService - low-level HTTP helpers plus high-level wrappers
/// The high-level wrappers return Map so UI code can read keys like
/// ['success'], ['message'], ['results'], etc.
class ApiService {
  // Use 127.0.0.1 so Flutter web served in browser can reach the backend
  static const String baseUrl = 'http://127.0.0.1:5000';

  // --- Low-level HTTP helpers ---
  static Future<http.Response> get(String path, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{'Accept': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.get(uri, headers: headers);
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.post(uri, headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> put(String path, Map<String, dynamic> body, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.put(uri, headers: headers, body: jsonEncode(body));
  }

  /// Helper to upload file bytes or a native path as multipart.
  /// - `path` is the API path (eg. '/api/me' or '/api/upload_profile_pic')
  /// - `field` is the form field name expected by backend (default 'profile_pic')
  /// - pass either `bytes` (web) or `filePath` (native); bytes are preferred on web
  static Future<http.Response> uploadFile(
    String path, {
    List<int>? bytes,
    String? filePath,
    required String filename,
    String field = 'profile_pic',
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final req = http.MultipartRequest(bytes != null ? 'POST' : 'PUT', uri);

    // attach auth if present
    if (token != null) req.headers['Authorization'] = 'Bearer $token';

    if (bytes != null) {
      req.files.add(http.MultipartFile.fromBytes(field, bytes, filename: filename));
    } else if (filePath != null) {
      // on native platforms we can read from path and attach
      req.files.add(await http.MultipartFile.fromPath(field, filePath));
    } else {
      throw ArgumentError('Either bytes or filePath must be provided');
    }

    final streamed = await req.send();
    return http.Response.fromStream(streamed);
  }

  // Backwards-compatible wrapper if you prefer building MultipartRequest yourself
  static Future<http.Response> uploadMultipart(String path, http.MultipartRequest req) async {
    final streamed = await req.send();
    return http.Response.fromStream(streamed);
  }

  // --- High-level wrappers used by UI pages ---
  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final paths = ['/api/auth/login', '/login', '/auth/login', '/api/login'];
    for (final p in paths) {
      try {
        final res = await post(p, {'email': email, 'password': password});
        final parsed = _safeDecode(res);
        if (parsed.isNotEmpty) return parsed;
      } catch (_) {
        // try next path
      }
    }
    return {'success': false, 'message': 'Network error (login)'};
  }

  static Future<Map<String, dynamic>> registerUser(String username, String email, String phone, String password) async {
    final paths = ['/register', '/api/register', '/api/auth/register', '/auth/register'];
    final body = {
      'username': username,
      'email': email,
      'phone': phone,
      'password': password,
    };

    for (final p in paths) {
      try {
        final res = await post(p, body);
        final parsed = _safeDecode(res);
        if (parsed.isNotEmpty) return parsed;
      } catch (_) {
        // try next path
      }
    }
    return {'success': false, 'message': 'Network error (register)'};
  }

  static Future<Map<String, dynamic>> searchInternships(Map<String, dynamic> payload) async {
    try {
      final res = await post('/internships/search', payload);
      return _safeDecode(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e', 'results': [], 'count': 0};
    }
  }

  static Future<Map<String, dynamic>> applyForInternship(Map<String, dynamic> payload, {String? token}) async {
    try {
      final res = await post('/apply', payload, token: token);
      return _safeDecode(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> fetchMe({String? token}) async {
    try {
      final res = await get('/api/me', token: token);
      return _safeDecode(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateMe(Map<String, dynamic> body, {String? token}) async {
    try {
      final res = await put('/api/me', body, token: token);
      return _safeDecode(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // --- Helper ---
  static Map<String, dynamic> _safeDecode(http.Response res) {
    final int code = res.statusCode;
    final bool ok = code >= 200 && code < 300;
    try {
      final body = (res.body).trim();
      if (body.isEmpty) {
        return {'success': ok, 'message': 'Empty response', 'statusCode': code};
      }
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        // normalize: if backend doesn't use 'success', try to set it based on HTTP status
        final Map<String, dynamic> m = Map<String, dynamic>.from(decoded);
        if (!m.containsKey('success')) m['success'] = ok;
        if (!m.containsKey('statusCode')) m['statusCode'] = code;
        return m;
      }
      // If backend returned a list or other, wrap it
      return {'success': ok, 'results': decoded, 'statusCode': code};
    } catch (e) {
      // fallback: return raw body as message
      return {'success': code >= 200 && code < 300, 'message': 'Invalid JSON: ${res.body}', 'statusCode': code};
    }
  }
}
