class CheckinRecord {
  final String id;
  final DateTime checkinTime;
  final double checkinLat;
  final double checkinLng;
  final String qrCodeValue;
  final String previousTopic;
  final String expectedTopic;
  final int moodBefore; // 1-5

  DateTime? finishTime;
  double? finishLat;
  double? finishLng;
  String? learnedToday;
  String? feedback;

  CheckinRecord({
    required this.id,
    required this.checkinTime,
    required this.checkinLat,
    required this.checkinLng,
    required this.qrCodeValue,
    required this.previousTopic,
    required this.expectedTopic,
    required this.moodBefore,
    this.finishTime,
    this.finishLat,
    this.finishLng,
    this.learnedToday,
    this.feedback,
  });

  bool get isCompleted => finishTime != null;

  String get moodEmoji {
    switch (moodBefore) {
      case 1:
        return '😡';
      case 2:
        return '🙁';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'checkin_time': checkinTime.toIso8601String(),
      'checkin_lat': checkinLat,
      'checkin_lng': checkinLng,
      'qr_code_value': qrCodeValue,
      'previous_topic': previousTopic,
      'expected_topic': expectedTopic,
      'mood_before': moodBefore,
      'finish_time': finishTime?.toIso8601String(),
      'finish_lat': finishLat,
      'finish_lng': finishLng,
      'learned_today': learnedToday,
      'feedback': feedback,
    };
  }

  factory CheckinRecord.fromMap(Map<String, dynamic> map) {
    return CheckinRecord(
      id: map['id'] as String,
      checkinTime: DateTime.parse(map['checkin_time'] as String),
      checkinLat: (map['checkin_lat'] as num).toDouble(),
      checkinLng: (map['checkin_lng'] as num).toDouble(),
      qrCodeValue: map['qr_code_value'] as String,
      previousTopic: map['previous_topic'] as String,
      expectedTopic: map['expected_topic'] as String,
      moodBefore: map['mood_before'] as int,
      finishTime: map['finish_time'] != null
          ? DateTime.parse(map['finish_time'] as String)
          : null,
      finishLat: map['finish_lat'] != null
          ? (map['finish_lat'] as num).toDouble()
          : null,
      finishLng: map['finish_lng'] != null
          ? (map['finish_lng'] as num).toDouble()
          : null,
      learnedToday: map['learned_today'] as String?,
      feedback: map['feedback'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'checkin_time': checkinTime.toIso8601String(),
      'checkin_lat': checkinLat,
      'checkin_lng': checkinLng,
      'qr_code_value': qrCodeValue,
      'previous_topic': previousTopic,
      'expected_topic': expectedTopic,
      'mood_before': moodBefore,
      'finish_time': finishTime?.toIso8601String(),
      'finish_lat': finishLat,
      'finish_lng': finishLng,
      'learned_today': learnedToday,
      'feedback': feedback,
    };
  }
}
