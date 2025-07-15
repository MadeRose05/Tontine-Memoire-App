import 'package:flutter/material.dart';
import '../screens/user_profile_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final String? title;

  const CustomAppBar({
    Key? key,
    this.showBackButton = true,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      )
          : null,
      title: title != null
          ? Text(
        title!,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      )
          : null,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: Colors.black),
          onPressed: () {
            // TODO: Implémenter les notifications
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Notifications - Fonctionnalité en développement')),
            );
          },
        ),
        IconButton(
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, color: Colors.grey[600], size: 20),
          ),
          onPressed: () {
            // Navigation vers la page de profil
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfilePage()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}