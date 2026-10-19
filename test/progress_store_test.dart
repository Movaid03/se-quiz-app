import 'package:flutter_test/flutter_test.dart';
import 'package:se_quiz_app/progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('best score starts at zero', () async {
    expect(await ProgressStore.getBestScore('OOP'), 0);
  });

  test('best score only goes up', () async {
    await ProgressStore.saveBestScore('OOP', 5);
    await ProgressStore.saveBestScore('OOP', 3);
    expect(await ProgressStore.getBestScore('OOP'), 5);

    await ProgressStore.saveBestScore('OOP', 7);
    expect(await ProgressStore.getBestScore('OOP'), 7);
  });

  test('scores are stored per topic', () async {
    await ProgressStore.saveBestScore('OOP', 4);
    expect(await ProgressStore.getBestScore('UML'), 0);
  });

  test('remembers the last opened topic', () async {
    expect(await ProgressStore.getLastTopicId(), isNull);
    await ProgressStore.setLastTopicId('Testing');
    expect(await ProgressStore.getLastTopicId(), 'Testing');
  });
}
