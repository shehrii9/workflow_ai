import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workflow_ai/theme/app_theme.dart';
import 'package:workflow_ai/features/workflows/list/workflows_list_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Workflow AI',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const WorkflowsListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

