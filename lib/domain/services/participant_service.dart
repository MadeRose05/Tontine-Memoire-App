
import '../../models/tontine.dart';
import 'api_service.dart';

class ParticipantService {
  static Future<void> joinTontine(String tontineId, String userId) async {
    try {
      await ApiService.post('/tontines/$tontineId/participants', {'userId': userId});
    } catch (e) {
      throw Exception('Failed to join tontine: $e');
    }
  }

  static Future<void> leaveTontine(String tontineId, String userId) async {
    try {
      await ApiService.delete('/tontines/$tontineId/participants/$userId');
    } catch (e) {
      throw Exception('Failed to leave tontine: $e');
    }
  }

  static Future<List<Participant>> getTontineParticipants(String tontineId) async {
    try {
      final response = await ApiService.get('/tontines/$tontineId/participants');
      // Parse and return participants
      throw UnimplementedError('Implementation depends on API response format');
    } catch (e) {
      throw Exception('Failed to get participants: $e');
    }
  }
}


class BeneficiaireService {
  static Future<Beneficiaire?> getCurrentBeneficiaire(String tontineId) async {
    try {
      final response = await ApiService.get('/tontines/$tontineId/beneficiaire/current');
      // Parse and return current beneficiaire
      throw UnimplementedError('Implementation depends on API response format');
    } catch (e) {
      throw Exception('Failed to get current beneficiaire: $e');
    }
  }

  static Future<void> withdrawFunds(String tontineId, String beneficiaireId, double amount) async {
    try {
      await ApiService.post('/tontines/$tontineId/withdraw', {
        'beneficiaireId': beneficiaireId,
        'amount': amount,
      });
    } catch (e) {
      throw Exception('Failed to withdraw funds: $e');
    }
  }

  static Future<List<Beneficiaire>> getBeneficiaireHistory(String tontineId) async {
    try {
      final response = await ApiService.get('/tontines/$tontineId/beneficiaires/history');
      // Parse and return beneficiaire history
      throw UnimplementedError('Implementation depends on API response format');
    } catch (e) {
      throw Exception('Failed to get beneficiaire history: $e');
    }
  }
}