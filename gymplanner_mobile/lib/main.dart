import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/core/theme/app_theme.dart';
import 'package:gymplanner_mobile/core/theme/theme_notifier.dart';
import 'package:gymplanner_mobile/features/auth/screens/login_screen.dart';

void main() {
  runApp(
    const ProviderScope(child: GymPlannerApp()),
  );
}

class GymPlannerApp extends ConsumerWidget {
  const GymPlannerApp({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'GymPlanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
      home: const LoginScreen(),
    );
  }
}
