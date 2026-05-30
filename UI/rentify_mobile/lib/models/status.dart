class Status {
  final int id;
  final String name;

  Status({required this.id, required this.name});

  factory Status.fromJson(Map<String, dynamic> json) => Status(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
