class City {
  final int id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) => City(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
