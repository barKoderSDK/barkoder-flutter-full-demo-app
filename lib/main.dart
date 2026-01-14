import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/barcode_details_screen.dart';
import 'screens/history_screen.dart';
import 'screens/about_screen.dart';
import 'models/history_item.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Barkoder Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE52E4C),
          primary: const Color(0xFFE52E4C),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/scanner',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final mode = extra?['mode'] as String? ?? '1d';
        return ScannerScreen(mode: mode);
      },
    ),
    GoRoute(
      path: '/barcode-details',
      builder: (context, state) {
        final item = state.extra as HistoryItem;
        return BarcodeDetailsScreen(item: item);
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
  ],
);
