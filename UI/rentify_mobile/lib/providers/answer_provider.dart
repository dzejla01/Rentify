import 'package:rentify_mobile/models/answer.dart';
import 'package:rentify_mobile/providers/base_provider.dart';

class AnswerProvider extends BaseProvider<Answer> {
  AnswerProvider() : super("Answer");

  @override
  Answer fromJson(data) {
    return Answer.fromJson(Map<String, dynamic>.from(data));
  }
}