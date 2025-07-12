import 'package:intl/intl.dart';

enum TontineStatus { pending, ongoing, ended }
enum FrequenceTontine { day, week, month }
enum BenefType { unique, multiples }
enum PaymentStatus { done, failed }

class Beneficiaire {
  final String nom;
  final String msisdn;
  final double currentAmount;
  final double expectedAmount;
  final List<dynamic> receivPayement;
  final bool canWithdraw;

  Beneficiaire({
    required this.nom,
    required this.msisdn,
    this.currentAmount = 0,
    required this.expectedAmount,
    this.receivPayement = const [],
    this.canWithdraw = false,
  });
}

class Participant {
  final String nom;
  final String msisdn;
  final bool join;
  final int round;
  final double currentAmount;
  final double expectedAmount;
  final List<dynamic> emitPayement;
  final List<dynamic> receivPayement;

  Participant({
    required this.nom,
    required this.msisdn,
    this.join = false,
    required this.round,
    this.currentAmount = 0,
    required this.expectedAmount,
    this.emitPayement = const [],
    this.receivPayement = const [],
  });
}

class Tontine {
  final String id;
  final String nom;
  final TontineStatus status;
  final FrequenceTontine periodicite;
  final double cotisation;
  final double frais;
  final DateTime dateDebut;
  final int nbreTour;
  final int tour;
  final BenefType typeBeneficiaire;
  final String codeEntree;
  final String owner;
  final List<Participant> participants;

  Tontine({
    required this.id,
    required this.nom,
    required this.status,
    required this.periodicite,
    required this.cotisation,
    required this.frais,
    required this.dateDebut,
    required this.nbreTour,
    required this.tour,
    required this.typeBeneficiaire,
    required this.codeEntree,
    required this.owner,
    required this.participants,
  });

  String get formattedDate => DateFormat('dd/MM/yyyy').format(dateDebut);
  String get formattedAmount => '${cotisation.toStringAsFixed(0)} CFA';
}

class Payment {
  final String id;
  final String emetteur;
  final String receveur;
  final String tontineId;
  final int tour;
  final double amount;
  final DateTime date;
  final PaymentStatus status;

  Payment({
    required this.id,
    required this.emetteur,
    required this.receveur,
    required this.tontineId,
    required this.tour,
    required this.amount,
    required this.date,
    required this.status,
  });
}