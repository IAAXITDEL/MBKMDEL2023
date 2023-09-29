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
    this.hub
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
        hub: json['hub']
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
    return data;
  }
}
