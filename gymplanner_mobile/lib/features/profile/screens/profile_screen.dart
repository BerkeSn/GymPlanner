import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/core/constants/app_colors.dart';
import 'package:gymplanner_mobile/core/constants/app_text_styles.dart';
import 'package:gymplanner_mobile/core/models/user_model.dart';
import 'package:gymplanner_mobile/features/auth/providers/auth_provider.dart';
import 'package:gymplanner_mobile/features/auth/screens/login_screen.dart';
import 'package:gymplanner_mobile/features/calorie/screens/calorie_tracking_screen.dart';
import 'package:gymplanner_mobile/features/profile/providers/profile_provider.dart';
import 'package:gymplanner_mobile/features/social/screens/friends_screen.dart';

class ProfileScreen
    extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController =
      TextEditingController();
  final _usernameController =
      TextEditingController();
  final _emailController =
      TextEditingController();
  final _phoneController =
      TextEditingController();

  String _selectedGender = 'other';
  String _selectedLocation = 'Gym';
  bool _formInitialized = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(profileProvider.notifier)
          .loadProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _fillForm(UserModel user) {
    if (_formInitialized) return;
    _nameController.text = user.name;
    _surnameController.text = user.surname;
    _usernameController.text = user.username;
    _emailController.text = user.email;
    _phoneController.text = user.phone ?? '';
    _selectedGender = user.gender;
    _selectedLocation = user.locationPreference;
    _formInitialized = true;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate())
      return;

    final success = await ref
        .read(profileProvider.notifier)
        .updateProfile(
          name: _nameController.text.trim(),
          surname: _surnameController.text.trim(),
          username: _usernameController.text
              .trim(),
          email: _emailController.text.trim(),
          phone:
              _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          gender: _selectedGender,
          locationPreference: _selectedLocation,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil güncellendi.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text(
          'Hesabından çıkış yapmak istediğine emin misin?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ref
        .read(authProvider.notifier)
        .logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons
                  .local_fire_department_outlined,
            ),
            tooltip: 'Kalori Takibi',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const CalorieTrackingScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.group_outlined,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const FriendsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ProfileState state) {
    if (state.isLoading && state.user == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null &&
        state.user == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(
                      profileProvider.notifier,
                    )
                    .loadProfile(),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.user == null) {
      return const Center(
        child: Text('Profil bulunamadı.'),
      );
    }

    _fillForm(state.user!);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Hesap Bilgilerin',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              textCapitalization:
                  TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Ad',
                prefixIcon: Icon(
                  Icons.person_outline,
                ),
              ),
              validator: (value) =>
                  value == null || value.isEmpty
                  ? 'Ad zorunludur.'
                  : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _surnameController,
              textCapitalization:
                  TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Soyad',
                prefixIcon: Icon(
                  Icons.person_outline,
                ),
              ),
              validator: (value) =>
                  value == null || value.isEmpty
                  ? 'Soyad zorunludur.'
                  : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: 'Kullanıcı Adı',
                prefixIcon: Icon(
                  Icons.alternate_email,
                ),
              ),
              validator: (value) =>
                  value == null || value.isEmpty
                  ? 'Kullanıcı adı zorunludur.'
                  : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              keyboardType:
                  TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'E-posta',
                prefixIcon: Icon(
                  Icons.email_outlined,
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return 'E-posta zorunludur.';
                }
                if (!value.contains('@')) {
                  return 'Geçerli bir e-posta girin.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Telefon (opsiyonel)',
                prefixIcon: Icon(
                  Icons.phone_outlined,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Cinsiyet',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _OptionButton(
                  label: 'Erkek',
                  value: 'male',
                  selectedValue: _selectedGender,
                  onTap: () => setState(
                    () =>
                        _selectedGender = 'male',
                  ),
                ),
                const SizedBox(width: 12),
                _OptionButton(
                  label: 'Kadın',
                  value: 'female',
                  selectedValue: _selectedGender,
                  onTap: () => setState(
                    () => _selectedGender =
                        'female',
                  ),
                ),
                const SizedBox(width: 12),
                _OptionButton(
                  label: 'Diğer',
                  value: 'other',
                  selectedValue: _selectedGender,
                  onTap: () => setState(
                    () =>
                        _selectedGender = 'other',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Antrenman Tercihi',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _OptionButton(
                  label: 'Salon',
                  value: 'Gym',
                  selectedValue:
                      _selectedLocation,
                  onTap: () => setState(
                    () =>
                        _selectedLocation = 'Gym',
                  ),
                ),
                const SizedBox(width: 12),
                _OptionButton(
                  label: 'Ev',
                  value: 'Home',
                  selectedValue:
                      _selectedLocation,
                  onTap: () => setState(
                    () => _selectedLocation =
                        'Home',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                ),
                child: Text(
                  state.errorMessage!,
                  style: AppTextStyles.bodySmall
                      .copyWith(
                        color: AppColors.error,
                      ),
                ),
              ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: state.isSaving
                  ? null
                  : _handleSave,
              child: state.isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                    )
                  : const Text('Kaydet'),
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: _handleLogout,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Çıkış Yap'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final String value;
  final String selectedValue;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(
              12,
            ),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textGrey,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall
                .copyWith(
                  color: isSelected
                      ? AppColors.textLight
                      : AppColors.textGrey,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}
