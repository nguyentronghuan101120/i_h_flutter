// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interview_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InterviewPrep _$InterviewPrepFromJson(Map<String, dynamic> json) =>
    InterviewPrep(
      scenario: json['scenario'] as String,
      jobDescription: json['jobDescription'] as String,
      resume: json['resume'] as String,
    );

Map<String, dynamic> _$InterviewPrepToJson(InterviewPrep instance) =>
    <String, dynamic>{
      'scenario': instance.scenario,
      'jobDescription': instance.jobDescription,
      'resume': instance.resume,
    };
