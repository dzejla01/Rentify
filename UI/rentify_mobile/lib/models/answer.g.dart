// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Answer _$AnswerFromJson(Map<String, dynamic> json) => Answer(
  id: (json['id'] as num).toInt(),
  questionId: (json['questionId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  userName: json['userName'] as String?,
  content: json['content'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AnswerToJson(Answer instance) => <String, dynamic>{
  'id': instance.id,
  'questionId': instance.questionId,
  'userId': instance.userId,
  'userName': instance.userName,
  'content': instance.content,
  'createdAt': instance.createdAt.toIso8601String(),
};
