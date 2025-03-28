import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticktick_random_picker/screens/login_screen.dart';
import 'package:ticktick_random_picker/screens/projects_screen.dart';
import 'package:ticktick_random_picker/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.init();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          return const ProjectsScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
} 