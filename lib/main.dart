import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'data/repository/auth_repository.dart';
import 'firebase_options.dart';
import 'ui/auth/auth_provider.dart';
import 'ui/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PufLuvApp());
}

class PufLuvApp extends StatelessWidget {
  const PufLuvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            repository: context.read<AuthRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'PUFLUV',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pinkAccent,
            brightness: Brightness.light,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
