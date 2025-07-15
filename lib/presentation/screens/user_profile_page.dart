import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/custom_app_bar.dart';
import 'auth/phone_login.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String _userName = '';
  String _userPhone = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final name = await _secureStorage.read(key: 'user_name') ?? 'Utilisateur';
      final phone = await _secureStorage.read(key: 'user_msisdn') ?? '';

      setState(() {
        _userName = name;
        _userPhone = phone;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userName = 'Utilisateur';
        _userPhone = '';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Déconnexion',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                // Vider le cache
                await _secureStorage.deleteAll();

                // Rediriger vers la page de connexion
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => PhoneLogin()),
                      (Route<dynamic> route) => false,
                );
              },
              child: Text(
                'Déconnecter',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Profil',
        showBackButton: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
        child: Column(
          children: [
            // En-tête du profil
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.orange[100],
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Nom utilisateur
                  Text(
                    _userName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Numéro de téléphone
                  Text(
                    _userPhone,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Options du profil
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: 'Informations personnelles',
                    subtitle: 'Gérer vos informations',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fonctionnalité en développement')),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildProfileOption(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Paramètres de notification',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fonctionnalité en développement')),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildProfileOption(
                    icon: Icons.security_outlined,
                    title: 'Sécurité',
                    subtitle: 'Paramètres de sécurité',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fonctionnalité en développement')),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: 'Aide et support',
                    subtitle: 'Besoin d\'aide ?',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fonctionnalité en développement')),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Section paramètres
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildProfileOption(
                    icon: Icons.info_outline,
                    title: 'À propos',
                    subtitle: 'Version 1.0.0',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('OrangeMoney Tontine v1.0.0')),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildProfileOption(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Confidentialité',
                    subtitle: 'Politique de confidentialité',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fonctionnalité en développement')),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),

            // Bouton de déconnexion
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                child: Material(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _logout,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Se déconnecter',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.orange,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      indent: 60,
      endIndent: 20,
    );
  }
}