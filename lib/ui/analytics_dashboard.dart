import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({super.key});

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final sessionDuration = DateTime.now().difference(appState.sessionStartTime);
    
    final isHindi = appState.isHindi;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isHindi ? 'संस्थागत व्यवस्थापक (Institutional Admin)' : 'Institutional Admin Dashboard'),
          backgroundColor: Colors.blueGrey,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
              Tab(icon: Icon(Icons.people), text: 'License Management'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatCard(
                    title: isHindi ? 'सत्र की अवधि' : 'Session Duration',
                    value: _formatDuration(sessionDuration),
                    icon: Icons.timer,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: isHindi ? 'बनाए गए पृष्ठ' : 'Pages Created',
                          value: appState.pagesCreated.toString(),
                          icon: Icons.pages,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: isHindi ? 'AI उपयोग' : 'AI Features Used',
                          value: appState.aiFeaturesUsed.toString(),
                          icon: Icons.auto_awesome,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    isHindi ? 'टूल का उपयोग' : 'Tool Usage (This Session)',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  appState.toolUsageStats.isEmpty 
                      ? Text(isHindi ? 'अभी तक कोई टूल इस्तेमाल नहीं किया गया।' : 'No tools used yet.') 
                      : _buildBarChart(appState.toolUsageStats),
                ],
              ),
            ),
            _buildLicenseManagementTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseManagementTab() {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('License Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Total Seats: 50'),
                const Text('Active Seats: 42'),
                const SizedBox(height: 16),
                LinearProgressIndicator(value: 42 / 50, backgroundColor: Colors.grey[300], color: Colors.blue),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Active Teachers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ListTile(
          leading: const CircleAvatar(child: Text('T1')),
          title: const Text('Teacher 1 (Math)'),
          subtitle: const Text('Last Active: 2 hours ago'),
          trailing: IconButton(icon: const Icon(Icons.block, color: Colors.red), onPressed: () {}),
        ),
        ListTile(
          leading: const CircleAvatar(child: Text('T2')),
          title: const Text('Teacher 2 (Physics)'),
          subtitle: const Text('Last Active: 1 day ago'),
          trailing: IconButton(icon: const Icon(Icons.block, color: Colors.red), onPressed: () {}),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> stats) {
    int maxCount = stats.values.reduce((a, b) => a > b ? a : b);
    
    // Sort by usage count
    var sortedEntries = stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.map((entry) {
        double widthFactor = entry.value / maxCount;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  entry.key.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: widthFactor,
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${entry.value}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
