import 'dart:ffi';

class AttendanceDetailModel {
  String? id;
  String? idattendance;
  int? idtraining;
  String? signature_url;
  String? score;
  String? feedback;
  String? status;
  String? creationTime;
  String? updatedTime;
  String? name;
  String? email;
  String? photoURL;
  String? rank;
  String? license;
  String? hub;
  double? rating;
  String? feedbackforinstructor;
  String? formatNo;
  String? certificatemandatory;
  double? grade;
  double? rCommunication;
  double? rKnowledge;
  double? rActive;
  double? rTeachingMethod;
  double? rMastery;
  double? rTimeManagement;

  AttendanceDetailModel({
    this.id,
    this.idattendance,
    this.idtraining,
    this.signature_url,
    this.score,
    this.feedback,
    this.status,
    this.creationTime,
    this.updatedTime,
    this.name,
    this.email,
    this.photoURL,
    this.rank,
    this.license,
    this.hub,
    this.rating,
    this.feedbackforinstructor,
    this.formatNo,
    this.certificatemandatory,
    this.grade,
    this.rCommunication,
    this.rKnowledge,
    this.rActive,
    this.rTeachingMethod,
    this.rMastery,
    this.rTimeManagement

  });

  factory AttendanceDetailModel.fromJson(Map<String, dynamic> json) {
    return AttendanceDetailModel(
        id: json['id'],
        idattendance: json['idattendance'],
        idtraining: json['idtraining'],
        signature_url : json['signature_url'],
        score: json['score'],
        feedback: json['feedback'],
        status: json['status'],
        creationTime: json['creationTime'],
        updatedTime: json['updatedTime'],
        name: json['name'],
        email: json['email'],
        photoURL: json['photoURL'],
        rank: json['rank'],
        license: json['license'],
        hub: json['hub'],
        rating: json['rating']?.toDouble(),
        feedbackforinstructor: json['feedbackforinstructor'],
        formatNo: json['formatNo'],
        certificatemandatory : json['certificatemandatory'],
        grade: json['grade'],
        rCommunication: json['rCommunication'],
        rKnowledge: json['rKnowledge'],
        rActive: json['rActive'],
        rTeachingMethod : json['rTeachingMethod'],
        rMastery : json['rMastery'],
        rTimeManagement : json['rTimeManagement']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idattendance'] = this.idattendance;
    data['idtraining'] = this.idtraining;
    data['signature_url'] = this.signature_url;
    data['score'] = this.score;
    data['feedback'] = this.feedback;
    data['status'] = this.status;
    data['creationTime'] = this.creationTime;
    data['updatedTime'] =  this.updatedTime;
    data['name'] = this.name;
    data['email'] = this.email;
    data['photoURL'] = this.photoURL;
    data['rank'] = this.rank;
    data['license'] = this.license;
    data['hub'] = this.hub;
    data['rating'] = this.rating;
    data['feedbackforinstructor'] = this.feedbackforinstructor;
    data['formatNo'] = this.formatNo;
    data['certificatemandatory'] = this.certificatemandatory;
    data['grade'] = this.grade;
    data['rCommunication'] = this.rCommunication;
    data['rKnowledge'] = this.rKnowledge;
    data['rActive'] = this.rActive;
    data['rTeachingMethod'] = this.rTeachingMethod;
    data['rMastery'] = this.rMastery;
    data['rTimeManagement'] = this.rTimeManagement;
    return data;
  }

  @override
  String toString() {
    return 'AttendanceDetailModel{id: $id, idattendance: $idattendance, idtraining: $idtraining, '
        'signature_url: $signature_url, score: $score, feedback: $feedback, status: $status, '
        'creationTime: $creationTime, updatedTime: $updatedTime, name: $name, email: $email, '
        'photoURL: $photoURL, rank: $rank, license: $license, hub: $hub, rating: $rating, '
        'feedbackforinstructor: $feedbackforinstructor, formatNo: $formatNo, '
        'certificatemandatory: $certificatemandatory, grade: $grade, rCommunication: $rCommunication, '
        'rKnowledge: $rKnowledge, rActive: $rActive, rTeachingMethod: $rTeachingMethod, '
        'rMastery: $rMastery, rTimeManagement: $rTimeManagement}';
  }
}
