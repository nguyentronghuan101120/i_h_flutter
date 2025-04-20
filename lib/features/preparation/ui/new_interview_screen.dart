import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/interview_controller.dart';
import '../../../models/interview_model.dart';

class NewInterviewScreen extends StatefulWidget {
  const NewInterviewScreen({super.key});

  @override
  State<NewInterviewScreen> createState() => _NewInterviewScreenState();
}

class _NewInterviewScreenState extends State<NewInterviewScreen> {
  final _formKey = GlobalKey<FormState>();
  String _scenario = '';
  String _jobDescription = '';
  String _resume = '';

  @override
  void initState() {
    super.initState();
    final currentInterview =
        context.read<InterviewController>().currentInterview;
    if (currentInterview != null) {
      _scenario = currentInterview.scenario;
      _jobDescription = currentInterview.jobDescription;
      _resume = currentInterview.resume;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing =
        context.watch<InterviewController>().currentInterview != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Interview' : 'New Interview'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            DropdownButtonFormField<String>(
              value: _scenario.isEmpty ? null : _scenario,
              decoration: const InputDecoration(
                labelText: 'Choose Scenario',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Software Engineering',
                  child: Text('Software Engineering'),
                ),
                DropdownMenuItem(
                  value: 'Product Management',
                  child: Text('Product Management'),
                ),
                DropdownMenuItem(
                  value: 'Data Science',
                  child: Text('Data Science'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _scenario = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a scenario';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _jobDescription,
              decoration: const InputDecoration(
                labelText: 'Job Description',
                border: OutlineInputBorder(),
                hintText: 'Enter the job description...',
              ),
              maxLines: 5,
              onSaved: (value) {
                _jobDescription = value ?? '';
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter job description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _resume,
              decoration: const InputDecoration(
                labelText: 'Your Resume',
                border: OutlineInputBorder(),
                hintText: 'Paste your resume content here...',
              ),
              maxLines: 20,
              onSaved: (value) {
                _resume = value ?? '';
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your resume content';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(isEditing ? 'Update Interview' : 'Create Interview'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final interview = InterviewPrep(
        scenario: _scenario,
        jobDescription: _jobDescription,
        resume: _resume,
      );

      try {
        final controller = context.read<InterviewController>();
        final currentInterview = controller.currentInterview;

        if (currentInterview != null) {
          await controller.updateInterview(currentInterview, interview);
        } else {
          await controller.addInterview(interview);
        }

        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving interview: $e')),
        );
      }
    }
  }
}
