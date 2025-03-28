import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticktick_random_picker/models/project.dart';
import 'package:ticktick_random_picker/models/task.dart';
import 'package:ticktick_random_picker/services/ticktick_service.dart';
import 'package:ticktick_random_picker/widgets/task_item.dart';

class TasksScreen extends StatefulWidget {
  final Project project;
  
  const TasksScreen({Key? key, required this.project}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late Future<List<Task>> _tasksFuture;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }
  
  void _loadTasks() {
    final ticktickService = Provider.of<TickTickService>(context, listen: false);
    setState(() {
      _tasksFuture = ticktickService.getTasksByProject(widget.project.id);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                _loadTasks();
                await _tasksFuture;
              },
              child: FutureBuilder<List<Task>>(
                future: _tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${snapshot.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadTasks,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No tasks found'),
                    );
                  }
                  
                  final tasks = snapshot.data!;
                  final incompleteTasks = tasks.where((task) => !task.isCompleted).toList();
                  final completedTasks = tasks.where((task) => task.isCompleted).toList();
                  
                  return ListView(
                    padding: const EdgeInsets.all(8.0),
                    children: [
                      if (incompleteTasks.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Incomplete Tasks',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...incompleteTasks.map((task) => TaskItem(
                              task: task,
                              onStatusChanged: (completed) async {
                                setState(() {
                                  _isLoading = true;
                                });
                                
                                try {
                                  final ticktickService = Provider.of<TickTickService>(context, listen: false);
                                  await ticktickService.updateTaskStatus(task, completed);
                                  _loadTasks();
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: ${e.toString()}')),
                                    );
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                            )),
                      ],
                      
                      if (completedTasks.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Completed Tasks',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...completedTasks.map((task) => TaskItem(
                              task: task,
                              onStatusChanged: (completed) async {
                                setState(() {
                                  _isLoading = true;
                                });
                                
                                try {
                                  final ticktickService = Provider.of<TickTickService>(context, listen: false);
                                  await ticktickService.updateTaskStatus(task, completed);
                                  _loadTasks();
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: ${e.toString()}')),
                                    );
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                            )),
                      ],
                    ],
                  );
                },
              ),
            ),
    );
  }
} 