import 'package:flutter_test/flutter_test.dart';
import 'package:baggage/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const BaggageEstimatorApp());
    expect(find.text('Baggy · Baggage Fee Estimator'), findsOneWidget);
  });
}
