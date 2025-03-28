import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ticktick_random_picker/models/task.dart';
import 'package:ticktick_random_picker/services/ticktick_service.dart';

class RandomTaskDialog extends StatelessWidget {
  final Task task;
  
  const RandomTaskDialog({
    Key? key,
    required this.task,
  }) : super(key: key);
  
  String _formatDueDate(DateTime? dueDate) {
    if (dueDate == null) return 'No due date';
    return DateFormat('MMM d, yyyy').format(dueDate);
  }
  
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'None';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Your Random Task',
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (task.content != null && task.content!.isNotEmpty) ...[
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(task.content!),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text(
                  _formatDueDate(task.dueDate),
                  style: TextStyle(
                    color: task.dueDate != null && task.dueDate!.isBefore(DateTime.now())
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.flag,
                  size: 16,
                  color: _getPriorityColor(task.priority),
                ),
                const SizedBox(width: 4),
                Text('Priority: ${_getPriorityText(task.priority)}'),
              ],
            ),
            if (task.tags != null && task.tags!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Tags:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: task.tags!.map((tag) => Chip(
                  label: Text(tag),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Choose Another'),
        ),
        ElevatedButton(
          onPressed: () async {
            final ticktickService = Provider.of<TickTickService>(context, listen: false);
            await ticktickService.updateTaskStatus(task, true);
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task marked as completed')),
              );
            }
          },
          child: const Text('Mark Complete'),
        ),
      ],
    );
  }
} 