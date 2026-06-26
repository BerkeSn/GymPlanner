import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/core/constants/app_colors.dart';
import 'package:gymplanner_mobile/core/constants/app_text_styles.dart';
import 'package:gymplanner_mobile/features/auth/providers/auth_provider.dart';
import 'package:gymplanner_mobile/features/auth/screens/register_screen.dart';
import 'package:gymplanner_mobile/main_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginInputController =
      TextEditingController();
  final _passwordController =
      TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _loginInputController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate())
      return;

    final success = await ref
        .read(authProvider.notifier)
        .login(
          loginInput: _loginInputController.text
              .trim(),
          password: _passwordController.text
              .trim(),
        );

    if (!mounted) return;

    if (success) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading =
        authState.status == AuthStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // --- Başlık ---
                Text(
                  'Tekrar\nHoş Geldin 💪',
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: 8),
                Text(
                  'Antrenmanına devam etmek için giriş yap.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 48),

                // --- Giriş Alanı ---
                TextFormField(
                  controller:
                      _loginInputController,
                  keyboardType:
                      TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText:
                        'E-posta, kullanıcı adı veya telefon',
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Bu alan zorunludur.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- Şifre Alanı ---
                TextFormField(
                  controller: _passwordController,
                  obscureText:
                      !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Şifre',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons
                                  .visibility_off_outlined
                            : Icons
                                  .visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible =
                              !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Şifre zorunludur.';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // --- Hata Mesajı ---
                if (authState.status ==
                    AuthStatus.error)
                  Padding(
                    padding:
                        const EdgeInsets.only(
                          bottom: 8,
                        ),
                    child: Text(
                      authState.errorMessage ??
                          '',
                      style: AppTextStyles
                          .bodySmall
                          .copyWith(
                            color:
                                AppColors.error,
                          ),
                    ),
                  ),
                const SizedBox(height: 24),

                // --- Giriş Butonu ---
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : _handleLogin,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                                color:
                                    Colors.white,
                                strokeWidth: 2,
                              ),
                        )
                      : const Text('Giriş Yap'),
                ),
                const SizedBox(height: 16),

                // --- Kayıt Ol ---
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hesabın yok mu?',
                      style: AppTextStyles
                          .bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Kayıt Ol',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
