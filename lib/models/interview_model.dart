import 'package:json_annotation/json_annotation.dart';

part 'interview_model.g.dart';

@JsonSerializable()
class InterviewPrep {
  final String scenario;
  final String jobDescription;
  final String resume;

  InterviewPrep({
    required this.scenario,
    required this.jobDescription,
    required this.resume,
  });

  factory InterviewPrep.fromJson(Map<String, dynamic> json) =>
      _$InterviewPrepFromJson(json);
  Map<String, dynamic> toJson() => _$InterviewPrepToJson(this);
}
