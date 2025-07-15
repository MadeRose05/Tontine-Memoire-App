import 'package:flutter/material.dart';
import '../../domain/services/tontine_service.dart';
import '../../models/tontine.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/result_bottomSheet.dart';

class JoinRecap extends StatefulWidget {
  final Tontine tontine;
  final String inviteCode;

  const JoinRecap({
    Key? key,
    required this.tontine,
    required this.inviteCode,
  }) : super(key: key);

  @override
  _JoinRecapState createState() => _JoinRecapState();
}

class _JoinRecapState extends State<JoinRecap> {
  bool _isLoading = false;

  void _onJoinPressed() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await TontineService.joinTontine(widget.inviteCode);

      // Afficher le bottom sheet de succès
      ResultBottomSheet.show(
        context,
        isSuccess: true,
        message: 'Vous avez rejoint la tontine "${widget.tontine.nom}" avec succès !',
        onDismiss: () {
          // Retourner à l'écran précédent ou à l'accueil
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    } catch (e) {
      // Afficher le bottom sheet d'erreur
      ResultBottomSheet.show(
        context,
        isSuccess: false,
        message: 'Échec lors de la tentative de rejoindre la tontine. ${e.toString()}',
        onDismiss: () {
          // Rester sur la page pour permettre un nouvel essai
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getFrequencyText(FrequenceTontine frequency) {
    switch (frequency) {
      case FrequenceTontine.day:
        return 'Quotidienne';
      case FrequenceTontine.week:
        return 'Hebdomadaire';
      case FrequenceTontine.month:
        return 'Mensuelle';
      default:
        return 'Mensuelle';
    }
  }

  String _getStatusText(TontineStatus status) {
    switch (status) {
      case TontineStatus.pending:
        return 'En attente';
      case TontineStatus.ongoing:
        return 'En cours';
      case TontineStatus.ended:
        return 'Terminée';
      default:
        return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(showBackButton: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Récapitulatif',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Vérifiez les détails de la tontine avant de rejoindre.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),

            // Carte de la tontine
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tontine.nom,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),

                  _buildInfoRow('Propriétaire', widget.tontine.owner),
                  _buildInfoRow('Code d\'invitation', widget.inviteCode),
                  _buildInfoRow('Cotisation', '${widget.tontine.cotisation.toStringAsFixed(0)} FCFA'),
                  _buildInfoRow('Frais', '${widget.tontine.frais.toStringAsFixed(0)} FCFA'),
                  _buildInfoRow('Nombre de tours', '${widget.tontine.nbreTour}'),
                  _buildInfoRow('Fréquence', _getFrequencyText(widget.tontine.periodicite)),
                  _buildInfoRow('Statut', _getStatusText(widget.tontine.status)),
                  _buildInfoRow('Participants', '${widget.tontine.participants.length}'),

                  if (widget.tontine.dateDebut != null)
                    _buildInfoRow('Date de début',
                        '${widget.tontine.dateDebut!.day}/${widget.tontine.dateDebut!.month}/${widget.tontine.dateDebut!.year}'),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Bouton rejoindre
            Container(
              width: double.infinity,
              child: Material(
                color: _isLoading ? Colors.grey[400] : Colors.orange,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _isLoading ? null : _onJoinPressed,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: _isLoading
                          ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                          : Text(
                        'Rejoindre la tontine',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}