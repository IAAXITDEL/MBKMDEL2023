class AttendanceDetailModel {
  String? id;
  String? idattendance;
  int? idpilot;
  String? signature_url;
  String? score;
  String? feedback;
  String? creationTime;
  String? updatedTime;
  String? name;
  String? email;
  String? photoURL;
  String? rank;
  String? license;


  AttendanceDetailModel({
    this.id,
    this.idattendance,
    this.idpilot,
    this.signature_url,
    this.score,
    this.feedback,
    this.creationTime,
    this.updatedTime,
    this.name,
    this.email,
    this.photoURL,
    this.rank,
    this.license
  });

  factory AttendanceDetailModel.fromJson(Map<String, dynamic> json) {
    return AttendanceDetailModel(
        id: json['id'],
        idattendance: json['idattendance'],
        idpilot: json['idpilot'],
        signature_url : json['signature_url'],
        score: json['score'],
        feedback: json['feedback'],
        creationTime: json['creationTime'],
        updatedTime: json['updatedTime'],
        name: json['name'],
        email: json['email'],
        photoURL: json['photoURL'],
        rank: json['rank'],
        license: json['license']

    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idattendance'] = this.idattendance;
    data['idpilot'] = this.idpilot;
    data['signature_url'] = this.signature_url;
    data['score'] = this.score;
    data['feedback'] = this.feedback;
    data['creationTime'] = this.creationTime;
    data['updatedTime'] =  this.updatedTime;
    data['name'] = this.name;
    data['email'] = this.email;
    data['photoURL'] = this.photoURL;
    data['rank'] = this.rank;
    data['license'] = this.license;
    return data;
  }
}
