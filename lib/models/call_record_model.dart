enum CallType {
  incoming,
  outgoing,
  missed,
  rejected,
  completed,
}

class CallRecord {
  final String id;
  final String creatorId;
  final String name;
  final int age;
  final String photoUrl;
  final CallType type;
  final DateTime timestamp;
  final int durationSeconds;
  final int coinsUsed;
  final bool isOnline;
  final bool isAvailableForCall;

  const CallRecord({
    required this.id,
    required this.creatorId,
    required this.name,
    this.age = 23,
    required this.photoUrl,
    required this.type,
    required this.timestamp,
    this.durationSeconds = 0,
    this.coinsUsed = 500,
    this.isOnline = true,
    this.isAvailableForCall = true,
  });

  String get durationText {
    if (durationSeconds <= 0) return '0s';
    final mins = durationSeconds ~/ 60;
    final secs = durationSeconds % 60;
    if (mins > 0) {
      return '${mins}m ${secs}s';
    }
    return '${secs}s';
  }

  String get timeFormatted {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
