import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_state.dart';
import '../document/project_manager.dart';
import 'board_screen.dart';

class ProjectDashboard extends StatefulWidget {
  const ProjectDashboard({super.key});

  @override
  State<ProjectDashboard> createState() => _ProjectDashboardState();
}

class _ProjectDashboardState extends State<ProjectDashboard> {
  List<ProjectInfo> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    final projects = await ProjectManager.listProjects();
    if (mounted) {
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    }
  }

  void _startNewProject() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.clearBoard();
    appState.setProjectMetadata(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Untitled Lesson',
      subject: '',
      chapter: '',
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BoardScreen()),
    ).then((_) => _loadProjects());
  }

  void _openProject(ProjectInfo project) async {
    setState(() => _isLoading = true);
    await ProjectManager.loadProjectFromPath(context, project.path);
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BoardScreen()),
      ).then((_) => _loadProjects());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InkGuru - Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No local projects found.', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _startNewProject,
                        icon: const Icon(Icons.add),
                        label: const Text('Start New Project'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _startNewProject,
                        icon: const Icon(Icons.add),
                        label: const Text('Start New Project'),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _projects.length,
                          itemBuilder: (context, index) {
                            final p = _projects[index];
                            return Card(
                              elevation: 4,
                              child: InkWell(
                                onTap: () => _openProject(p),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text('Subject: ${p.subject.isEmpty ? 'N/A' : p.subject}'),
                                      Text('Chapter: ${p.chapter.isEmpty ? 'N/A' : p.chapter}'),
                                      const Spacer(),
                                      Text(
                                        'Last edited: ${DateFormat.yMMMd().add_jm().format(p.modifiedAt)}',
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
