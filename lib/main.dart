import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'ui/board_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppState>().themeMode;
    
    ThemeData themeData;
    switch (themeMode) {
      case 0:
        themeData = ThemeData.light(useMaterial3: true);
        break;
      case 1:
        themeData = ThemeData.dark(useMaterial3: true);
        break;
      case 2:
      default:
        themeData = ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xFF1E3F20),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF122814),
            foregroundColor: Colors.white,
          ),
        );
        break;
    }

    return MaterialApp(
      title: 'InkGuru',
      theme: themeData,
      home: const BoardScreen(),
    );
  }
}
