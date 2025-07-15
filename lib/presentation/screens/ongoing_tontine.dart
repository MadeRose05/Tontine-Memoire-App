import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/tontine.dart';
import '../widgets/custom_app_bar.dart';

class OngoingTontine extends StatefulWidget {
  final Tontine tontine;

  const OngoingTontine({Key? key, required this.tontine}) : super(key: key);

  @override
  _OngoingTontineState createState() => _OngoingTontineState();
}

class _OngoingTontineState extends State<OngoingTontine> {
  String selectedTab = 'Déjà payé';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        showBackButton: true,
        title: 'Détails de la Tontine',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tontine name and icon
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: Colors.orange,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nom de la Tontine',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              widget.tontine.nom,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Orange total amount card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Cagnotte Tontine',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${(widget.tontine.cotisation * widget.tontine.participants.length).toStringAsFixed(0)} F CFA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Details
                  Text(
                    'Détail',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildDetailRow('Date de début', widget.tontine.formattedDate),
                  _buildDetailRow('Date de fin', _calculateEndDate()),
                  _buildDetailRow('Nombre de participant', '${widget.tontine.participants.length}'),
                  _buildDetailRow('Montant par participant', widget.tontine.formattedAmount),
                ],
              ),
            ),

            // Status tabs
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTabButton('Déjà payé', Colors.orange),
                  SizedBox(width: 8),
                  _buildTabButton('En attente', Colors.grey),
                ],
              ),
            ),

            // Participants list
            Container(
              margin: EdgeInsets.all(16),
              child: Column(
                children: _buildParticipantsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
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

  Widget _buildTabButton(String title, Color activeColor) {
    bool isActive = selectedTab == title;
    return Expanded(
      child: Material(
        color: isActive ? activeColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            setState(() {
              selectedTab = title;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildParticipantsList() {
    // Filter participants based on selected tab
    List<Participant> filteredParticipants = widget.tontine.participants;

    if (selectedTab == 'Déjà payé') {
      // Show participants who have paid (you can adjust this logic based on your data structure)
      filteredParticipants = widget.tontine.participants.where((p) => p.currentAmount >= widget.tontine.cotisation).toList();
    } else {
      // Show participants who haven't paid yet
      filteredParticipants = widget.tontine.participants.where((p) => p.currentAmount < widget.tontine.cotisation).toList();
    }

    return filteredParticipants.map((participant) {
      return Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 12),

            // Participant info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mon numéro',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        participant.msisdn.isNotEmpty ? participant.msisdn : '07 00 03 00 00',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Montant',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${widget.tontine.cotisation.toStringAsFixed(0)} F CFA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date de paiement',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _getPaymentDate(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _calculateEndDate() {
    DateTime endDate = widget.tontine.dateDebut.add(Duration(days: widget.tontine.nbreTour * 30));
    return DateFormat('dd-MM-yyyy').format(endDate);
  }

  String _getPaymentDate() {
    return DateFormat('dd-MM-yyyy').format(DateTime.now().subtract(Duration(days: 1)));
  }
}