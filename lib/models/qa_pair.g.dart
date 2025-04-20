// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qa_pair.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QAPair _$QAPairFromJson(Map<String, dynamic> json) => QAPair(
      question: json['question'] as String,
      answer: json['answer'] as String,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$QAPairToJson(QAPair instance) => <String, dynamic>{
      'question': instance.question,
      'answer': instance.answer,
      'timestamp': instance.timestamp.toIso8601String(),
    };
