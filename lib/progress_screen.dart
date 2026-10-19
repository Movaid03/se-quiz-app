import 'package:flutter/material.dart';
import 'model.dart';
import 'progress_store.dart';

// shows the best score for every topic and an overall total.
class ProgressScreen extends StatefulWidget {
  final List<Topic> topics;

  const ProgressScreen({super.key, required this.topics});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // best score for each topic, null until loaded.
  Map<String, int>? bestScores;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final Map<String, int> temp = {};
    for (final t in widget.topics) {
      temp[t.id] = await ProgressStore.getBestScore(t.id);
    }
    if (!mounted) return;
    setState(() => bestScores = temp);
  }

  @override
  Widget build(BuildContext context) {
    final scores = bestScores;
    if (scores == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalQuestions =
        widget.topics.fold<int>(0, (sum, t) => sum + t.questions.length);
    final totalCorrect = scores.values.fold<int>(0, (sum, s) => sum + s);
    final completed = widget.topics
        .where((t) => (scores[t.id] ?? 0) == t.questions.length)
        .length;
    final overall = totalQuestions == 0 ? 0.0 : totalCorrect / totalQuestions;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // summary card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${(overall * 100).round()}% overall',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                  '$totalCorrect of $totalQuestions questions answered correctly · '
                  '$completed of ${widget.topics.length} topics mastered'),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: overall,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...widget.topics.map((t) {
          final best = scores[t.id] ?? 0;
          final total = t.questions.length;
          final value = total == 0 ? 0.0 : best / total;
          return Card(
            elevation: 0.5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(child: Icon(t.icon)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: value,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('$best / $total',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
