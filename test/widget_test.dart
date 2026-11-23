import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmanagement_app/app/app.dart';
import 'package:taskmanagement_app/core/storage/preferences_service.dart';
import 'package:taskmanagement_app/core/utils/validators.dart';
import 'package:taskmanagement_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskmanagement_app/features/tasks/data/models/task_filter.dart';
import 'package:taskmanagement_app/features/tasks/data/models/task_model.dart';

void main() {
  group('Unit Tests', () {
    test('TaskModel JSON serialization test', () {
      final task = TaskModel(
        id: '123',
        title: 'Complete Project',
        description: 'Test Description',
        status: 'pending',
        priority: 'high',
        dueDate: DateTime(2026, 12, 31),
      );

      final json = task.toJson();
      expect(json['title'], 'Complete Project');
      expect(json['priority'], 'high');

      final fromJson = TaskModel.fromJson({
        '_id': '123',
        'title': 'Complete Project',
        'description': 'Test Description',
        'status': 'pending',
        'priority': 'high',
        'dueDate': '2026-12-31T00:00:00.000',
      });

      expect(fromJson.id, '123');
      expect(fromJson.title, 'Complete Project');
      expect(fromJson.dueDate?.year, 2026);
    });

    test('Input Validators test', () {
      expect(Validators.required(''), isNotNull);
      expect(Validators.required('Valid text'), isNull);

      expect(Validators.email('invalid-email'), isNotNull);
      expect(Validators.email('user@example.com'), isNull);

      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('password123'), isNull);

      expect(Validators.confirmPassword('abc', 'def'), isNotNull);
      expect(Validators.confirmPassword('pass', 'pass'), isNull);
    });

    test('TaskFilter query parameters test', () {
      const filter = TaskFilter(
        status: 'in-progress',
        priority: 'high',
        overdue: true,
        sort: 'dueDate',
        page: 2,
        limit: 10,
      );

      final params = filter.toQueryParams();
      expect(params['status'], 'in-progress');
      expect(params['priority'], 'high');
      expect(params['overdue'], 'true');
      expect(params['sort'], 'dueDate');
      expect(params['page'], 2);
      expect(params['limit'], 10);
    });
  });

  group('Widget Smoke Tests', () {
    testWidgets('App starts with Task Me splash', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await PreferencesService.init();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesServiceProvider.overrideWithValue(preferences),
          ],
          child: const TaskManagerApp(),
        ),
      );

      expect(find.text('Task Me'), findsWidgets);
      // Advance fake timer to clear pending Future.delayed
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
