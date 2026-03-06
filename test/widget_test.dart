import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/main.dart';

void main() {
  testWidgets('Habit Tracker smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitTrackerApp());
    expect(find.text('Hábitos'), findsWidgets);
  });
}
