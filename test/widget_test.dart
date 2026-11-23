import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmanagement_app/main.dart';

void main() {
  testWidgets('Task App initial load smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    expect(find.text('Task Manager'), findsWidgets);
    await tester.pumpAndSettle();
  });
}
