import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'ui/board_screen.dart';
import 'ui/project_dashboard.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const InkGuruApp(),
    ),
  );
}

class InkGuruApp extends StatelessWidget {
  const InkGuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final themeMode = appState.themeMode;
        final highContrast = appState.highContrast;
        final uiScale = appState.uiScale;
        
        ThemeData themeData;
        if (themeMode == 0) { // Light
          themeData = ThemeData.light(useMaterial3: true);
          if (highContrast) {
             themeData = themeData.copyWith(
                colorScheme: const ColorScheme.light(
                   primary: Colors.black,
                   secondary: Colors.black,
                   surface: Colors.white,
                   surfaceContainerHighest: Colors.white,
                )
             );
          }
        } else if (themeMode == 1) { // Dark
          themeData = ThemeData.dark(useMaterial3: true);
          if (highContrast) {
             themeData = themeData.copyWith(
                colorScheme: const ColorScheme.dark(
                   primary: Colors.white,
                   secondary: Colors.white,
                   surface: Colors.black,
                )
             );
          }
        } else { // Blackboard
          themeData = ThemeData.dark(useMaterial3: true).copyWith(
            scaffoldBackgroundColor: const Color(0xFF1a2b22),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF132019),
            ),
          );
        }

        return MaterialApp(
          title: 'InkGuru',
          debugShowCheckedModeBanner: false,
          theme: themeData,
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            // Apply text scaling (and UI scaling indirectly)
            return MediaQuery(
              data: mediaQueryData.copyWith(
                textScaler: TextScaler.linear(uiScale),
                highContrast: highContrast,
              ),
              child: child!,
            );
          },
          home: const ProjectDashboard(),
        );
      },
    );
  }
}
