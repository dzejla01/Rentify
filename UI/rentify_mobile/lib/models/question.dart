import 'package:json_annotation/json_annotation.dart';
import 'package:rentify_mobile/models/property.dart';
import 'package:rentify_mobile/models/user.dart';

part 'question.g.dart';

@JsonSerializable()
class Question {
  final int id;
  final User? user;
  final Property? property;
  final String content;
  final DateTime createdAt;
  final bool isAnswered;

  Question({
    required this.id,
    this.user,
    this.property,
    required this.content,
    required this.createdAt,
    required this.isAnswered,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}