import 'package:json_annotation/json_annotation.dart';
import 'package:rentify_desktop/models/answer.dart';
import 'package:rentify_desktop/models/property.dart';
import 'package:rentify_desktop/models/user.dart';


part 'question.g.dart';

@JsonSerializable()
class Question {
  final int id;
  final User? user;
  final Property? property;
  final String content;
  final DateTime createdAt;
  final bool isAnswered;
  final Answer? answer;

  Question({
    required this.id,
    this.user,
    this.property,
    required this.content,
    required this.createdAt,
    required this.isAnswered,
    this.answer
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}