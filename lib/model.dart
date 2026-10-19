import 'package:flutter/material.dart';

// class for quiz question.
class Question {
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
// constructor used to create Question objects.
  const Question({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  // creates a Question from one entry in assets/questions.json.
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['text'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String,
    );
  }
}

// class for revision topic.
class Topic {
  final String id;
  final String title;
  final String desc;
  final IconData icon;
  final String reading;
  final List<Question> questions;
// constructor used to create Topic objects.
  const Topic({
    required this.id,
    required this.title,
    required this.desc,
    required this.icon,
    required this.reading,
    required this.questions,
  });

  // creates a Topic from one entry in assets/questions.json.
  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      title: json['title'] as String,
      desc: json['desc'] as String,
      icon: iconFor(json['icon'] as String?),
      reading: json['reading'] as String,
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  // icons can't be stored in JSON, so the file uses a name and this maps it to an icon.
  static const Map<String, IconData> icons = {
    'school': Icons.school,
    'compare': Icons.compare_arrows,
    'cube': Icons.view_in_ar,
    'checklist': Icons.checklist,
    'bug': Icons.bug_report_outlined,
    'puzzle': Icons.extension_outlined,
    'branch': Icons.call_split,
    'diagram': Icons.account_tree_outlined,
  };

  static IconData iconFor(String? name) => icons[name] ?? Icons.menu_book;
}
