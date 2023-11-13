class TrainingTypeModel {
  int? id;
  String? training;
  String? training_description;
  String? recurrent;
  int? is_delete;

  TrainingTypeModel({
    this.id,
    this.training,
    this.training_description,
    this.recurrent,
    this.is_delete
  });

  factory TrainingTypeModel.fromJson(Map<String, dynamic> json) {
    return TrainingTypeModel(
        id: json['id'],
        training: json['training'],
        training_description: json['training_description'],
        recurrent:  json['recurrent'],
        is_delete: json['is_delete']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['training'] = this.training;
    data['training_description'] = this.training_description;
    data['recurrent'] = this.recurrent;
    data['is_delete'] = this.is_delete;
    return data;
  }
}
