import '../../models/tontine.dart';
import 'api_service.dart';

class TontineService {
  static Future<List<Tontine>> getTontines() async {
    print(' Fetching tontines...');
    try {
      final response = await ApiService.get('/tontines');
      print(' Tontines fetched from API: $response');

      // TODO: parser réellement le résultat API ici
      throw UnimplementedError('Parser non implémenté');

    } catch (e) {
      print(' Failed to fetch tontines from API: $e');
      print(' Using mock tontines instead');
      return _getMockTontines();
    }
  }

  static Future<Tontine> createTontine(Map<String, dynamic> tontineData) async {
    print('Creating tontine...');
    try {
      final response = await ApiService.post('/tontines', tontineData);
      print('Tontine created: $response');

      throw UnimplementedError('Parser non implémenté');

    } catch (e) {
      print(' Failed to create tontine: $e');
      throw Exception('Failed to create tontine: $e');
    }
  }

  static Future<Tontine> updateTontine(String id, Map<String, dynamic> tontineData) async {
    print('Updating tontine $id...');
    try {
      final response = await ApiService.put('/tontines/$id', tontineData);
      print('Tontine updated: $response');

      throw UnimplementedError('Parser non implémenté');

    } catch (e) {
      print('Failed to update tontine $id: $e');
      throw Exception('Failed to update tontine: $e');
    }
  }

  static Future<void> deleteTontine(String id) async {
    print('Deleting tontine $id...');
    try {
      await ApiService.delete('/tontines/$id');
      print('Tontine $id deleted');
    } catch (e) {
      print('Failed to delete tontine $id: $e');
      throw Exception('Failed to delete tontine: $e');
    }
  }

  static Future<List<Tontine>> getPendingTontines() async {
    print(' Getting pending tontines...');
    try {
      final allTontines = await getTontines();
      return allTontines.where((t) => t.status == TontineStatus.pending).toList();
    } catch (e) {
      print('Failed to get pending tontines: $e');
      throw Exception('Failed to get pending tontines: $e');
    }
  }

  static Future<List<Tontine>> getOngoingTontines() async {
    print('Getting ongoing tontines...');
    try {
      final allTontines = await getTontines();
      return allTontines.where((t) => t.status == TontineStatus.ongoing).toList();
    } catch (e) {
      print('Failed to get ongoing tontines: $e');
      throw Exception('Failed to get ongoing tontines: $e');
    }
  }

  static Future<void> nextTour(String tontineId) async {
    print(' Advancing to next tour for tontine $tontineId...');
    try {
      throw UnimplementedError('Business logic non défini');
    } catch (e) {
      print(' Failed to advance tour: $e');
      throw Exception('Failed to advance tour: $e');
    }
  }

  static Future<void> startTontine(String tontineId) async {
    print(' Starting tontine $tontineId...');
    try {
      await updateTontine(tontineId, {'status': 'ongoing'});
      print('Tontine started');
    } catch (e) {
      print('Failed to start tontine: $e');
      throw Exception('Failed to start tontine: $e');
    }
  }

  static Future<List<Tontine>> getEndedTontines() async {
    print('🔍 Getting ended tontines...');
    try {
      final allTontines = await getTontines();
      return allTontines.where((t) => t.status == TontineStatus.ended).toList();
    } catch (e) {
      print('Failed to get ended tontines: $e');
      throw Exception('Failed to get ended tontines: $e');
    }
  }

  static Future<Map<String, dynamic>> getTontineArchive(String tontineId) async {
    print('Fetching archive for tontine $tontineId...');
    try {
      final response = await ApiService.get('/tontines/$tontineId/archive');
      print('Archive fetched: $response');
      return response;
    } catch (e) {
      print('Failed to get tontine archive: $e');
      throw Exception('Failed to get tontine archive: $e');
    }
  }

  static List<Tontine> _getMockTontines() {
    print('Returning mocked tontines');
    return [
      Tontine(
        id: '1',
        nom: 'Mariage de Clovis',
        status: TontineStatus.ongoing,
        periodicite: FrequenceTontine.month,
        cotisation: 10000,
        frais: 500,
        dateDebut: DateTime(2024, 11, 6),
        nbreTour: 12,
        tour: 3,
        typeBeneficiaire: BenefType.unique,
        codeEntree: 'MAR123',
        owner: 'user1',
        participants: [],
      ),
      Tontine(
        id: '2',
        nom: 'Soutien scolaire Jean',
        status: TontineStatus.ongoing,
        periodicite: FrequenceTontine.month,
        cotisation: 10000,
        frais: 500,
        dateDebut: DateTime(2024, 11, 6),
        nbreTour: 10,
        tour: 2,
        typeBeneficiaire: BenefType.unique,
        codeEntree: 'SCO456',
        owner: 'user1',
        participants: [],
      ),
      Tontine(
        id: '3',
        nom: 'Anniversaire Eric',
        status: TontineStatus.ongoing,
        periodicite: FrequenceTontine.month,
        cotisation: 10000,
        frais: 500,
        dateDebut: DateTime(2024, 11, 6),
        nbreTour: 8,
        tour: 0,
        typeBeneficiaire: BenefType.unique,
        codeEntree: 'ANN789',
        owner: 'user1',
        participants: [],
      ),
      Tontine(
        id: '3',
        nom: 'Anniversaire Eric',
        status: TontineStatus.ended,
        periodicite: FrequenceTontine.month,
        cotisation: 10000,
        frais: 500,
        dateDebut: DateTime(2024, 11, 6),
        nbreTour: 8,
        tour: 0,
        typeBeneficiaire: BenefType.unique,
        codeEntree: 'ANN789',
        owner: 'user1',
        participants: [],
      ),
    ];
  }
}
