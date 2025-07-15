import 'package:flutter/material.dart';
import '../../domain/services/tontine_service.dart';
import '../screens/home.dart';


class ResultBottomSheet extends StatelessWidget {
  final bool isSuccess;
  final String message;
  final VoidCallback? onDismiss;

  const ResultBottomSheet({
    Key? key,
    required this.isSuccess,
    required this.message,
    this.onDismiss,
  }) : super(key: key);

  static void show(
      BuildContext context, {
        required bool isSuccess,
        required String message,
        VoidCallback? onDismiss,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => ResultBottomSheet(
        isSuccess: isSuccess,
        message: message,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 32),

          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isSuccess
                  ? Image.asset(
                'assets/success.png',
                width: 100,
                height: 100,
              )
                  : Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red,
              ),
            ),
          ),
          SizedBox(height: 24),

          // Title
          Text(
            isSuccess ? 'Succès !' : 'Erreur',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isSuccess ? Colors.orange : Colors.red,
            ),
          ),
          SizedBox(height: 16),

          // Message
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),

          // OK Button
          SizedBox(
            width: double.infinity,
            child: Material(
              color: isSuccess ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () async {
                  // Fermer le bottom sheet
                  Navigator.of(context).pop();

                  // Si c'est un succès, on invalide le cache pour forcer le refresh
                  if (isSuccess) {
                    TontineService.invalidateCache();
                  }

                  // Rediriger vers la page d'accueil
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Home()),
                        (route) => false,
                  );

                  // Appeler onDismiss si défini
                  if (onDismiss != null) {
                    onDismiss!();
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'OK',
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
          SizedBox(height: 16),
        ],
      ),
    );
  }
}