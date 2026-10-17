import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'data/repository/auth_repository.dart';
import 'data/repository/couple_repository.dart';
import 'data/repository/date_repository.dart';
import 'data/repository/moment_repository.dart';
import 'firebase_options.dart';
import 'ui/auth/auth_provider.dart';
import 'ui/couple/couple_provider.dart';
import 'ui/dates/date_provider.dart';
import 'ui/home/home_provider.dart';
import 'ui/moment/moment_provider.dart';
import 'ui/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    debugPrint('Firebase initialization failed: $e\n$stack');
  }

  // Inisialisasi locale formatting tanggal (id_ID) untuk intl
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    debugPrint('DateFormatting initialization failed: $e');
  }

  runApp(const PufLuvApp());
}

class PufLuvApp extends StatelessWidget {
  const PufLuvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        Provider<CoupleRepository>(create: (_) => CoupleRepository()),
        Provider<MomentRepository>(create: (_) => MomentRepository()),
        Provider<DateRepository>(create: (_) => DateRepository()),

        // Providers (ChangeNotifiers)
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            repository: context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider<CoupleProvider>(
          create: (context) => CoupleProvider(
            repository: context.read<CoupleRepository>(),
          ),
        ),
        ChangeNotifierProvider<MomentProvider>(
          create: (context) => MomentProvider(
            repository: context.read<MomentRepository>(),
          ),
        ),
        ChangeNotifierProvider<DateProvider>(
          create: (context) => DateProvider(
            repository: context.read<DateRepository>(),
          ),
        ),
        ChangeNotifierProvider<HomeProvider>(
          create: (context) => HomeProvider(
            coupleRepository: context.read<CoupleRepository>(),
            momentRepository: context.read<MomentRepository>(),
            dateRepository: context.read<DateRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'PUFLUV',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
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
