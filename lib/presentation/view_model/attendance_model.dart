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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['creationTime'] = creationTime;
    data['date'] = date;
    data['idTrainingType'] = idTrainingType;
    data['instructor'] = instructor;
    data['keyAttendance'] = keyAttendance;
    data['status'] = status;
    data['subject'] = subject;
    data['updatedTime'] = updatedTime;
    data['vanue'] = vanue;
    data['name'] = name;
    data['photoURL'] = photoURL;
    return data;
  }
}
