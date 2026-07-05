import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/core/models/exercise_model.dart';
import 'package:gymplanner_mobile/features/exercise/providers/exercise_provider.dart';
import 'package:gymplanner_mobile/features/workout/providers/workout_provider.dart';

class AddExerciseScreen
    extends ConsumerStatefulWidget {
  final int routineId;

  const AddExerciseScreen({
    super.key,
    required this.routineId,
  });

  @override
  ConsumerState<AddExerciseScreen>
  createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState
    extends ConsumerState<AddExerciseScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(exerciseProvider.notifier)
          .loadMuscleGroups();
    });
  }

  void _showAddSheet(ExerciseModel exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddExerciseSheet(
        exercise: exercise,
        onSave: (day, targetSets, targetReps) async {
          final success = await ref
              .read(workoutProvider.notifier)
              .addExerciseToRoutine(
                routineId: widget.routineId,
                exerciseId: exercise.id,
                day: day,
                targetSets: targetSets,
                targetReps: targetReps,
              );

          if (!mounted) return;

          if (success) {
            Navigator.of(context)
              ..pop() // sheet'i kapat
              ..pop(); // ekrandan çık, WorkoutDetailScreen'e dön
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              SnackBar(
                content: Text(
                  ref
                          .read(workoutProvider)
                          .errorMessage ??
                      'Bir hata oluştu',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exerciseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Egzersiz Ekle'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              itemCount:
                  state.muscleGroups.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final group =
                    state.muscleGroups[index];
                final isSelected =
                    group.id ==
                    state.selectedMuscleGroupId;

                return ChoiceChip(
                  label: Text(group.name),
                  selected: isSelected,
                  onSelected: (_) {
                    ref
                        .read(
                          exerciseProvider
                              .notifier,
                        )
                        .selectMuscleGroup(
                          group.id,
                        );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildExerciseList(state),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(ExerciseState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Text(state.errorMessage!),
      );
    }

    if (state.exercises.isEmpty) {
      return const Center(
        child: Text(
          'Bu bölgede egzersiz bulunamadı',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.exercises.length,
      itemBuilder: (context, index) {
        final exercise = state.exercises[index];

        return Card(
          margin: const EdgeInsets.only(
            bottom: 10,
          ),
          child: ListTile(
            title: Text(exercise.name),
            subtitle:
                exercise.equipmentName != null
                ? Text(exercise.equipmentName!)
                : null,
            trailing: IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
              ),
              onPressed: () =>
                  _showAddSheet(exercise),
            ),
          ),
        );
      },
    );
  }
}

class _AddExerciseSheet extends StatefulWidget {
  final ExerciseModel exercise;
  final Future<void> Function(
    String day,
    int targetSets,
    int targetReps,
  )
  onSave;

  const _AddExerciseSheet({
    required this.exercise,
    required this.onSave,
  });

  @override
  State<_AddExerciseSheet> createState() =>
      _AddExerciseSheetState();
}

class _AddExerciseSheetState
    extends State<_AddExerciseSheet> {
  final _setController = TextEditingController(
    text: '3',
  );
  final _repController = TextEditingController(
    text: '10',
  );
  final List<String> _days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String _selectedDay = 'Monday';
  bool _isSaving = false;

  @override
  void dispose() {
    _setController.dispose();
    _repController.dispose();
    super.dispose();
  }

  String _dayLabel(String day) {
    switch (day) {
      case 'Monday':
        return 'Pazartesi';
      case 'Tuesday':
        return 'Salı';
      case 'Wednesday':
        return 'Çarşamba';
      case 'Thursday':
        return 'Perşembe';
      case 'Friday':
        return 'Cuma';
      case 'Saturday':
        return 'Cumartesi';
      case 'Sunday':
        return 'Pazar';
      default:
        return day;
    }
  }

  Future<void> _save() async {
    final targetSets = int.tryParse(
      _setController.text.trim(),
    );
    final targetReps = int.tryParse(
      _repController.text.trim(),
    );

    if (targetSets == null ||
        targetReps == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Set ve tekrar sayıları geçerli olmalı',
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await widget.onSave(
      _selectedDay,
      targetSets,
      targetReps,
    );
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(
      context,
    ).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: bottomInset + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.exercise.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedDay,
              decoration: const InputDecoration(
                labelText: 'Gün',
              ),
              items: _days
                  .map(
                    (day) =>
                        DropdownMenuItem<String>(
                          value: day,
                          child: Text(
                            _dayLabel(day),
                          ),
                        ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(
                  () => _selectedDay = value,
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _setController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Set',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _repController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tekrar',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                    )
                  : const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
