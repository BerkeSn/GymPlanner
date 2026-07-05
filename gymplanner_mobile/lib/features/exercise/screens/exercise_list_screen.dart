import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/features/exercise/providers/exercise_provider.dart';

class ExerciseListScreen
    extends ConsumerStatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  ConsumerState<ExerciseListScreen>
  createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState
    extends ConsumerState<ExerciseListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(exerciseProvider.notifier)
          .loadMuscleGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exerciseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Egzersizler'),
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
        final isFavorite = state
            .favoriteExerciseIds
            .contains(exercise.id);

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
              icon: Icon(
                isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: isFavorite
                    ? Colors.redAccent
                    : null,
              ),
              onPressed: () {
                ref
                    .read(
                      exerciseProvider.notifier,
                    )
                    .toggleFavorite(exercise.id);
              },
            ),
          ),
        );
      },
    );
  }
}
