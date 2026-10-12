import 'package:flutter_test/flutter_test.dart';
import 'package:fitstart/main.dart';

void main() {
  testWidgets('FitPulse app initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FitPulseApp());
    expect(find.byType(FitPulseApp), findsOneWidget);
  });
}
