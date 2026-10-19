import 'package:flutter/material.dart';
import 'model.dart';
import 'progress_store.dart';

class QuizScreen extends StatefulWidget {
  final String topicId;
  final String topicTitle;
  final List<Question> questions;

  const QuizScreen(
      {super.key,
      required this.topicId,
      required this.topicTitle,
      required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int current = 0;
  // track current question number
  // store the score
  int score = 0;
  // store the answer the user selected.
  int? selectedIndex;
  // stops users from changing answer after they have selected one.
  bool answered = false;

// called when the user selects an answer.
  void _selectAnswer(int index) {
    if (answered) return;
// get the correct answer for the current question
    final correct = widget.questions[current].correctIndex;

    setState(() {
      selectedIndex = index;
      answered = true;
      // increase score if the user selected the correct answer
      if (index == correct) score++;
    });
  }

// move to next question or finish quiz.
  void _next() {
    // user not allowed to continue without answering.
    if (!answered) return;

    if (current < widget.questions.length - 1) {
      // move to next question and reset answer state.
      setState(() {
        current++;
        selectedIndex = null;
        answered = false;
      });
    } else {
      _finishQuiz();
    }
  }

// called when the user finishes the quiz.
  Future<void> _finishQuiz() async {
    await ProgressStore.saveBestScore(widget.topicId, score);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quiz Complete'),
        content: Text('You scored $score / ${widget.questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to reading
            },
            child: const Text('Back'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              // reset quiz state to allow retrying.
              setState(() {
                current = 0;
                score = 0;
                selectedIndex = null;
                answered = false;
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // current question
    final q = widget.questions[current];
    final correct = q.correctIndex;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.topicTitle} Quiz'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${current + 1} of ${widget.questions.length}  |  Score: $score',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            // shows how far through the quiz the user is.
            LinearProgressIndicator(
              value: (current + (answered ? 1 : 0)) / widget.questions.length,
              minHeight: 6,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 12),

            // scrolls so long questions and explanations fit on small screens.
            Expanded(
              child: ListView(
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        q.text,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(q.options.length, (i) {
                    Color? bg;
                    Color? fg;
// if the question has been answered, show green background for correct answer and red for wrong answer.
                    if (answered) {
                      if (i == correct) {
                        bg = Colors.green.shade600;
                        fg = Colors.white;
                      } else if (i == selectedIndex) {
                        bg = Colors.red.shade600;
                        fg = Colors.white;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        onPressed: answered ? null : () => _selectAnswer(i),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12),
                          // buttons are disabled once answered, so the colours must be set on the disabled state.
                          disabledBackgroundColor: bg,
                          disabledForegroundColor: fg,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(q.options[i]),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  if (answered)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (selectedIndex == correct)
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        q.explanation,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: answered ? _next : null,
                child: Text(
                    current < widget.questions.length - 1 ? 'Next' : 'Finish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
