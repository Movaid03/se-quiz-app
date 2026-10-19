import 'package:flutter/material.dart';
import 'text_screen.dart';
import 'topics.dart';
import 'model.dart';
import 'progress_store.dart';
import 'progress_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // load all topics from assets/questions.json
  late final Future<List<Topic>> _topicsFuture = loadTopics();
  // 0 = home, 1 = progress
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Topic>>(
      future: _topicsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Could not load topics.')),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildLayout(snapshot.data!);
      },
    );
  }

  Widget _buildLayout(List<Topic> topics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // checks screen width to adapt all devices
        final isWide = constraints.maxWidth >= 900;

        final content = _selectedIndex == 0
            ? _HomeContent(topics: topics)
            : ProgressScreen(topics: topics);
        final title =
            Text(_selectedIndex == 0 ? 'SE Quiz App' : 'Your Progress');

        if (!isWide) {
          // Mobile layout with a bottom navigation bar
          return Scaffold(
            appBar: AppBar(
              title: title,
              centerTitle: true,
            ),
            body: content,
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights),
                  label: 'Progress',
                ),
              ],
            ),
          );
        }

        // Desktop layout with NavigationRail so it works correctly on all devices (mobile, tablet, desktop)
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) =>
                    setState(() => _selectedIndex = i),
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.insights_outlined),
                    selectedIcon: Icon(Icons.insights),
                    label: Text('Progress'),
                  ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Scaffold(
                  appBar: AppBar(
                    title: title,
                    centerTitle: false,
                  ),
                  body: content,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// loads saved data such as best score and last opened topic.
// was made stateful to load data in initState and update when user finishes quiz and returns to home screen.
class _HomeContent extends StatefulWidget {
  final List<Topic> topics;

  const _HomeContent({required this.topics});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  // stores last topic user opened.
  String? lastTopicId;
  // stores best score for each topic.
  final Map<String, int> bestScores = {};
  // text typed in the search bar, used to filter topics.
  String query = '';

// loads saved best score for each topic.
  Future<void> _loadBestScores() async {
    final Map<String, int> temp = {};

    for (final t in widget.topics) {
      final best =
          await ProgressStore.getBestScore(t.id); // must exist in ProgressStore
      temp[t.id] = best;
    }

    if (!mounted) return;
    setState(() {
      bestScores
        ..clear()
        ..addAll(temp);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLast();
    _loadBestScores();
  }

  Future<void> _loadLast() async {
    final id = await ProgressStore.getLastTopicId();
    if (!mounted) return;
    setState(() => lastTopicId = id);
  }

  void _continue() {
    if (lastTopicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Open a topic first.')),
      );
      return;
    }

    final topic = widget.topics.firstWhere(
      (t) => t.id == lastTopicId,
      orElse: () => widget.topics.first,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TextScreen(topic: topic)),
    );
  }

  // starts a short quiz with questions from every topic, the same set for the whole day.
  Future<void> _startDailyQuiz() async {
    final questions = dailyQuestions(widget.topics, DateTime.now());
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
            topicId: dailyQuizId, topicTitle: 'Daily', questions: questions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // only show topics whose title or description match the search.
    final q = query.trim().toLowerCase();
    final topics = widget.topics
        .where((t) =>
            q.isEmpty ||
            t.title.toLowerCase().contains(q) ||
            t.desc.toLowerCase().contains(q))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.bolt,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back 👋',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pick a topic, read the notes, then take a quiz.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search bar
          TextField(
            onChanged: (value) => setState(() => query = value),
            decoration: InputDecoration(
              hintText: 'Search topics (e.g., Agile, SDLC, OOP)',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),

          const SizedBox(height: 16),

          // Quick actions (cards like a landing page)
          // same height for both cards so they line up.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ActionCard(
                    title: 'Continue',
                    subtitle: 'Resume your last topic',
                    icon: Icons.play_circle_outline,
                    onTap: _continue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    title: 'Daily Quiz',
                    subtitle: '5 mixed questions',
                    icon: Icons.flash_on_outlined,
                    onTap: _startDailyQuiz,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Choose a Topic',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          if (topics.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No topics match your search.',
                  textAlign: TextAlign.center),
            ),

          // Topic list (clean cards)
          ...topics.map((t) {
            final best = bestScores[t.id] ?? 0;
            final total = t.questions.length;

            return _TopicTile(
              title: t.title,
              description: t.desc,
              icon: t.icon,
              bestScore: best,
              totalQuestions: total,
              onTap: () async {
                await ProgressStore.setLastTopicId(t.id);
                if (!context.mounted) return;
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TextScreen(topic: t)),
                );
                await _loadLast();
                await _loadBestScores();
              },
            );
          }),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final int bestScore;
  final int totalQuestions;
  final VoidCallback onTap;

  const _TopicTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.bestScore,
    required this.totalQuestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$description\nBest: $bestScore / $totalQuestions'),
        isThreeLine: true,
        trailing: Text(
          '${totalQuestions == 0 ? 0 : ((bestScore / totalQuestions) * 100).round()}%',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: onTap,
      ),
    );
  }
}
