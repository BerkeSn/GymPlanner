import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/core/constants/app_colors.dart';
import 'package:gymplanner_mobile/features/auth/providers/auth_provider.dart';
import 'package:gymplanner_mobile/features/auth/screens/login_screen.dart';
import 'package:gymplanner_mobile/main_screen.dart';

class SplashScreen
    extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_checkAuth);
  }

  Future<void> _checkAuth() async {
    final isAuthenticated = await ref
        .read(authProvider.notifier)
        .tryAutoLogin();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isAuthenticated
            ? const MainScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
