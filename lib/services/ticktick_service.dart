import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ticktick_random_picker/models/project.dart';
import 'package:ticktick_random_picker/models/task.dart';
import 'package:ticktick_random_picker/services/auth_service.dart';

class TickTickService {
  final AuthService _authService;
  final String _baseUrl;
  
  TickTickService(this._authService) 
      : _baseUrl = dotenv.env['TICKTICK_API_BASE_URL'] ?? 'https://api.ticktick.com/api/v2';
  
  // Get all projects (lists)
  Future<List<Project>> getProjects() async {
    if (!_authService.isAuthenticated) {
      throw Exception('User not authenticated');
    }
    
    final response = await _authService.client!.get(
      Uri.parse('$_baseUrl/projects'),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Project.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load projects: ${response.statusCode}');
    }
  }
  
  // Get all tasks for a specific project
  Future<List<Task>> getTasksByProject(String projectId) async {
    if (!_authService.isAuthenticated) {
      throw Exception('User not authenticated');
    }
    
    final response = await _authService.client!.get(
      Uri.parse('$_baseUrl/project/$projectId/tasks'),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks: ${response.statusCode}');
    }
  }
  
  // Get specific task details
  Future<Task> getTask(String projectId, String taskId) async {
    if (!_authService.isAuthenticated) {
      throw Exception('User not authenticated');
    }
    
    final response = await _authService.client!.get(
      Uri.parse('$_baseUrl/project/$projectId/task/$taskId'),
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Task.fromJson(data);
    } else {
      throw Exception('Failed to load task details: ${response.statusCode}');
    }
  }
  
  // Get all tasks across all projects
  Future<List<Task>> getAllTasks() async {
    if (!_authService.isAuthenticated) {
      throw Exception('User not authenticated');
    }
    
    final projects = await getProjects();
    List<Task> allTasks = [];
    
    for (final project in projects) {
      if (!project.closed) {
        final tasks = await getTasksByProject(project.id);
        allTasks.addAll(tasks);
      }
    }
    
    return allTasks;
  }
  
  // Pick a random task from a specific project
  Future<Task?> getRandomTaskFromProject(String projectId) async {
    final tasks = await getTasksByProject(projectId);
    final incompleteTasks = tasks.where((task) => !task.isCompleted).toList();
    
    if (incompleteTasks.isEmpty) {
      return null;
    }
    
    final random = Random();
    return incompleteTasks[random.nextInt(incompleteTasks.length)];
  }
  
  // Pick a random task from all projects
  Future<Task?> getRandomTask() async {
    final tasks = await getAllTasks();
    final incompleteTasks = tasks.where((task) => !task.isCompleted).toList();
    
    if (incompleteTasks.isEmpty) {
      return null;
    }
    
    final random = Random();
    return incompleteTasks[random.nextInt(incompleteTasks.length)];
  }
  
  // Update task status
  Future<bool> updateTaskStatus(Task task, bool completed) async {
    if (!_authService.isAuthenticated) {
      throw Exception('User not authenticated');
    }
    
    final taskData = task.toJson();
    taskData['status'] = completed ? 'completed' : 'normal';
    
    final response = await _authService.client!.post(
      Uri.parse('$_baseUrl/project/${task.projectId}/task/${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(taskData),
    );
    
    return response.statusCode == 200;
  }
} 