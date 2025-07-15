import '../../models/tontine.dart';
import 'api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TontineService {
  static const _storage = FlutterSecureStorage();
  static List<Tontine>? _cachedTontines;
  static bool _isLoading = false;

  static Future<List<Tontine>> getTontines() async {
    // Si on a déjà les données en cache et qu'on n'est pas en train de charger
    if (_cachedTontines != null && !_isLoading) {
      print('Returning cached tontines');
      return _cachedTontines!;
    }

    // Si on est déjà en train de charger, attendre
    if (_isLoading) {
      while (_isLoading) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      return _cachedTontines ?? [];
    }

    print('Fetching tontines from API...');
    _isLoading = true;

    try {
      final response = await ApiService.get('/tontine');
      print('Tontines fetched from API: $response');

      // Vérifier le status code et la structure de la réponse
      if (response is Map<String, dynamic>) {
        // Gérer les status codes d'erreur
        if (response.containsKey('status') && response['status'] >= 400) {
          throw Exception('API Error: ${response['status']} - ${response['message'] ?? 'Unknown error'}');
        }

        // Extraire les données des tontines
        dynamic tontinesData = [];
        if (response.containsKey('data')) {
          tontinesData = response['data'];
        } else if (response is List) {
          tontinesData = response;
        }

        // Si c'est un Map, cela signifie qu'il y a une seule tontine
        if (tontinesData is Map<String, dynamic>) {
          tontinesData = [tontinesData];
        }

        // Convertir en List<dynamic> si ce n'est pas déjà le cas
        List<dynamic> tontinesList = tontinesData is List ? tontinesData : [];

        // Si le tableau est vide, aucune tontine
        if (tontinesList.isEmpty) {
          print('No tontines found in API response');
          _cachedTontines = [];
          _isLoading = false;
          return [];
        }

        // Parser les tontines
        List<Tontine> tontines = tontinesList.map<Tontine>((tontineJson) {
          return _parseTontineFromJson(tontineJson);
        }).toList();

        _cachedTontines = tontines;
        _isLoading = false;
        return tontines;
      } else {
        throw Exception('Invalid response format');
      }

    } catch (e) {
      print('Failed to fetch tontines from API: $e');
      _isLoading = false;

      // En cas d'erreur, retourner les données mock
      print('Using mock tontines instead');
      _cachedTontines = _getMockTontines();
      return _cachedTontines!;
    }
  }

  // Méthode pour parser une tontine depuis JSON
  static Tontine _parseTontineFromJson(Map<String, dynamic> json) {
    // Mapper le status string vers l'enum
    TontineStatus status = TontineStatus.pending;
    if (json['tontineStatus'] != null) {
      switch (json['tontineStatus'].toString().toLowerCase()) {
        case 'ongoing':
          status = TontineStatus.ongoing;
          break;
        case 'ended':
        case 'completed':
          status = TontineStatus.ended;
          break;
        default:
          status = TontineStatus.pending;
      }
    }

    // Mapper la périodicité
    FrequenceTontine periodicite = FrequenceTontine.month;
    if (json['periodicite'] != null) {
      switch (json['periodicite'].toString().toLowerCase()) {
        case 'day':
          periodicite = FrequenceTontine.day;
          break;
        case 'week':
          periodicite = FrequenceTontine.week;
          break;
        default:
          periodicite = FrequenceTontine.month;
      }
    }

    // Parser les participants
    List<Participant> participants = [];
    if (json['participants'] != null && json['participants'] is List) {
      participants = (json['participants'] as List).map<Participant>((participantJson) {
        return Participant(
          nom: participantJson['nom'] ?? '',
          msisdn: participantJson['msisdn'] ?? '',
          join: participantJson['join'] ?? false,
          round: participantJson['round'] ?? 0,
          currentAmount: (participantJson['currentAmount'] ?? 0).toDouble(),
          expectedAmount: (participantJson['expectedAmount'] ?? 0).toDouble(),
          emitPayement: participantJson['emitPayement'] ?? [],
          receivPayement: participantJson['receivPayement'] ?? [],
        );
      }).toList();
    }

    return Tontine(
      id: json['id']?.toString() ?? '',
      nom: json['nom'] ?? '',
      status: status,
      periodicite: periodicite,
      cotisation: (json['cotisation'] ?? 0).toDouble(),
      frais: (json['frais'] ?? 0).toDouble(),
      dateDebut: json['dateDebut'] != null
          ? DateTime.parse(json['dateDebut'])
          : DateTime.now(),
      nbreTour: json['nbreTour'] ?? 0,
      tour: json['tour'] ?? 0,
      codeEntree: json['codeEntree'] ?? '',
      owner: json['owner'] ?? '',
      participants: participants,
    );
  }

  // Méthode pour invalider le cache et forcer un refresh
  static void invalidateCache() {
    _cachedTontines = null;
    _isLoading = false;
  }

  static Future<Tontine> createTontine(Map<String, dynamic> tontineData) async {
    print('Creating tontine...');
    try {
      final response = await ApiService.post('/tontines', tontineData);
      print('Tontine created: $response');

      // Invalider le cache pour forcer un refresh
      invalidateCache();

      if (response is Map<String, dynamic>) {
        if (response.containsKey('status') && response['status'] >= 400) {
          throw Exception('API Error: ${response['status']} - ${response['message'] ?? 'Unknown error'}');
        }

        // Si on a les données de la tontine créée
        if (response.containsKey('data')) {
          return _parseTontineFromJson(response['data']);
        }
      }

      throw Exception('Invalid response format');

    } catch (e) {
      print('Failed to create tontine: $e');
      throw Exception('Failed to create tontine: $e');
    }
  }

  static Future<Tontine> updateTontine(String id, Map<String, dynamic> tontineData) async {
    print('Updating tontine $id...');
    try {
      final response = await ApiService.put('/tontines/$id', tontineData);
      print('Tontine updated: $response');

      // Invalider le cache pour forcer un refresh
      invalidateCache();

      if (response is Map<String, dynamic>) {
        if (response.containsKey('status') && response['status'] >= 400) {
          throw Exception('API Error: ${response['status']} - ${response['message'] ?? 'Unknown error'}');
        }

        if (response.containsKey('data')) {
          return _parseTontineFromJson(response['data']);
        }
      }

      throw Exception('Invalid response format');

    } catch (e) {
      print('Failed to update tontine $id: $e');
      throw Exception('Failed to update tontine: $e');
    }
  }

  static Future<void> deleteTontine(String id) async {
    print('Deleting tontine $id...');
    try {
      await ApiService.delete('/tontine/$id');

      // Invalider le cache pour forcer un refresh
      invalidateCache();

      print('Tontine $id deleted');
    } catch (e) {
      print('Failed to delete tontine $id: $e');
      throw Exception('Failed to delete tontine: $e');
    }
  }

  // Méthodes qui utilisent les données mises en cache
  static Future<List<Tontine>> getPendingTontines() async {
    print('Getting pending tontines...');
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

  static Future<List<Tontine>> getEndedTontines() async {
    print('Getting ended tontines...');
    try {
      final allTontines = await getTontines();
      return allTontines.where((t) => t.status == TontineStatus.ended).toList();
    } catch (e) {
      print('Failed to get ended tontines: $e');
      throw Exception('Failed to get ended tontines: $e');
    }
  }

  static Future<void> nextTour(String tontineId) async {
    print('Advancing to next tour for tontine $tontineId...');
    try {
      final response = await ApiService.post('/tontines/$tontineId/next-tour', {});

      if (response is Map<String, dynamic> && response.containsKey('status') && response['status'] >= 400) {
        throw Exception('API Error: ${response['status']} - ${response['message'] ?? 'Unknown error'}');
      }

      // Invalider le cache pour forcer un refresh
      invalidateCache();

    } catch (e) {
      print('Failed to advance tour: $e');
      throw Exception('Failed to advance tour: $e');
    }
  }

  static Future<void> startTontine(String tontineId) async {
    print('Starting tontine $tontineId...');
    try {
      await updateTontine(tontineId, {'tontineStatus': 'ongoing'});
      print('Tontine started');
    } catch (e) {
      print('Failed to start tontine: $e');
      throw Exception('Failed to start tontine: $e');
    }
  }

  static Future<Tontine> getTontineByUser() async {
    print('Fetching tontine by user pin...');
    try {
      final userPin = await _storage.read(key: 'user_pin');
      if (userPin == null) {
        throw Exception('User PIN not found in secure storage');
      }

      print('User PIN retrieved from secure storage: $userPin');

      final response = await ApiService.get('/tontines/user/$userPin');
      print('Tontine fetched by user: $response');

      if (response is Map<String, dynamic>) {
        if (response.containsKey('status') && response['status'] >= 400) {
          throw Exception('API Error: ${response['status']} - ${response['message'] ?? 'Unknown error'}');
        }

        if (response.containsKey('data')) {
          return _parseTontineFromJson(response['data']);
        }
      }

      throw Exception('Invalid response format');

    } catch (e) {
      print('Failed to fetch tontine by user: $e');
      return _getMockTontineByUser();
    }
  }

  static Future<void> joinTontine(String code) async {
    print('Joining tontine with code: $code');
    try {
      final userPin = await _storage.read(key: 'user_pin');
      if (userPin == null) {
        throw Exception('User PIN not found in secure storage');
      }

      final response = await ApiService.post('/tontines/join/$code', {
        'user_pin': userPin,
      });

      if (response is Map<String, dynamic> && response.containsKey('status') && response['status'] >= 400) {
        throw Exception('API Error: ${response['status']} - ${response['message'] ?? 'Unknown error'}');
      }

      // Invalider le cache pour forcer un refresh
      invalidateCache();

      print('Successfully joined tontine: $response');
    } catch (e) {
      print('Failed to join tontine: $e');
      throw Exception('Failed to join tontine: $e');
    }
  }


  static Future<Tontine?> getTontineById(String id) async {
    try {
      final allTontines = await getTontines();
      return allTontines.firstWhere((t) => t.id == id);
    } catch (e) {
      print('Tontine with id $id not found: $e');
      return null;
    }
  }

  // Données mock inchangées
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
        codeEntree: 'MAR123',
        owner: 'user1',
        participants: [
          Participant(
            nom: 'Clovis Adjambro',
            msisdn: '07 00 03 00 01',
            join: true,
            round: 1,
            currentAmount: 10000,
            expectedAmount: 10000,
            emitPayement: [],
            receivPayement: [],
          ),
          Participant(
            nom: 'Marie Dupont',
            msisdn: '07 00 03 00 02',
            join: true,
            round: 2,
            currentAmount: 5000,
            expectedAmount: 10000,
            emitPayement: [],
            receivPayement: [],
          ),
        ],
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
        codeEntree: 'SCO456',
        owner: 'user1',
        participants: [
          Participant(
            nom: 'Jean Martin',
            msisdn: '07 00 03 00 03',
            join: true,
            round: 1,
            currentAmount: 10000,
            expectedAmount: 10000,
            emitPayement: [],
            receivPayement: [],
          ),
        ],
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
        codeEntree: 'ANN789',
        owner: 'user1',
        participants: [
          Participant(
            nom: 'Eric Koffi',
            msisdn: '07 00 03 00 04',
            join: true,
            round: 1,
            currentAmount: 8000,
            expectedAmount: 10000,
            emitPayement: [],
            receivPayement: [],
          ),
        ],
      ),
      Tontine(
        id: '4',
        nom: 'Anniversaire Eric',
        status: TontineStatus.ended,
        periodicite: FrequenceTontine.month,
        cotisation: 10000,
        frais: 500,
        dateDebut: DateTime(2024, 11, 6),
        nbreTour: 8,
        tour: 0,
        codeEntree: 'ANN789',
        owner: 'user1',
        participants: [],
      ),
    ];
  }

  static Future<Tontine> _getMockTontineByUser() async {
    print('Returning mock tontine for user');
    final userPin = await _storage.read(key: 'user_pin');

    return Tontine(
      id: '1',
      nom: 'Mariage de Clovis',
      status: TontineStatus.pending,
      periodicite: FrequenceTontine.month,
      cotisation: 10000,
      frais: 500,
      dateDebut: DateTime(2024, 11, 6),
      nbreTour: 12,
      tour: 0,
      codeEntree: 'MAR123',
      owner: 'Clovis Adjambro',
      participants: [],
    );
  }
}