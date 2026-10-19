import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import 'model.dart';
import 'progress_store.dart';

class TextScreen extends StatelessWidget {
  // topic object passed from home screen.
  // contains reading text and quiz questions.
  final Topic topic;

  const TextScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // allows the reading text to scroll if it's too long for the screen.
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  topic.reading,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            // button to start quiz, navigates to quiz screen.
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  // save topic as last opened.
                  // allows resume topic button to work.
                  await ProgressStore.setLastTopicId(topic.id);
                  if (!context.mounted) return;
                  Navigator.push(
                    // navigate to quiz screen.
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(
                        topicId: topic.id,
                        topicTitle: topic.title,
                        questions: topic.questions,
                      ),
                    ),
                  );
                },
                child: const Text('Start Quiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
