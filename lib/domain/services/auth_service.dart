import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _msisdnKey = 'msisdn';
  static const String _userNameKey = 'user_name';

  static Future<Map<String, dynamic>> getUser(String msisdn) async {
    print('Getting user for: $msisdn');
    try {
      final response = await ApiService.get('/users/$msisdn');
      print('User retrieved: $response');
      return response;
    } catch (e) {
      print('Failed to get user: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('HandshakeException') ||
          e.toString().contains('NetworkException')) {
        throw Exception('Problème de connexion réseau. Vérifiez votre connexion internet.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Délai d\'attente dépassé. Réessayez plus tard.');
      } else if (e.toString().contains('404')) {
        throw Exception('Numéro non trouvé. Vérifiez votre numéro de téléphone.');
      } else if (e.toString().contains('500')) {
        throw Exception('Erreur serveur. Réessayez plus tard.');
      }
      throw Exception('Erreur lors de la récupération des données utilisateur.');
    }
  }

  static Future<Map<String, dynamic>> login(String phoneNumber, String pin) async {
    print('Logging in with phone: $phoneNumber and pin: $pin');
    try {
      final response = await ApiService.post('/users/login', {
        'msisdn': phoneNumber,
        'pin': pin,
      });
      print('Login successful: $response');

      // Extraire les données de la réponse
      if (response['data'] != null) {
        final data = response['data'];
        final token = data['token'];
        final user = data['user'];

        // Stocker les informations utilisateur de manière sécurisée
        await storeUserData(
          token: token,
          userId: user['id'],
          msisdn: user['msisdn'],
          userName: user['name'],
        );

        print('User data stored securely');
      }

      return response;
    } catch (e) {
      print('Failed to login: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('HandshakeException') ||
          e.toString().contains('NetworkException')) {
        throw Exception('Problème de connexion réseau. Vérifiez votre connexion internet.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Délai d\'attente dépassé. Réessayez plus tard.');
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        throw Exception('Code PIN incorrect. Veuillez réessayer.');
      } else if (e.toString().contains('404')) {
        throw Exception('Utilisateur non trouvé.');
      } else if (e.toString().contains('500')) {
        throw Exception('Erreur serveur. Réessayez plus tard.');
      }
      throw Exception('Erreur lors de la connexion.');
    }
  }

  static Future<void> logout() async {
    print('Logging out...');
    try {
      await ApiService.post('/auth/logout', {});
      await clearUserData();
      print('Logout successful');
    } catch (e) {
      print('Failed to logout: $e');
      // Même en cas d'erreur, on supprime les données locales
      await clearUserData();
      throw Exception('Failed to logout: $e');
    }
  }

  static Future<Map<String, dynamic>> refreshToken() async {
    print('Refreshing token...');
    try {
      final response = await ApiService.post('/auth/refresh', {});
      print('Token refreshed: $response');

      // Mettre à jour le token si présent dans la réponse
      if (response['token'] != null) {
        await storeToken(response['token']);
      }

      return response;
    } catch (e) {
      print('Failed to refresh token: $e');
      throw Exception('Failed to refresh token: $e');
    }
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    print('Getting user profile...');
    try {
      final response = await ApiService.get('/auth/profile');
      print('User profile retrieved: $response');
      return response;
    } catch (e) {
      print('Failed to get user profile: $e');
      throw Exception('Failed to get user profile: $e');
    }
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    print('Updating user profile...');
    try {
      final response = await ApiService.put('/auth/profile', profileData);
      print('Profile updated: $response');
      return response;
    } catch (e) {
      print('Failed to update profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  static Future<void> changePin(String currentPin, String newPin) async {
    print('Changing PIN...');
    try {
      await ApiService.post('/auth/change-pin', {
        'current_pin': currentPin,
        'new_pin': newPin,
      });
      print('PIN changed successfully');
    } catch (e) {
      print('Failed to change PIN: $e');
      throw Exception('Failed to change PIN: $e');
    }
  }

  static Future<void> resetPin(String phoneNumber) async {
    print('Resetting PIN for phone: $phoneNumber');
    try {
      await ApiService.post('/auth/reset-pin', {
        'phone_number': phoneNumber,
      });
      print('PIN reset request sent');
    } catch (e) {
      print('Failed to reset PIN: $e');
      throw Exception('Failed to reset PIN: $e');
    }
  }

  // Méthodes pour gérer l'état de connexion avec Flutter Secure Storage
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getStoredToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  static Future<String?> getStoredToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }

  static Future<void> storeToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      print('Token stored successfully');
    } catch (e) {
      print('Error storing token: $e');
    }
  }

  static Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      print('Token cleared successfully');
    } catch (e) {
      print('Error clearing token: $e');
    }
  }

  // Méthodes pour gérer toutes les données utilisateur
  static Future<void> storeUserData({
    required String token,
    required String userId,
    required String msisdn,
    required String userName,
  }) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(key: _userIdKey, value: userId);
      await _secureStorage.write(key: _msisdnKey, value: msisdn);
      await _secureStorage.write(key: _userNameKey, value: userName);
      print('User data stored successfully');
    } catch (e) {
      print('Error storing user data: $e');
    }
  }

  static Future<Map<String, String?>> getStoredUserData() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      final userId = await _secureStorage.read(key: _userIdKey);
      final msisdn = await _secureStorage.read(key: _msisdnKey);
      final userName = await _secureStorage.read(key: _userNameKey);

      return {
        'token': token,
        'userId': userId,
        'msisdn': msisdn,
        'userName': userName,
      };
    } catch (e) {
      print('Error reading user data: $e');
      return {};
    }
  }

  static Future<void> clearUserData() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _msisdnKey);
      await _secureStorage.delete(key: _userNameKey);
      print('User data cleared successfully');
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  // Méthodes utilitaires pour récupérer des données spécifiques
  static Future<String?> getStoredUserId() async {
    try {
      return await _secureStorage.read(key: _userIdKey);
    } catch (e) {
      print('Error reading user ID: $e');
      return null;
    }
  }

  static Future<String?> getStoredMsisdn() async {
    try {
      return await _secureStorage.read(key: _msisdnKey);
    } catch (e) {
      print('Error reading MSISDN: $e');
      return null;
    }
  }

  static Future<String?> getStoredUserName() async {
    try {
      return await _secureStorage.read(key: _userNameKey);
    } catch (e) {
      print('Error reading user name: $e');
      return null;
    }
  }
}