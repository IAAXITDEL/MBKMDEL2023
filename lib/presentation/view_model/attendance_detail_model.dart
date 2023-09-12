class AttendanceDetailModel {
  String? id;
  String? idattendance;
  int? idpilot;
  String? signature_url;
  String? creationTime;
  String? updatedTime;
  String? name;
  String? photoURL;
  String? rank;
  String? license;


  AttendanceDetailModel({
    this.id,
    this.idattendance,
    this.idpilot,
    this.signature_url,
    this.creationTime,
    this.updatedTime,
    this.name,
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
        creationTime: json['creationTime'],
        updatedTime: json['updatedTime'],
        name: json['name'],
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
    data['creationTime'] = this.creationTime;
    data['updatedTime'] =  this.updatedTime;
    data['name'] = this.name;
    data['photoURL'] = this.photoURL;
    data['rank'] = this.rank;
    data['license'] = this.license;
    return data;
  }
}
