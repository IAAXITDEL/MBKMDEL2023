import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  String? id;
  int? idTrainingType;
  int? instructor;
  int? idPilotAdministrator;
  String? attendanceType;
  String? keyAttendance;
  String? room;
  String? signatureIccUrl;
  String? signaturePilotAdministratorUrl;
  String? status;
  String? subject;
  String? trainingType;
  Timestamp? date;
  Timestamp? valid_to;
  String? department;
  String? vanue;
  String? creationTime;
  String? updatedTime;
  String? name;
  String? photoURL;
  String? loano;
  String? expiry;

  AttendanceModel({
    this.id,
    this.idTrainingType,
    this.instructor,
    this.idPilotAdministrator,
    this.attendanceType,
    this.keyAttendance,
    this.room,
    this.signatureIccUrl,
    this.signaturePilotAdministratorUrl,
    this.status,
    this.subject,
    this.trainingType,
    this.date,
    this.valid_to,
    this.department,
    this.vanue,
    this.creationTime,
    this.updatedTime,
    this.name,
    this.photoURL,
    this.loano,
    this.expiry
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
        id: json['id'],
        idTrainingType: json['idTrainingType'],
        instructor: json['instructor'],
        idPilotAdministrator : json['idPilotAdministrator'],
        attendanceType: json['attendanceType'],
        keyAttendance: json['keyAttendance'],
        room: json['room'],
        signatureIccUrl: json['signatureIccUrl'],
        signaturePilotAdministratorUrl: json['signaturePilotAdministratorUrl'],
        status: json['status'],
        subject: json['subject'],
        trainingType: json['trainingType'],
        date: json['date'],
        valid_to: json['valid_to'],
        department: json['department'],
        vanue: json['vanue'],
        creationTime: json['creationTime'],
        updatedTime: json['updatedTime'],
        name: json['name'],
        photoURL: json['photoURL'],
        loano: json['loano'],
        expiry: json['expiry'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idTrainingType'] = this.idTrainingType;
    data['instructor'] = this.instructor;
    data['idPilotAdministrator'] = this.idPilotAdministrator;
    data['attendanceType'] = this.attendanceType;
    data['keyAttendance'] = this.keyAttendance;
    data['room'] = this.room;
    data['signatureIccUrl'] = this.signatureIccUrl;
    data['signaturePilotAdministratorUrl'] = this.signaturePilotAdministratorUrl;
    data['status'] = this.status;
    data['subject'] = this.subject;
    data['trainingType'] = this.trainingType;
    data['date'] = this.date;
    data['valid_to'] = this.valid_to;
    data['department'] = this.department;
    data['vanue'] = this.vanue;
    data['creationTime'] = this.creationTime;
    data['updatedTime'] =  this.updatedTime;
    data['name'] = this.name;
    data['photoURL'] = this.photoURL;
    data['loano'] = this.loano;
    data['expiry'] = this.expiry;
    return data;
  }
}
