import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartCheckinApp());
    expect(find.text('Smart Class Check-in'), findsOneWidget);
  });
}
