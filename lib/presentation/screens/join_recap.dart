import 'package:flutter/material.dart';
import '../../domain/services/tontine_service.dart';
import '../../models/tontine.dart';
import '../widgets/custom_app_bar.dart';

class JoinRecap extends StatefulWidget {
  final Tontine tontine;

  const JoinRecap({Key? key, required this.tontine}) : super(key: key);

  @override
  _JoinRecapState createState() => _JoinRecapState();
}

class _JoinRecapState extends State<JoinRecap> {
  bool _isLoading = false;

  void _onJoinTontine() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await TontineService.joinTontine(widget.tontine.codeEntree);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous avez rejoint la tontine avec succès !')),
      );

      // Retourner à la page d'accueil
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
              'Vous êtes invité à rejoindre la tontine',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                widget.tontine.nom,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            SizedBox(height: 32),
            _buildInfoCard(),
            SizedBox(height: 32),
            Container(
              width: double.infinity,
              child: Material(
                color: _isLoading ? Colors.grey[400] : Colors.grey[600],
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _isLoading ? null : _onJoinTontine,
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

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow('Administrateur de la tontine', widget.tontine.owner),
          _buildInfoRow('Nom de la tontine', widget.tontine.nom),
          _buildInfoRow('Périodicité', _getPeriodiciteText(widget.tontine.periodicite)),
          _buildInfoRow('Date début', widget.tontine.formattedDate),
          _buildInfoRow('Cotisation par membre', widget.tontine.formattedAmount),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
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
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodiciteText(FrequenceTontine periodicite) {
    switch (periodicite) {
      case FrequenceTontine.week:
        return 'Hebdomadaire';
      case FrequenceTontine.month:
        return 'Mensuelle';
      case FrequenceTontine.day:
        return 'Annuelle';
      default:
        return 'Non définie';
    }
  }

  
}