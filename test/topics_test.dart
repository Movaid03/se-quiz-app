import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:se_quiz_app/model.dart';
import 'package:se_quiz_app/topics.dart';

void main() {
  final topics = parseTopics(File(topicsAsset).readAsStringSync());

  test('question bank has every topic', () {
    expect(topics.length, 8);
    expect(topics.map((t) => t.id).toSet().length, topics.length,
        reason: 'topic ids must be unique');
  });

  test('every question is valid', () {
    for (final t in topics) {
      expect(t.questions.length, greaterThanOrEqualTo(5), reason: t.id);
      for (final q in t.questions) {
        expect(q.options.length, greaterThanOrEqualTo(2), reason: q.text);
        expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1),
            reason: q.text);
        expect(q.explanation, isNotEmpty, reason: q.text);
      }
    }
  });

  test('unknown icon names fall back to a default icon', () {
    expect(Topic.iconFor('school'), Icons.school);
    expect(Topic.iconFor('missing'), Icons.menu_book);
  });

  test('daily quiz is the same all day and changes the next day', () {
    final morning = dailyQuestions(topics, DateTime(2026, 10, 19, 8));
    final evening = dailyQuestions(topics, DateTime(2026, 10, 19, 22));
    final nextDay = dailyQuestions(topics, DateTime(2026, 10, 20));

    expect(morning.length, 5);
    expect(morning.toSet().length, 5, reason: 'no repeated questions');
    expect(evening, morning);
    expect(nextDay, isNot(morning));
  });
}
