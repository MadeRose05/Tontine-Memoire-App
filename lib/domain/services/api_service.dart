import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://tontine.212.56.40.133.sslip.io';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  static Future<Map<String, String>> _getHeaders() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // Récupérer le token depuis le secure storage
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      print('Error reading token for headers: $e');
    }

    return headers;
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Méthode pour gérer les réponses HTTP
  static Map<String, dynamic> _handleResponse(http.Response response) {
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      } else {
        return {'message': 'Success'};
      }
    } else {
      // Gérer les erreurs spécifiques
      String errorMessage = 'HTTP Error ${response.statusCode}';

      try {
        final errorResponse = json.decode(response.body);
        if (errorResponse['message'] != null) {
          errorMessage = errorResponse['message'];
        }
      } catch (e) {
        // Si on ne peut pas décoder la réponse d'erreur, on garde le message par défaut
        print('Error parsing error response: $e');
      }

      throw Exception('$errorMessage (${response.statusCode})');
    }
  }

  // Méthode pour vérifier si le token est valide
  static Future<bool> isTokenValid() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null || token.isEmpty) {
        return false;
      }

      // Optionnel: Faire un appel API pour vérifier la validité du token
      // Par exemple, appeler un endpoint de vérification
      // final response = await get('/auth/verify');
      // return response['valid'] == true;

      return true;
    } catch (e) {
      print('Error checking token validity: $e');
      return false;
    }
  }

  // Méthode pour nettoyer le token en cas d'expiration
  static Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      print('Token cleared from ApiService');
    } catch (e) {
      print('Error clearing token: $e');
    }
  }

  // Méthode pour les requêtes avec gestion automatique du token expiré
  static Future<Map<String, dynamic>> authenticatedRequest(
      String method,
      String endpoint, {
        Map<String, dynamic>? data,
      }) async {
    try {
      Map<String, dynamic> response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await get(endpoint);
          break;
        case 'POST':
          response = await post(endpoint, data ?? {});
          break;
        case 'PUT':
          response = await put(endpoint, data ?? {});
          break;
        case 'PATCH':
          response = await patch(endpoint, data ?? {});
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return response;
    } catch (e) {
      // Si l'erreur indique un token expiré, on peut essayer de le rafraîchir
      if (e.toString().contains('401') || e.toString().contains('403')) {
        print('Token might be expired, clearing it');
        await clearToken();
        throw Exception('Token expired. Please login again.');
      }

      rethrow;
    }
  }
}