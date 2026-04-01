import 'package:json_annotation/json_annotation.dart';

part 'answer.g.dart';

@JsonSerializable()
class Answer {
  final int id;
  final int questionId;
  final int userId;
  final String? userName;
  final String content;
  final DateTime createdAt;

  Answer({
    required this.id,
    required this.questionId,
    required this.userId,
    this.userName,
    required this.content,
    required this.createdAt,
  });

  factory Answer.fromJson(Map<String, dynamic> json) =>
      _$AnswerFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerToJson(this);
}