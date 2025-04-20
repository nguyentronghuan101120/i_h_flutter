import 'package:json_annotation/json_annotation.dart';

part 'qa_pair.g.dart';

@JsonSerializable()
class QAPair {
  final String question;
  final String answer;
  final DateTime timestamp;

  QAPair({
    required this.question,
    required this.answer,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory QAPair.fromJson(Map<String, dynamic> json) => _$QAPairFromJson(json);
  Map<String, dynamic> toJson() => _$QAPairToJson(this);
}
