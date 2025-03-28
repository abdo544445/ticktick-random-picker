import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:ticktick_random_picker/screens/home_screen.dart';
import 'package:ticktick_random_picker/services/auth_service.dart';
import 'package:ticktick_random_picker/services/ticktick_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ProxyProvider<AuthService, TickTickService>(
          update: (_, authService, __) => TickTickService(authService),
        ),
      ],
      child: MaterialApp(
        title: 'TickTick Random Picker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
      ),
    );
  }
} 