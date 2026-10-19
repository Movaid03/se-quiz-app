import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:se_quiz_app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // clear the asset cache so every test loads the topics fresh.
    rootBundle.clear();
  });

  Future<void> login(
    WidgetTester tester,
    String email,
    String password,
  ) async {
    await tester.enterText(find.widgetWithText(TextField, 'Email'), email);
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      password,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pumpAndSettle();
  }

  // logs in and waits for the topics to finish loading from the asset file.
  Future<void> loginAndWaitForTopics(WidgetTester tester) async {
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'hello@demo.com',
    );
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    for (var i = 0;
        i < 50 && find.text('Choose a Topic').evaluate().isEmpty;
        i++) {
      await tester
          .runAsync(() => Future.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  testWidgets('login rejects an invalid email', (tester) async {
    await tester.pumpWidget(const MyApp());
    await login(tester, 'not-an-email', '123456');

    expect(find.text('Please enter a valid email'), findsOneWidget);
    expect(find.text('Choose a Topic'), findsNothing);
  });

  testWidgets('login opens the home screen with all topics', (tester) async {
    await tester.pumpWidget(const MyApp());
    await loginAndWaitForTopics(tester);

    expect(find.text('Choose a Topic'), findsOneWidget);
    expect(find.text('Software Engineering Basics'), findsOneWidget);
  });

  testWidgets('search filters the topic list', (tester) async {
    await tester.pumpWidget(const MyApp());
    await loginAndWaitForTopics(tester);

    await tester.enterText(find.byType(TextField), 'agile');
    await tester.pumpAndSettle();
    expect(find.text('Agile vs Waterfall'), findsOneWidget);
    expect(find.text('Software Engineering Basics'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No topics match your search.'), findsOneWidget);
  });

  testWidgets('progress tab shows scores for every topic', (tester) async {
    await tester.pumpWidget(const MyApp());
    await loginAndWaitForTopics(tester);

    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();
    expect(find.text('0% overall'), findsOneWidget);
    expect(find.text('0 / 8'), findsWidgets);
  });
}
