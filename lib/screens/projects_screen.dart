import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_color/random_color.dart';
import 'package:ticktick_random_picker/models/project.dart';
import 'package:ticktick_random_picker/models/task.dart';
import 'package:ticktick_random_picker/screens/tasks_screen.dart';
import 'package:ticktick_random_picker/services/auth_service.dart';
import 'package:ticktick_random_picker/services/ticktick_service.dart';
import 'package:ticktick_random_picker/widgets/random_task_dialog.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late Future<List<Project>> _projectsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    final ticktickService = Provider.of<TickTickService>(context, listen: false);
    setState(() {
      _projectsFuture = ticktickService.getProjects();
    });
  }

  Future<void> _logout() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.logout();
  }

  Future<void> _getRandomTaskFromAllProjects() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ticktickService = Provider.of<TickTickService>(context, listen: false);
      final Task? randomTask = await ticktickService.getRandomTask();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (randomTask != null) {
          showDialog(
            context: context,
            builder: (context) => RandomTaskDialog(task: randomTask),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No incomplete tasks found')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My TickTick Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                _loadProjects();
                return _projectsFuture;
              },
              child: FutureBuilder<List<Project>>(
                future: _projectsFuture,
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
                            onPressed: _loadProjects,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No lists found'),
                    );
                  }

                  final projects = snapshot.data!
                      .where((project) => !project.closed)
                      .toList();

                  return ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      Color projectColor;
                      
                      try {
                        projectColor = _getColorFromHex(project.color);
                      } catch (e) {
                        // Fallback color if the hex is invalid
                        projectColor = RandomColor().randomColor();
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: projectColor,
                          child: const Icon(Icons.list, color: Colors.white),
                        ),
                        title: Text(project.name),
                        subtitle: Text('Last updated: ${project.modifiedTime.toString().substring(0, 10)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.shuffle),
                          tooltip: 'Pick random task',
                          onPressed: () async {
                            final ticktickService = Provider.of<TickTickService>(context, listen: false);
                            setState(() {
                              _isLoading = true;
                            });
                            
                            try {
                              final randomTask = await ticktickService.getRandomTaskFromProject(project.id);
                              
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                                
                                if (randomTask != null) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => RandomTaskDialog(task: randomTask),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('No incomplete tasks in this list')),
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: ${e.toString()}')),
                                );
                              }
                            }
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => TasksScreen(project: project),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getRandomTaskFromAllProjects,
        tooltip: 'Pick random task from all lists',
        child: const Icon(Icons.shuffle),
      ),
    );
  }
} 