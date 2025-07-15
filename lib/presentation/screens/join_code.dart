import 'package:flutter/material.dart';
import '../../domain/services/tontine_service.dart';
import '../../models/tontine.dart';
import '../widgets/custom_app_bar.dart';
import 'join_recap.dart';

class JoinCode extends StatefulWidget {
  @override
  _JoinCodeState createState() => _JoinCodeState();
}

class _JoinCodeState extends State<JoinCode> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  void _onJoinPressed() async {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer un code d\'invitation')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tontine = await TontineService.getTontineByUser();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinRecap(tontine: tontine),
        ),
      );
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
              'Rejoindre',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Entrez le code pour rejoindre la Tontine. Suivez les cotisations et envoyez la vôtre, en toute simplicité !',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: Container(
                width: 250,
                height: 200,
                child: Image.asset(
                  'assets/join1.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Rejoindre une nouvelle Tontine',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: 'Code d\'invitation',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: TextStyle(fontSize: 16),
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
            ),
            SizedBox(height: 80),
            Container(
              width: double.infinity,
              child: Material(
                color: _isLoading ? Colors.grey[400] : Colors.grey[600],
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
                        'Rejoindre',
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

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}