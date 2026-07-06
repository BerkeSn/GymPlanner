import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/core/constants/app_colors.dart';
import 'package:gymplanner_mobile/core/constants/app_text_styles.dart';
import 'package:gymplanner_mobile/features/body_measurement/providers/measurement_provider.dart';

class AddMeasurementScreen
    extends ConsumerStatefulWidget {
  const AddMeasurementScreen({super.key});

  @override
  ConsumerState<AddMeasurementScreen>
  createState() => _AddMeasurementScreenState();
}

class _AddMeasurementScreenState
    extends ConsumerState<AddMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController =
      TextEditingController();
  final _heightController =
      TextEditingController();
  final _neckController = TextEditingController();
  final _waistController =
      TextEditingController();
  final _bodyFatController =
      TextEditingController();
  final _muscleMassController =
      TextEditingController();

  String _selectedGoal = 'Maintain';
  DateTime _selectedDate = DateTime.now();

  final List<String> _goals = const [
    'Lose Weight',
    'Gain Muscle',
    'Maintain',
  ];

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _neckController.dispose();
    _waistController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    super.dispose();
  }

  String _goalLabel(String goal) {
    switch (goal) {
      case 'Lose Weight':
        return 'Kilo Ver';
      case 'Gain Muscle':
        return 'Kas Kazan';
      case 'Maintain':
        return 'Koru';
      default:
        return goal;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(
      2,
      '0',
    );
    final day = date.day.toString().padLeft(
      2,
      '0',
    );
    return '${date.year}-$month-$day';
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate())
      return;

    final success = await ref
        .read(measurementProvider.notifier)
        .createMeasurement(
          weight: double.parse(
            _weightController.text.trim(),
          ),
          height: double.parse(
            _heightController.text.trim(),
          ),
          date: _formatDate(_selectedDate),
          neck:
              _neckController.text.trim().isEmpty
              ? null
              : double.tryParse(
                  _neckController.text.trim(),
                ),
          waist:
              _waistController.text.trim().isEmpty
              ? null
              : double.tryParse(
                  _waistController.text.trim(),
                ),
          bodyFatPercentage:
              _bodyFatController.text
                  .trim()
                  .isEmpty
              ? null
              : double.tryParse(
                  _bodyFatController.text.trim(),
                ),
          muscleMass:
              _muscleMassController.text
                  .trim()
                  .isEmpty
              ? null
              : double.tryParse(
                  _muscleMassController.text
                      .trim(),
                ),
          goal: _selectedGoal,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ölçüm kaydedildi!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      final error = ref
          .read(measurementProvider)
          .errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ?? 'Bir hata oluştu',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(measurementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ölçüm Ekle'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Yeni Ölçüm',
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 24),

                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      hintText: 'Tarih',
                      prefixIcon: Icon(
                        Icons
                            .calendar_today_outlined,
                      ),
                    ),
                    child: Text(
                      _formatDate(_selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                  decoration: const InputDecoration(
                    hintText: 'Kilo (kg)',
                    prefixIcon: Icon(
                      Icons
                          .monitor_weight_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Kilo zorunludur.';
                    }
                    if (double.tryParse(value) ==
                        null) {
                      return 'Geçerli bir sayı girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _heightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                  decoration:
                      const InputDecoration(
                        hintText: 'Boy (cm)',
                        prefixIcon: Icon(
                          Icons.height,
                        ),
                      ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Boy zorunludur.';
                    }
                    if (double.tryParse(value) ==
                        null) {
                      return 'Geçerli bir sayı girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _neckController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                  decoration: const InputDecoration(
                    hintText:
                        'Boyun (cm, opsiyonel)',
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _waistController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                  decoration:
                      const InputDecoration(
                        hintText:
                            'Bel (cm, opsiyonel)',
                      ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _bodyFatController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                  decoration: const InputDecoration(
                    hintText:
                        'Yağ Oranı (%, opsiyonel)',
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      _muscleMassController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                  decoration: const InputDecoration(
                    hintText:
                        'Kas Kütlesi (kg, opsiyonel)',
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Hedef',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: _goals.map((goal) {
                    final isSelected =
                        goal == _selectedGoal;
                    return Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(
                              right: 8,
                            ),
                        child: GestureDetector(
                          onTap: () => setState(
                            () => _selectedGoal =
                                goal,
                          ),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors
                                        .primary
                                  : Colors
                                        .transparent,
                              borderRadius:
                                  BorderRadius.circular(
                                    12,
                                  ),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors
                                          .primary
                                    : AppColors
                                          .textGrey,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              _goalLabel(goal),
                              textAlign: TextAlign
                                  .center,
                              style: AppTextStyles
                                  .bodySmall
                                  .copyWith(
                                    color:
                                        isSelected
                                        ? AppColors
                                              .textLight
                                        : AppColors
                                              .textGrey,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
                                color:
                                    Colors.white,
                                strokeWidth: 2,
                              ),
                        )
                      : const Text('Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
