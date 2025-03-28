import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticktick_random_picker/models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(bool) onStatusChanged;
  
  const TaskItem({
    Key? key,
    required this.task,
    required this.onStatusChanged,
  }) : super(key: key);

  String _formatDueDate(DateTime? dueDate) {
    if (dueDate == null) return 'No due date';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    if (taskDate.compareTo(today) == 0) {
      return 'Today';
    } else if (taskDate.compareTo(tomorrow) == 0) {
      return 'Tomorrow';
    } else if (taskDate.difference(today).inDays < 7) {
      return DateFormat('EEEE').format(dueDate); // Day of week
    } else {
      return DateFormat('MMM d, yyyy').format(dueDate);
    }
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          activeColor: _getPriorityColor(task.priority),
          onChanged: (value) {
            if (value != null) {
              onStatusChanged(value);
            }
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.dueDate != null)
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    _formatDueDate(task.dueDate),
                    style: TextStyle(
                      color: task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            if (task.tags != null && task.tags!.isNotEmpty)
              Wrap(
                spacing: 4,
                children: task.tags!.map((tag) => Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 10)),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
          ],
        ),
        trailing: Container(
          width: 4,
          height: 40,
          color: _getPriorityColor(task.priority),
        ),
      ),
    );
  }
} 