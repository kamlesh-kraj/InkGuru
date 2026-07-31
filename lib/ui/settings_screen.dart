// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'analytics_dashboard.dart';
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: isHindi ? 'पेन बटन 1 (Pen Button 1)' : 'Pen Button 1 Mapping'),
              value: 'Undo',
              items: ['Undo', 'Eraser', 'Next Page', 'Laser'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: isHindi ? 'एक्सप्रेस कुंजी 1 (Express Key 1)' : 'Express Key 1 Mapping'),
              value: 'Eraser',
              items: ['Undo', 'Eraser', 'Next Page', 'Laser'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
            ),
          ),
          const SizedBox(height: 16),
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
          const Divider(),
          ListTile(
            title: Text(isHindi ? 'पहुंच-योग्यता (Accessibility)' : 'Accessibility', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: Text(isHindi ? 'उच्च कंट्रास्ट' : 'High Contrast'),
            value: appState.highContrast,
            onChanged: (val) {
              context.read<AppState>().toggleHighContrast();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(isHindi ? 'UI आकार' : 'UI Scale'),
                Expanded(
                  child: Slider(
                    value: appState.uiScale,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    label: appState.uiScale.toStringAsFixed(1),
                    onChanged: (val) {
                      context.read<AppState>().setUiScale(val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(isHindi ? 'एआई फीचर्स (AI Features)' : 'AI Features (Open Source)', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: TextEditingController(text: appState.aiApiKey ?? ''),
              decoration: InputDecoration(
                labelText: isHindi ? 'अपना AI API कुंजी दर्ज करें (जैसे OpenAI)' : 'Enter your AI API Key (e.g. OpenAI/Gemini)',
                hintText: 'sk-...',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.vpn_key),
              ),
              obscureText: true,
              onChanged: (val) {
                appState.aiApiKey = val.trim();
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(isHindi ? 'लाइव स्ट्रीमिंग (Live Streaming)' : 'Live Streaming (RTMP)', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: TextEditingController(text: appState.rtmpUrl),
              decoration: InputDecoration(
                labelText: isHindi ? 'RTMP स्ट्रीम URL दर्ज करें (वैकल्पिक)' : 'Enter RTMP Stream URL (Optional)',
                hintText: 'rtmp://a.rtmp.youtube.com/live2/...',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.live_tv),
              ),
              onChanged: (val) {
                appState.setRtmpUrl(val.trim());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalyticsDashboard()),
                );
              },
              icon: const Icon(Icons.analytics),
              label: Text(isHindi ? 'व्यवस्थापक एनालिटिक्स देखें' : 'View Admin Analytics'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
