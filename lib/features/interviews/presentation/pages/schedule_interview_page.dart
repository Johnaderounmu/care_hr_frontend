import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';

class ScheduleInterviewPage extends StatefulWidget {
  const ScheduleInterviewPage({super.key});

  @override
  State<ScheduleInterviewPage> createState() => _ScheduleInterviewPageState();
}

class _ScheduleInterviewPageState extends State<ScheduleInterviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _candidateController = TextEditingController();
  final _positionController = TextEditingController();
  final _interviewerController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _interviewType = 'In-Person';
  String _interviewLevel = 'Initial Screening';

  final List<String> _interviewTypes = [
    'In-Person',
    'Video Call',
    'Phone Call',
  ];

  final List<String> _interviewLevels = [
    'Initial Screening',
    'Technical Interview',
    'HR Interview',
    'Final Interview',
  ];

  @override
  void dispose() {
    _candidateController.dispose();
    _positionController.dispose();
    _interviewerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _scheduleInterview() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      // In a real app, this would save to a database or call an API
      
      // Send a notification about the scheduled interview
      try {
        await NotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch,
          title: 'Interview Scheduled',
          body: 'Interview with ${_candidateController.text} scheduled for ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} at ${_selectedTime!.format(context)}',
        );
      } catch (e) {
        print('Notification error: $e');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Interview scheduled successfully! Check your notifications.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Interview'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Interview Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Candidate Name
              TextFormField(
                controller: _candidateController,
                decoration: const InputDecoration(
                  labelText: 'Candidate Name',
                  hintText: 'Enter candidate name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter candidate name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Position
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  hintText: 'Enter position title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter position';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Interviewer
              TextFormField(
                controller: _interviewerController,
                decoration: const InputDecoration(
                  labelText: 'Interviewer',
                  hintText: 'Enter interviewer name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter interviewer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Interview Type
              DropdownButtonFormField<String>(
                value: _interviewType,
                decoration: const InputDecoration(
                  labelText: 'Interview Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.video_call),
                ),
                items: _interviewTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _interviewType = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Interview Level
              DropdownButtonFormField<String>(
                value: _interviewLevel,
                decoration: const InputDecoration(
                  labelText: 'Interview Level',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.stairs),
                ),
                items: _interviewLevels.map((String level) {
                  return DropdownMenuItem<String>(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _interviewLevel = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Date Selection
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Interview Date',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    errorText: _selectedDate == null ? 'Please select a date' : null,
                  ),
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select Date',
                    style: TextStyle(
                      color: _selectedDate != null ? null : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time Selection
              InkWell(
                onTap: _selectTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Interview Time',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.access_time),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    errorText: _selectedTime == null ? 'Please select a time' : null,
                  ),
                  child: Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Select Time',
                    style: TextStyle(
                      color: _selectedTime != null ? null : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Additional notes about the interview',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _scheduleInterview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Schedule Interview'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}