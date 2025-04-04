import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import 'package:intl/intl.dart';

class CreateEventDialog extends StatefulWidget {
  final String communityId;
  final Function(String title, String description, String location, DateTime dateTime, int maxParticipants) onSubmit;

  const CreateEventDialog({
    Key? key,
    required this.communityId,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _CreateEventDialogState createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxParticipantsController = TextEditingController(text: '5'); // Default value

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Combine date and time
      final DateTime eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      widget.onSubmit(
        _titleController.text,
        _descriptionController.text,
        _locationController.text,
        eventDateTime,
        int.parse(_maxParticipantsController.text),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Format the selected date
    final dateFormatter = DateFormat('EEEE, MMM d, yyyy');
    final formattedDate = dateFormatter.format(_selectedDate);

    // Format the selected time
    final formattedTime = _selectedTime.format(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: isDark ? ThemeConstants.backgroundDark : Colors.white,
      child: ContentContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeConstants.accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_note,
                    color: ThemeConstants.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Create New Event',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeConstants.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Event Title',
                        hintText: 'e.g. Weekly Meetup',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Event Location
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'e.g. Central Park',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date and Time Selection
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(formattedDate),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Time',
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              child: Text(formattedTime),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Max Participants
                    TextFormField(
                      controller: _maxParticipantsController,
                      decoration: const InputDecoration(
                        labelText: 'Max Participants',
                        hintText: 'e.g. 10',
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter max participants';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number < 1) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Add details about your event',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeConstants.accentColor,
                            foregroundColor: ThemeConstants.primaryColor,
                          ),
                          child: const Text('Create Event'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContentContainer extends StatelessWidget {
  final Widget child;

  const ContentContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
