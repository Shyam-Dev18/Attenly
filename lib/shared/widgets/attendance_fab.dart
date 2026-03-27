import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AttendanceFab extends StatelessWidget {
  final VoidCallback onPressed;
  const AttendanceFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: kPrimary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.done_all),
      label: const Text('Mark All Present'),
    );
  }
}
