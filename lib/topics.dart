import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'model.dart';

// all topics and questions live in this file so new content can be added without changing code.
const topicsAsset = 'assets/questions.json';

// id used to save the daily quiz score, kept separate from the real topics.
const dailyQuizId = 'daily';

// turns the JSON text into a list of topics.
List<Topic> parseTopics(String source) {
  final data = jsonDecode(source) as Map<String, dynamic>;
  return (data['topics'] as List)
      .map((t) => Topic.fromJson(t as Map<String, dynamic>))
      .toList();
}

// loads the topics bundled with the app.
Future<List<Topic>> loadTopics() async {
  final source = await rootBundle.loadString(topicsAsset);
  return parseTopics(source);
}

// picks a set of questions from every topic for the daily quiz.
// the date is used as the random seed so everyone gets the same quiz on the same day.
List<Question> dailyQuestions(List<Topic> topics, DateTime date,
    {int count = 5}) {
  final all = [for (final t in topics) ...t.questions];
  final seed = date.year * 10000 + date.month * 100 + date.day;
  all.shuffle(Random(seed));
  return all.take(count).toList();
}
