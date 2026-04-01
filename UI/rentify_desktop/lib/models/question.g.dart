// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
  id: (json['id'] as num).toInt(),
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  property: json['property'] == null
      ? null
      : Property.fromJson(json['property'] as Map<String, dynamic>),
  content: json['content'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isAnswered: json['isAnswered'] as bool,
);

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  'id': instance.id,
  'user': instance.user,
  'property': instance.property,
  'content': instance.content,
  'createdAt': instance.createdAt.toIso8601String(),
  'isAnswered': instance.isAnswered,
};
