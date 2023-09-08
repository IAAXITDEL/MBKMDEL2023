class AttendanceModel {
  String? id;
  String? creationTime;
  String? date;
  int? idTrainingType;
  int? instructor;
  String? keyAttendance;
  String? status;
  String? subject;
  String? updatedTime;
  String? vanue;
  String? name;
  String? photoURL;

  AttendanceModel({
    this.id,
    this.creationTime,
    this.date,
    this.idTrainingType,
    this.instructor,
    this.keyAttendance,
    this.status,
    this.subject,
    this.updatedTime,
    this.vanue,
    this.name,
    this.photoURL
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      creationTime: json['creationTime'],
      date: json['date'],
      idTrainingType: json['idTrainingType'],
      instructor: json['instructor'],
      keyAttendance: json['keyAttendance'],
      status: json['status'],
      subject: json['subject'],
      updatedTime: json['updatedTime'],
        vanue: json['vanue'],
      name: json['name'],
        photoURL: json['photoURL']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['creationTime'] = this.creationTime;
    data['date'] = this.date;
    data['idTrainingType'] = this.idTrainingType;
    data['instructor'] = this.instructor;
    data['keyAttendance'] = this.keyAttendance;
    data['status'] = this.status;
    data['subject'] = this.subject;
    data['updatedTime'] = this.updatedTime;
    data['vanue'] = this.vanue;
    data['name'] = this.name;
    data['photoURL'] = this.photoURL;
    return data;
  }
}
