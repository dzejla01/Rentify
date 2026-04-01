import 'package:rentify_mobile/models/question.dart';
import 'package:rentify_mobile/providers/base_provider.dart';

class QuestionProvider extends BaseProvider<Question> {
  QuestionProvider() : super("Question");

  @override
  Question fromJson(data) {
    return Question.fromJson(Map<String, dynamic>.from(data));
  }
}