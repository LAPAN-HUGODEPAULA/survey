import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LAPAN Survey'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person), // Placeholder for profile icon
            onPressed: () {
              // TODO: Open profile menu (login, settings, etc.)
              context.go('/profile'); // Navigate to profile page for now
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings), // Settings icon
            onPressed: () {
              context.go('/settings'); // Navigate to settings page
            },
          ),
        ],
      ),
      body: child,
    );
  }
}
