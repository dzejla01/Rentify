class FieldRule {
  final String field;
  final String? Function() validate;

  FieldRule(this.field, this.validate);
}
