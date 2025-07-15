import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class CreateTour extends StatefulWidget {
  final Map<String, dynamic> formData;

  const CreateTour({Key? key, required this.formData}) : super(key: key);

  @override
  _CreateTourState createState() => _CreateTourState();
}

class _CreateTourState extends State<CreateTour> {
  late List<Map<String, String>> participants;

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

                    // Liste réorganisable
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: participants.length,
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
                        return Container(
                          key: ValueKey(participant['name']! + index.toString()),
                          margin: EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
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
                                        Text(
                                          participant['name']!,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange,
                                          ),
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
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _sendTontine,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
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

  void _sendTontine() {
    // Créer l'objet tontine final avec l'ordre des participants
    final finalTontineData = {
      ...widget.formData,
      'participants': participants,
    };

    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tontine créée avec succès !'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Ici vous pouvez ajouter la logique pour sauvegarder la tontine
    // Par exemple, appeler une API ou sauvegarder en local
    print('Tontine Data: $finalTontineData');

    // Navigation vers la page précédente ou une autre page
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}