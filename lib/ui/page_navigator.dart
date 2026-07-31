import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class PageNavigator extends StatelessWidget {
  const PageNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Container(
      height: 60,
      color: Colors.grey[800],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: appState.pages.length + 1,
        itemBuilder: (context, index) {
          if (index == appState.pages.length) {
            return IconButton(
              icon: const Icon(Icons.add_box, color: Colors.blueAccent),
              onPressed: () => appState.addPage(),
              tooltip: 'Add Page',
            );
          }

          final isSelected = index == appState.currentPageIndex;
          
          return GestureDetector(
            onTap: () => appState.switchPage(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              width: 60,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[200] : Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.blueAccent : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isSelected ? Colors.blue[900] : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (appState.pages.length > 1)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => appState.deletePage(index),
                        child: const Icon(Icons.close, size: 16, color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
