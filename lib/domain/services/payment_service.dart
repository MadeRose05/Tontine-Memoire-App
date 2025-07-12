import '../../models/tontine.dart';
import 'api_service.dart';

class PaymentService {
  static Future<void> sendPayment(String fromUserId, String toUserId, double amount, String tontineId) async {
    try {
      final paymentData = {
        'emetteur': fromUserId,
        'receveur': toUserId,
        'amount': amount,
        'tontineId': tontineId,
        'date': DateTime.now().toIso8601String(),
      };
      await ApiService.post('/payments', paymentData);
    } catch (e) {
      throw Exception('Failed to send payment: $e');
    }
  }

  static Future<List<Payment>> getPaymentHistory(String userId) async {
    try {
      final response = await ApiService.get('/payments/user/$userId');
      // Parse and return payments
      throw UnimplementedError('Implementation depends on API response format');
    } catch (e) {
      throw Exception('Failed to get payment history: $e');
    }
  }
}