import 'package:flutter_test/flutter_test.dart';
import 'package:rentify_mobile/main.dart';

void main() {
  testWidgets('Rentify app smoke test', (WidgetTester tester) async {
    expect(const RentifyApp(), isA<RentifyApp>());
  });
}
