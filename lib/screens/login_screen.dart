import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticktick_random_picker/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _codeController = TextEditingController();
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _authorize() async {
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    final auth = Provider.of<AuthService>(context, listen: false);
    final success = await auth.authorize();

    if (!success) {
      setState(() {
        _errorMessage = 'Failed to launch authorization URL';
        _isAuthenticating = false;
      });
    } else {
      // Keep _isAuthenticating true as we now wait for the code
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _submitAuthCode() async {
    if (_codeController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the authorization code';
      });
      return;
    }

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    final auth = Provider.of<AuthService>(context, listen: false);
    final success = await auth.handleAuthCode(_codeController.text);

    if (!success) {
      setState(() {
        _errorMessage = 'Failed to authenticate with provided code';
        _isAuthenticating = false;
      });
    }
    // If successful, the HomeScreen will automatically navigate to ProjectsScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TickTick Random Picker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.task_alt,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to TickTick Random Picker',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect your TickTick account to randomly select tasks from your lists',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            if (_isAuthenticating && _errorMessage == null && _codeController.text.isEmpty)
              ElevatedButton(
                onPressed: null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Authorizing...'),
                  ],
                ),
              )
            else if (!_isAuthenticating || _errorMessage != null)
              ElevatedButton(
                onPressed: _authorize,
                child: const Text('Connect to TickTick'),
              ),
            const SizedBox(height: 16),
            if (_isAuthenticating || _errorMessage != null) ...[
              const Text(
                'Enter the authorization code from TickTick:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Authorization code',
                  errorText: _errorMessage,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isAuthenticating ? _submitAuthCode : null,
                child: _isAuthenticating && _codeController.text.isNotEmpty
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Code'),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Note: You will be redirected to TickTick login page. After login, copy the authorization code from the redirected URL.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 