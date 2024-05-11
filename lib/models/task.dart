class Task {
  String content;
  DateTime timestamp;
  bool done;

  Task({required this.content, required this.timestamp, required this.done});

  factory Task.fromMap(Map tas) {
    return Task(
        content: tas['content'],
        timestamp: tas['timestamp'],
        done: tas['done']);
  }

  Map toMap() {
    return {'content': content, 'timestamp': timestamp, 'done': done};
  }
}
