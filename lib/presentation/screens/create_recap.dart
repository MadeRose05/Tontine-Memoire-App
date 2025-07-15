import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/custom_app_bar.dart';
import 'create_tour.dart'; // Import de la page create_tour
import '../../domain/services/auth_service.dart'; // Import du service d'authentification

class CreateRecap extends StatefulWidget {
  final Map<String, dynamic> formData;

  const CreateRecap({Key? key, required this.formData}) : super(key: key);

  @override
  _CreateRecapState createState() => _CreateRecapState();
}

class _CreateRecapState extends State<CreateRecap> {
  List<Map<String, String>> participants = [];
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userData = await AuthService.getStoredUserData();
      if (userData['userName'] != null && userData['msisdn'] != null) {
        setState(() {
          participants.add({
            'name': userData['userName']!,
            'phone': userData['msisdn']!,
            'isCurrentUser': 'true', // Marquer comme utilisateur actuel
          });
          _isLoadingUserData = false;
        });
      } else {
        setState(() {
          _isLoadingUserData = false;
        });
      }
    } catch (e) {
      print('Error loading current user: $e');
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        showBackButton: true,
        title: 'Nouvelle O\'Coti',
      ),
      body: _isLoadingUserData
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.orange,
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Informations de la tontine
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
                    _buildInfoRow('Nom de la tontine', widget.formData['name']),
                    _buildInfoRow('Date début', widget.formData['startDate']),
                    _buildInfoRow('Périodicité', 'Journalier'),
                    _buildInfoRow('Cotisation par membre', '${widget.formData['amount'].toStringAsFixed(0)} ${widget.formData['currency']}'),
                    _buildInfoRow('Nombre de tour', '${widget.formData['tours']}'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Section Participants
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

                    // Champ pour ajouter un participant
                    InkWell(
                      onTap: _showContactPicker,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ajouter un participant',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                            Icon(
                              Icons.person_add,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Liste des participants ajoutés
                    if (participants.isNotEmpty)
                      Column(
                        children: participants.map((participant) {
                          final isCurrentUser = participant['isCurrentUser'] == 'true';
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
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
                                if (!isCurrentUser) // L'utilisateur actuel ne peut pas être supprimé
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        participants.remove(participant);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),

            // Bouton Suivant (minimum 2 participants requis)
            SizedBox(
              width: double.infinity,
              child: Material(
                color: participants.length < 2 ? Colors.grey[300] : Colors.orange,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: participants.length < 2 ? null : _goToNextStep,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Suivant ${participants.length >= 2 ? '' : '(${2 - participants.length} participant${2 - participants.length > 1 ? 's' : ''} manquant${2 - participants.length > 1 ? 's' : ''})'}',
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showContactPicker() async {
    try {
      final permission = await Permission.contacts.request();

      if (permission.isGranted) {
        final contacts = await FlutterContacts.getContacts(withProperties: true);

        if (contacts.isNotEmpty) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sélectionner un contact',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        final name = contact.displayName;
                        final phone = contact.phones.isNotEmpty
                            ? contact.phones.first.number
                            : '';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(name),
                          subtitle: phone.isNotEmpty ? Text(phone) : null,
                          onTap: () {
                            setState(() {
                              if (!participants.any((p) => p['name'] == name)) {
                                participants.add({
                                  'name': name,
                                  'phone': phone,
                                  'isCurrentUser': 'false',
                                });
                              }
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          _showNoContactsDialog();
        }
      } else {
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      _showGenericParticipantDialog();
    }
  }

  void _showNoContactsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aucun contact'),
        content: Text('Aucun contact trouvé sur votre appareil. Voulez-vous ajouter un participant générique ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addGenericParticipant();
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission refusée'),
        content: Text('L\'accès aux contacts a été refusé. Voulez-vous ajouter un participant générique ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addGenericParticipant();
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showGenericParticipantDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contacts non disponibles'),
        content: Text('Impossible d\'accéder aux contacts. Voulez-vous ajouter un participant générique ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addGenericParticipant();
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _addGenericParticipant() {
    // Compter seulement les participants autres que l'utilisateur actuel
    final otherParticipantsCount = participants.where((p) => p['isCurrentUser'] != 'true').length;
    setState(() {
      participants.add({
        'name': 'Participant ${otherParticipantsCount + 1}',
        'phone': '',
        'isCurrentUser': 'false',
      });
    });
  }

  void _goToNextStep() {
    if (participants.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez ajouter au moins 2 participants (vous inclus)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Créer l'objet tontine complet avec les participants
    final tontineData = {
      ...widget.formData,
      'participants': participants,
    };

    // Navigation vers la page create_tour
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTour(formData: tontineData),
      ),
    );
  }
}