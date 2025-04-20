import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/interview_model.dart';

class StorageService {
  static const String _interviewsKey = 'interviews';

  Future<void> saveInterviews(List<InterviewPrep> interviews) async {
    final prefs = await SharedPreferences.getInstance();
    final interviewsJson =
        interviews.map((interview) => interview.toJson()).toList();
    await prefs.setString(_interviewsKey, jsonEncode(interviewsJson));
  }

  Future<List<InterviewPrep>> loadInterviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interviewsString = prefs.getString(_interviewsKey);

      if (interviewsString == null) {
        return [];
      }

      final interviewsJson = jsonDecode(interviewsString) as List;
      return interviewsJson
          .map((json) => InterviewPrep.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading interviews: $e');
      return [];
    }
  }

  Future<void> clearInterviews() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_interviewsKey);
  }
}
