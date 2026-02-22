
import 'package:rentify_mobile/validation/validation_model/validation_field_rule.dart';

class ValidationEngine {
  static bool validate(
    List<FieldRule> rules,
    void Function(String field, String message) onError,
  ) {
    bool isValid = true;

    for (final rule in rules) {
      final error = rule.validate();
      if (error != null) {
        isValid = false;
        onError(rule.field, error);
      }
    }

    return isValid;
  }
}
