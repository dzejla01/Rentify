import 'package:flutter_test/flutter_test.dart';
import 'package:rentify_desktop/main.dart';

void main() {
  testWidgets('Rentify desktop app smoke test', (WidgetTester tester) async {
    expect(const RentifyApp(), isA<RentifyApp>());
  });
}
