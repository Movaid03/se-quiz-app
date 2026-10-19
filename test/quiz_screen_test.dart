import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:se_quiz_app/model.dart';
import 'package:se_quiz_app/progress_store.dart';
import 'package:se_quiz_app/quiz_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const questions = [
  Question(
      text: 'Q1',
      options: ['A', 'B'],
      correctIndex: 0,
      explanation: 'A is right.'),
  Question(
      text: 'Q2',
      options: ['C', 'D'],
      correctIndex: 1,
      explanation: 'D is right.'),
];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> openQuiz(WidgetTester tester) {
    return tester.pumpWidget(const MaterialApp(
      home:
          QuizScreen(topicId: 'test', topicTitle: 'Test', questions: questions),
    ));
  }

  testWidgets('correct answer raises the score and shows the explanation',
      (tester) async {
    await openQuiz(tester);
    expect(find.textContaining('Score: 0'), findsOneWidget);

    await tester.tap(find.text('A'));
    await tester.pump();

    expect(find.textContaining('Score: 1'), findsOneWidget);
    expect(find.text('A is right.'), findsOneWidget);
  });

  testWidgets('answers turn green and red after answering', (tester) async {
    await openQuiz(tester);
    await tester.tap(find.text('B'));
    await tester.pump();

    Color? colourOf(String option) {
      final button = tester.widget<ElevatedButton>(
        find.ancestor(
            of: find.text(option), matching: find.byType(ElevatedButton)),
      );
      return button.style?.backgroundColor?.resolve({WidgetState.disabled});
    }

    expect(colourOf('A'), Colors.green.shade600);
    expect(colourOf('B'), Colors.red.shade600);
  });

  testWidgets('wrong answer keeps the score the same', (tester) async {
    await openQuiz(tester);
    await tester.tap(find.text('B'));
    await tester.pump();

    expect(find.textContaining('Score: 0'), findsOneWidget);
  });

  testWidgets('Next is disabled until a question is answered', (tester) async {
    await openQuiz(tester);
    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Q1'), findsOneWidget);
  });

  testWidgets('finishing the quiz shows the result and saves the best score',
      (tester) async {
    await openQuiz(tester);

    await tester.tap(find.text('A'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.tap(find.text('D'));
    await tester.pump();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.text('You scored 2 / 2'), findsOneWidget);
    expect(await ProgressStore.getBestScore('test'), 2);
  });

  testWidgets('retry resets the quiz', (tester) async {
    await openQuiz(tester);

    await tester.tap(find.text('A'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.tap(find.text('C'));
    await tester.pump();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Q1'), findsOneWidget);
    expect(find.textContaining('Score: 0'), findsOneWidget);
  });
}
