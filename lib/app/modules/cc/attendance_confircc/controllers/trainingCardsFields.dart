import 'dart:convert';

class TrainingCardsFields {
  static final String name = 'NAME';
  static final String id = 'ID';
  static final String rank = 'RANK';
  static final String hub = "HUB";
  static final String nolicense = "NO LICENSE";
  static final String lpDRILL = "LAST PASSED DRILL";
  static final String exDRILL = "EXPIRY DRILL";
  static final String lpLINECHECK = "LAST PASSED LINE CHECK";
  static final String exLINECHECK = "EXPIRY LINE CHECK";
  static final String lpSEP = "LAST PASSED SEP";
  static final String exSEP = "EXPIRY SEP";
  static final String lpDGR = "LAST PASSED DGR";
  static final String exDGR = "EXPIRY DGR";
  static final String lpAVSEC = "LAST PASSED AVSEC";
  static final String exAVSEC = "EXPIRY AVSEC";
  static final String lpCRM = "LAST PASSED CRM";
  static final String exCRM = "EXPIRY CRM";
  static final String lpRGT = "LAST PASSED RGT";
  static final String exRGT = "EXPIRY RGT";
  static final String lpWDS = "LAST PASSED WDS";
  static final String exWDS = "EXPIRY WDS";
  static final String lpPBNALARCFIT = "LAST PASSED PBN/ALAR/CFIT";
  static final String exPBNALARCFIT = "EXPIRY PBN/ALAR/CFIT";
  static final String lpSMS = "LAST PASSED SMS";
  static final String exSMS = "EXPIRY SMS";

  static List<String> getFields() => [id, name, rank, hub, lpDRILL, exDRILL, lpLINECHECK, exLINECHECK,
    lpSEP, exSEP, lpDGR, exDGR, lpAVSEC, exAVSEC, lpCRM, exCRM, lpRGT, exRGT, lpWDS, exWDS,
    lpPBNALARCFIT, exPBNALARCFIT, lpSMS, exSMS
  ];
}

class TrainingCards {
  final String? name;
  final int id;
  final String rank;
  final String hub;

  const TrainingCards({
    required this.name,
    required this.id,
    required this.rank,
    required this.hub,
  });

//   TrainingCards copy({
//     int? no,
//     String? name,
//     int? id,
//     String? rank,
//     String? hub,
//     String? nolicense
// }) =>
//   TrainingCards(
//       name: name ?? this.name,
//       id: id ?? this.id,
//       rank: rank ?? this.rank,
//       hub: hub ?? this.hub,
//       nolicense: nolicense ?? this.nolicense
//
//   );

  static TrainingCards fromJson(Map<String, dynamic> json) => TrainingCards(
    id: jsonDecode(json[TrainingCardsFields.id]),
    name: json[TrainingCardsFields.name],
    rank: json[TrainingCardsFields.rank],
    hub : json[TrainingCardsFields.hub],
  );

  Map<String, dynamic> toJson() => {
    TrainingCardsFields.name: name,
    TrainingCardsFields.id: id,
    TrainingCardsFields.rank : rank,
    TrainingCardsFields.hub : hub,
  };


}