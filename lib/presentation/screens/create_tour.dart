import 'package:flutter/material.dart';
import '../../domain/services/tontine_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/result_bottomSheet.dart';


class CreateTour extends StatefulWidget {
  final Map<String, dynamic> formData;

  const CreateTour({Key? key, required this.formData}) : super(key: key);

  @override
  _CreateTourState createState() => _CreateTourState();
}

class _CreateTourState extends State<CreateTour> {
  late List<Map<String, String>> participants;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Copier la liste des participants pour pouvoir la modifier
    participants = List<Map<String, String>>.from(
        widget.formData['participants'].map((p) => Map<String, String>.from(p))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        showBackButton: true,
        title: 'Nouvelle O\'Coti',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Message d'instruction
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Ranger les participants dans l\'ordre souhaité',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24),

            // Liste des participants réorganisables
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Participants',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Liste réorganisable avec paramètres améliorés
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: participants.length,
                      // Améliorer la sensibilité du drag and drop
                      buildDefaultDragHandles: false,
                      // Supprimer le conteneur blanc de l'élément en cours de déplacement
                      proxyDecorator: (child, index, animation) {
                        return Material(
                          color: Colors.transparent,
                          child: child,
                        );
                      },
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex--;
                          }
                          final participant = participants.removeAt(oldIndex);
                          participants.insert(newIndex, participant);
                        });
                      },
                      itemBuilder: (context, index) {
                        final participant = participants[index];
                        final isCurrentUser = participant['isCurrentUser'] == 'true';

                        return ReorderableDragStartListener(
                          key: ValueKey(participant['name']! + index.toString()),
                          index: index,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 12),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.orange.withOpacity(0.3)
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Numéro d'ordre
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),

                                    // Avatar du participant
                                    CircleAvatar(
                                      backgroundColor: Colors.orange,
                                      radius: 20,
                                      child: Text(
                                        participant['name']![0].toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),

                                    // Informations du participant
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              if (isCurrentUser) ...[
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                    'Vous',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ] else ...[
                                                Text(
                                                  participant['name']!,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          if (participant['phone']!.isNotEmpty)
                                            Text(
                                              participant['phone']!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // Icône de drag
                                    Icon(
                                      Icons.drag_handle,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),

            // Bouton Envoyer
            SizedBox(
              width: double.infinity,
              child: Material(
                color: _isLoading ? Colors.grey : Colors.orange,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _isLoading ? null : _sendTontine,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: _isLoading
                        ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                        : Text(
                      'Envoyer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendTontine() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Préparer les participants avec l'ordre correct
      final List<Map<String, dynamic>> participantsData = participants.asMap().entries.map((entry) {
        final index = entry.key;
        final participant = entry.value;
        return {
          "msisdn": participant['phone'] ?? '',
          "nom": participant['name'] ?? '',
          "round": index + 1, // L'ordre commence à 1
        };
      }).toList();

      // Mapper la fréquence selon l'enum (API attend Day, Week, Month avec majuscule)
      String frequence = 'Month'; // valeur par défaut
      if (widget.formData['frequency'] != null) {
        switch (widget.formData['frequency'].toString().toLowerCase()) {
          case 'day':
            frequence = 'Day';
            break;
          case 'week':
            frequence = 'Week';
            break;
          case 'month':
          default:
            frequence = 'Month';
            break;
        }
      }

      // Formater la date de début en ISO 8601
      String startDate = DateTime.now().toIso8601String();
      if (widget.formData['startDate'] != null) {
        // Si c'est déjà un DateTime
        if (widget.formData['startDate'] is DateTime) {
          startDate = (widget.formData['startDate'] as DateTime).toIso8601String();
        } else if (widget.formData['startDate'] is String) {
          // Si c'est une string, essayer de la parser
          try {
            // Gérer le format "24/7/2025"
            String dateString = widget.formData['startDate'];
            if (dateString.contains('/')) {
              List<String> parts = dateString.split('/');
              if (parts.length == 3) {
                int day = int.parse(parts[0]);
                int month = int.parse(parts[1]);
                int year = int.parse(parts[2]);
                startDate = DateTime(year, month, day).toIso8601String();
              }
            } else {
              // Essayer de parser directement
              startDate = DateTime.parse(widget.formData['startDate']).toIso8601String();
            }
          } catch (e) {
            print('Error parsing date: $e, using current date');
            startDate = DateTime.now().toIso8601String();
          }
        }
      }

      // Créer l'objet tontine pour l'API (sans le champ description)
      final Map<String, dynamic> tontineData = {
        "nom": widget.formData['name'] ?? '',
        "totalRound": participantsData.length,
        "frequence": frequence,
        "cotisation": widget.formData['amount'] ?? 0,
        "startDate": startDate,
        "participants": participantsData,
      };

      print('Sending tontine data: $tontineData');

      // Appel API
      await TontineService.createTontine(tontineData);

      // Succès
      ResultBottomSheet.show(
        context,
        isSuccess: true,
        message: 'Tontine créée avec succès !',
        onDismiss: () {
          // Invalider le cache et retourner à la page principale
          TontineService.invalidateCache();
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      );

    } catch (e) {
      print('Error creating tontine: $e');

      // Erreur
      ResultBottomSheet.show(
        context,
        isSuccess: false,
        message: 'Erreur lors de la création de la tontine: ${e.toString()}',
        onDismiss: () {
          // Reste sur la page actuelle
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}