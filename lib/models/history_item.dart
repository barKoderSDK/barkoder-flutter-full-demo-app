class HistoryItem {
  final String text;
  final String type;
  final String? image;
  final int timestamp;
  final int count;

  HistoryItem({
    required this.text,
    required this.type,
    this.image,
    required this.timestamp,
    this.count = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type,
      'image': image,
      'timestamp': timestamp,
      'count': count,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      text: json['text'] as String,
      type: json['type'] as String,
      image: json['image'] as String?,
      timestamp: json['timestamp'] as int,
      count: json['count'] as int? ?? 1,
    );
  }

  HistoryItem copyWith({
    String? text,
    String? type,
    String? image,
    int? timestamp,
    int? count,
  }) {
    return HistoryItem(
      text: text ?? this.text,
      type: type ?? this.type,
      image: image ?? this.image,
      timestamp: timestamp ?? this.timestamp,
      count: count ?? this.count,
    );
  }
}
