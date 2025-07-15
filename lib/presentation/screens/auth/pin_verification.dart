import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/services/auth_service.dart';


class PinVerification extends StatefulWidget {
  final String phoneNumber;

  const PinVerification({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _PinVerificationState createState() => _PinVerificationState();
}

class _PinVerificationState extends State<PinVerification> {
  String _pin = '';
  bool _isLoading = false;

  void _addDigit(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
      });

      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _removeDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _verifyPin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Appel API pour le login
      final response = await AuthService.login(widget.phoneNumber, _pin);

      setState(() {
        _isLoading = false;
      });

      // Connexion réussie
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connexion réussie !')),
      );

      // Naviguer vers la page d'accueil
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _pin = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code PIN incorrect'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Text(
                'Code PIN',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Entrez votre code PIN pour vous connecter',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                widget.phoneNumber,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Text(
                  'PIN par défaut : 1234',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 40),
              // Affichage du PIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 60,
                    height: 60,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: index < _pin.length ? Colors.orange : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        index < _pin.length ? _pin[index] : '',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Spacer(),
              // Pinpad
              _buildPinpad(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinpad() {
    return Container(
      child: Column(
        children: [
          // Première ligne : 1, 2, 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPinButton('1'),
              _buildPinButton('2'),
              _buildPinButton('3'),
            ],
          ),
          SizedBox(height: 16),
          // Deuxième ligne : 4, 5, 6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPinButton('4'),
              _buildPinButton('5'),
              _buildPinButton('6'),
            ],
          ),
          SizedBox(height: 16),
          // Troisième ligne : 7, 8, 9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPinButton('7'),
              _buildPinButton('8'),
              _buildPinButton('9'),
            ],
          ),
          SizedBox(height: 16),
          // Quatrième ligne : *, 0, delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(width: 80, height: 80), // Espace vide
              _buildPinButton('0'),
              _buildDeleteButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPinButton(String digit) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : () {
          HapticFeedback.lightImpact();
          _addDigit(digit);
        },
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Center(
            child: Text(
              digit,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : () {
          HapticFeedback.lightImpact();
          _removeDigit();
        },
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 24,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}