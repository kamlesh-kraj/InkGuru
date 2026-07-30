// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'calibration_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isHindi = appState.isHindi;

    return Scaffold(
      appBar: AppBar(
        title: Text(isHindi ? 'सेटिंग्स' : 'Settings'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text(isHindi ? 'थीम' : 'Themes', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          RadioListTile<int>(
            title: Text(isHindi ? 'लाइट थीम' : 'Light Theme'),
            value: 0,
            groupValue: appState.themeMode,
            onChanged: (val) {
              if (val != null) context.read<AppState>().setThemeMode(val);
            },
          ),
          RadioListTile<int>(
            title: Text(isHindi ? 'डार्क थीम' : 'Dark Theme'),
            value: 1,
            groupValue: appState.themeMode,
            onChanged: (val) {
              if (val != null) context.read<AppState>().setThemeMode(val);
            },
          ),
          RadioListTile<int>(
            title: Text(isHindi ? 'क्लासिक ब्लैकबोर्ड' : 'Classic Blackboard'),
            value: 2,
            groupValue: appState.themeMode,
            onChanged: (val) {
              if (val != null) context.read<AppState>().setThemeMode(val);
            },
          ),
          const Divider(),
          ListTile(
            title: Text(isHindi ? 'हार्डवेयर एकीकरण (XP-Pen)' : 'Hardware Integration (XP-Pen)', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: Text(isHindi ? 'दबाव वक्र को कैलिब्रेट करें' : 'Calibrate Pressure Curve'),
            trailing: const Icon(Icons.settings_input_component),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalibrationScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: Text(isHindi ? 'भाषा' : 'Language', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: Text(isHindi ? 'भाषा बदलें' : 'Change Language'),
            subtitle: Text(isHindi ? 'वर्तमान: हिंदी (अंग्रेजी उपलब्ध)' : 'Current: English (Hindi available)'),
            trailing: const Icon(Icons.language),
            onTap: () {
              appState.toggleLanguage();
            },
          ),
        ],
      ),
    );
  }
}
