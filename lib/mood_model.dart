
class MoodModel{
  final int id;
  final int scale;
  final String description;
  final String createdOn;

  MoodModel({
    required this.id,
    required this.scale,
    required this.description,
    required this.createdOn,
});

  factory MoodModel.fromJson(Map<String, dynamic>data) => MoodModel(
    id: data['id'],
    scale: data['scale'],
    description: data['description'],
    createdOn: data['createdOn'],
  );

  Map<String,dynamic> toMap() => {
    'id':id,
    'scale': scale,
    'description': description,
    'createdOn': createdOn,
  };
}