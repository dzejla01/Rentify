import 'package:flutter/widgets.dart';

class Fields {
  final Map<String, TextEditingController> _c;

  Fields._(this._c);

  factory Fields.fromNames(List<String> names) {
    assert(names.isNotEmpty, 'Names list ne smije biti prazna.');

    final unique = names.toSet();
    assert(unique.length == names.length, 'Imaš duplikat imena u listi.');

    return Fields._({
      for (final name in names) name: TextEditingController(),
    });
  }

  TextEditingController controller(String name) {
    final ctrl = _c[name];
    if (ctrl == null) throw ArgumentError('Ne postoji controller za "$name"');
    return ctrl;
  }

  String text(String name) => controller(name).text;

  void setText(String name, String value) => controller(name).text = value;

  Map<String, String> values() => _c.map((k, v) => MapEntry(k, v.text));

  Map<String, TextEditingController> get map => _c;

  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
  }
}
