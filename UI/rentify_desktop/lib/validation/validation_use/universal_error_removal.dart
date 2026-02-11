import 'package:flutter/material.dart';


class ErrorAutoRemoval {

  static void removeErrorOnTextField({
    required String field,
    required Map<String, String?> fieldErrors,
    required TextEditingController controller,
    VoidCallback? onChangedCallback,
    required VoidCallback setState,
  }) {
    controller.addListener(() {
      if (fieldErrors[field] != null) {
        fieldErrors.remove(field);
        setState();
      }
      if (onChangedCallback != null) onChangedCallback();
    });
  }

  static void removeErrorOnListField<T>({
    required String field,
    required Map<String, String?> fieldErrors,
    required List<T> list,
    required VoidCallback setState,
    VoidCallback? onChangedCallback,
  }) {
    if (list.isNotEmpty && fieldErrors[field] != null) {
      fieldErrors.remove(field);
      setState();
    }
    if (onChangedCallback != null) onChangedCallback();
  }
}
