import 'package:flutter_test/flutter_test.dart';
import 'package:grind_go_mobile/app.dart';

void main() {
  testWidgets('Welcome screen renders title', (WidgetTester tester) async {
    await tester.pumpWidget(const GrindGoApp());
    expect(find.text('Grind&GO HSE'), findsOneWidget);
    expect(find.text('Войти'), findsOneWidget);
    expect(find.text('Регистрация'), findsOneWidget);
  });
}
