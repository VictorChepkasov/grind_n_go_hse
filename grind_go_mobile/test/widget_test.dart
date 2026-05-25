import 'package:flutter_test/flutter_test.dart';
import 'package:grind_go_mobile/main.dart';

void main() {
  testWidgets('App renders title', (WidgetTester tester) async {
    await tester.pumpWidget(const GrindGoApp());
    expect(find.text('Grind&GO HSE'), findsOneWidget);
  });
}
