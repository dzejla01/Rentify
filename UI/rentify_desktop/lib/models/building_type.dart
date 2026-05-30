class BuildingType {
  final int id;
  final String name;

  BuildingType({required this.id, required this.name});

  factory BuildingType.fromJson(Map<String, dynamic> json) => BuildingType(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
