import 'package:flutter_test/flutter_test.dart';
import 'package:deprem_anlik/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DepremAnlikApp());
    expect(find.text('Deprem Erken Uyarı'), findsOneWidget);
  });
}
