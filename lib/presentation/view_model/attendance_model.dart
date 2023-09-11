class AttendanceModel {
  String? id;
  int? idTrainingType;
  int? instructor;
  String? attendanceType;
  String? keyAttendance;
  String? room;
  String? signatureIccUrl;
  String? status;
  String? subject;
  String? trainingType;
  String? date;
  String? department;
  String? vanue;
  String? creationTime;
  String? updatedTime;
  String? name;
  String? photoURL;

  AttendanceModel({
    this.id,
    this.idTrainingType,
    this.instructor,
    this.attendanceType,
    this.keyAttendance,
    this.room,
    this.signatureIccUrl,
    this.status,
    this.subject,
    this.trainingType,
    this.date,
    this.department,
    this.vanue,
    this.creationTime,
    this.updatedTime,
    this.name,
    this.photoURL
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
        id: json['id'],
        idTrainingType: json['idTrainingType'],
        instructor: json['instructor'],
        attendanceType: json['attendanceType'],
        keyAttendance: json['keyAttendance'],
        room: json['room'],
        signatureIccUrl: json['signature-icc-url'],
        status: json['status'],
        subject: json['subject'],
        trainingType: json['trainingType'],
        date: json['date'],
        department: json['department'],
        vanue: json['vanue'],
        creationTime: json['creationTime'],
        updatedTime: json['updatedTime'],
        name: json['name'],
        photoURL: json['photoURL']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idTrainingType'] = this.idTrainingType;
    data['instructor'] = this.instructor;
    data['attendanceType'] = this.attendanceType;
    data['keyAttendance'] = this.keyAttendance;
    data['room'] = this.room;
    data['signatureIccUrl'] = this.signatureIccUrl;
    data['status'] = this.status;
    data['subject'] = this.subject;
    data['trainingType'] = this.trainingType;
    data['date'] = this.date;
    data['department'] = this.department;
    data['vanue'] = this.vanue;
    data['creationTime'] = this.creationTime;
    data['updatedTime'] =  this.updatedTime;
    data['name'] = this.name;
    data['photoURL'] = this.photoURL;
    return data;
  }
}
