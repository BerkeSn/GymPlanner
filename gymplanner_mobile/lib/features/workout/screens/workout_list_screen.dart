import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/features/workout/providers/workout_provider.dart';
import 'package:gymplanner_mobile/features/workout/screens/workout_detail_screen.dart';

class WorkoutListScreen
    extends ConsumerStatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  ConsumerState<WorkoutListScreen>
  createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState
    extends ConsumerState<WorkoutListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(workoutProvider.notifier)
          .getRoutines();
    });
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => _CreateRoutineDialog(
        onSave: (name, description, isActive) {
          ref
              .read(workoutProvider.notifier)
              .createRoutine(
                name: name,
                description: description ?? '',
                isActive: isActive,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Programlarım'),
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_routine',
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(WorkoutState state) {
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

    if (state.routines.isEmpty) {
      return const Center(
        child: Text('Henüz program yok'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.routines.length,
      itemBuilder: (context, index) {
        final routine = state.routines[index];

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      WorkoutDetailScreen(
                    routineId: routine.id,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          routine.name,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium,
                        ),
                      ),
                      Switch(
                        value: routine.isActive,
                        onChanged: (value) {
                          ref
                              .read(
                                workoutProvider
                                    .notifier,
                              )
                              .updateRoutine(
                                id: routine.id,
                                isActive: value,
                              );
                        },
                      ),
                    ],
                  ),
                  if (routine.description != null)
                    Text(
                      routine.description!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      Text(
                        '${routine.exercises.length} egzersiz',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) =>
                                _EditRoutineDialog(
                                  routineId:
                                      routine.id,
                                  initialName:
                                      routine.name,
                                  initialDescription:
                                      routine
                                          .description,
                                  initialIsActive:
                                      routine.isActive,
                                  onSave: (
                                    id,
                                    name,
                                    description,
                                    isActive,
                                  ) {
                                    ref
                                        .read(
                                          workoutProvider
                                              .notifier,
                                        )
                                        .updateRoutine(
                                          id: id,
                                          name: name,
                                          description:
                                              description,
                                          isActive:
                                              isActive,
                                        );
                                  },
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CreateRoutineDialog
    extends StatefulWidget {
  final Function(
    String name,
    String? description,
    bool isActive,
  )
  onSave;

  const _CreateRoutineDialog({
    required this.onSave,
  });

  @override
  State<_CreateRoutineDialog> createState() =>
      _CreateRoutineDialogState();
}

class _CreateRoutineDialogState
    extends State<_CreateRoutineDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isActive = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final description = _descController.text
        .trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Program adı boş olamaz'),
        ),
      );
      return;
    }

    widget.onSave(
      name,
      description.isEmpty ? null : description,
      _isActive,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Program'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Program Adı',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
              ),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('Aktif mi?'),
                Switch(
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}

class _EditRoutineDialog
    extends StatefulWidget {
  final int routineId;
  final String initialName;
  final String? initialDescription;
  final bool initialIsActive;
  final Function(
    int id,
    String name,
    String? description,
    bool isActive,
  )
  onSave;

  const _EditRoutineDialog({
    required this.routineId,
    required this.initialName,
    required this.initialDescription,
    required this.initialIsActive,
    required this.onSave,
  });

  @override
  State<_EditRoutineDialog> createState() =>
      _EditRoutineDialogState();
}

class _EditRoutineDialogState
    extends State<_EditRoutineDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _descController.text =
        widget.initialDescription ?? '';
    _isActive = widget.initialIsActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final description = _descController.text
        .trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Program adı boş olamaz'),
        ),
      );
      return;
    }

    widget.onSave(
      widget.routineId,
      name,
      description.isEmpty ? null : description,
      _isActive,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Programı Düzenle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Program Adı',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
              ),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('Aktif mi?'),
                Switch(
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
