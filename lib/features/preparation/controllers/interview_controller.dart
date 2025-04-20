import 'package:flutter/foundation.dart';
import '../../../models/interview_model.dart';
import '../../../services/storage_service.dart';

class InterviewController extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<InterviewPrep> _interviews = [];
  InterviewPrep? _currentInterview;

  List<InterviewPrep> get interviews => _interviews;
  InterviewPrep? get currentInterview => _currentInterview;

  InterviewController() {
    _loadInterviews();
  }

  Future<void> _loadInterviews() async {
    _interviews = await _storageService.loadInterviews();
    notifyListeners();
  }

  Future<void> addInterview(InterviewPrep interview) async {
    _interviews.add(interview);
    await _storageService.saveInterviews(_interviews);
    notifyListeners();
  }

  void setCurrentInterview(InterviewPrep interview) {
    _currentInterview = interview;
    notifyListeners();
  }

  Future<void> updateResume(String newResume) async {
    if (_currentInterview != null) {
      final updatedInterview = InterviewPrep(
        scenario: _currentInterview!.scenario,
        jobDescription: _currentInterview!.jobDescription,
        resume: newResume,
      );

      final index = _interviews.indexOf(_currentInterview!);
      if (index != -1) {
        _interviews[index] = updatedInterview;
        _currentInterview = updatedInterview;
        await _storageService.saveInterviews(_interviews);
        notifyListeners();
      }
    }
  }

  Future<void> updateJobDescription(String newJobDescription) async {
    if (_currentInterview != null) {
      final updatedInterview = InterviewPrep(
        scenario: _currentInterview!.scenario,
        jobDescription: newJobDescription,
        resume: _currentInterview!.resume,
      );

      final index = _interviews.indexOf(_currentInterview!);
      if (index != -1) {
        _interviews[index] = updatedInterview;
        _currentInterview = updatedInterview;
        await _storageService.saveInterviews(_interviews);
        notifyListeners();
      }
    }
  }

  Future<void> clearCurrentInterview() async {
    _currentInterview = null;
    notifyListeners();
  }

  Future<void> clearAllInterviews() async {
    _interviews = [];
    _currentInterview = null;
    await _storageService.clearInterviews();
    notifyListeners();
  }

  Future<void> removeInterview(InterviewPrep interview) async {
    _interviews.remove(interview);
    if (_currentInterview == interview) {
      _currentInterview = null;
    }
    await _storageService.saveInterviews(_interviews);
    notifyListeners();
  }

  Future<void> updateInterview(
      InterviewPrep oldInterview, InterviewPrep newInterview) async {
    final index = _interviews.indexOf(oldInterview);
    if (index != -1) {
      _interviews[index] = newInterview;
      if (_currentInterview == oldInterview) {
        _currentInterview = newInterview;
      }
      await _storageService.saveInterviews(_interviews);
      notifyListeners();
    }
  }
}
