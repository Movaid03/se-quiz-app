import 'package:shared_preferences/shared_preferences.dart';

class ProgressStore {
  // class to handle storing and retrieving progress data using shared_preferences
  // key used to store the last opened topic.
  static const _lastTopicKey = 'lastTopicId';
// generates a unique key for stroing best score of a topic.
  static String _bestKey(String topicId) => 'bestScore_$topicId';

// saves the last opened topic.
  static Future<void> setLastTopicId(String topicId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastTopicKey, topicId);
  }

  static Future<String?> getLastTopicId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastTopicKey);
  }

// saves the best score for a topic if it's higher than the current best.
  static Future<void> saveBestScore(String topicId, int score) async {
    final prefs = await SharedPreferences.getInstance();
    // create a unique key for this topic's best score.
    final key = _bestKey(topicId);
    // get the current score = 0
    final current = prefs.getInt(key) ?? 0;
    // update score is higher than current score.
    if (score > current) {
      await prefs.setInt(key, score);
    }
  }

  static Future<int> getBestScore(String topicId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestKey(topicId)) ?? 0;
  }
}
