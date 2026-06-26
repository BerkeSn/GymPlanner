import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/core/models/body_measurement_model.dart';
import 'package:gymplanner_mobile/core/models/workout_log_model.dart';
import 'package:gymplanner_mobile/core/models/workout_routine_model.dart';
import 'package:gymplanner_mobile/features/home/data/home_repository.dart';

class DashboardData {
  final WorkoutLogModel? lastWorkoutLog;
  final String? nextWorkoutDay;
  final int activeRoutineCount;
  final BodyMeasurementModel? lastMeasurement;

  DashboardData({
    required this.lastWorkoutLog,
    required this.nextWorkoutDay,
    required this.activeRoutineCount,
    required this.lastMeasurement,
  });
}

final homeRepositoryProvider =
    Provider<HomeRepository>((ref) {
      return HomeRepository();
    });

class HomeNotifier
    extends AsyncNotifier<DashboardData> {
  @override
  FutureOr<DashboardData> build() async {
    return _loadDashboardData();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      _loadDashboardData,
    );
  }

  Future<DashboardData>
  _loadDashboardData() async {
    final repository = ref.read(
      homeRepositoryProvider,
    );
    final data = await repository
        .getDashboardData();

    final workoutLogs = data.workoutLogs;
    final routines = data.routines;
    final measurements = data.measurements;

    return DashboardData(
      lastWorkoutLog: workoutLogs.isNotEmpty
          ? workoutLogs.first
          : null,
      nextWorkoutDay: _findNextWorkoutDay(
        routines,
      ),
      activeRoutineCount: routines.length,
      lastMeasurement: measurements.isNotEmpty
          ? measurements.first
          : null,
    );
  }

  String? _findNextWorkoutDay(
    List<WorkoutRoutineModel> routines,
  ) {
    final now = DateTime.now();
    DateTime? nearestDate;
    String? nearestDayLabel;

    for (final routine in routines) {
      for (final day in routine.days) {
        final weekday = _parseWeekday(day);
        if (weekday == null) {
          continue;
        }

        final nextDate = _nextDateForWeekday(
          now,
          weekday,
        );
        if (nearestDate == null ||
            nextDate.isBefore(nearestDate)) {
          nearestDate = nextDate;
          nearestDayLabel = day;
        }
      }
    }

    return nearestDayLabel;
  }

  DateTime _nextDateForWeekday(
    DateTime from,
    int targetWeekday,
  ) {
    final daysUntilTarget =
        (targetWeekday - from.weekday + 7) % 7;
    final daysToAdd = daysUntilTarget;
    final startOfDay = DateTime(
      from.year,
      from.month,
      from.day,
    );
    return startOfDay.add(
      Duration(days: daysToAdd),
    );
  }

  int? _parseWeekday(String day) {
    final normalized = day.trim().toLowerCase();

    switch (normalized) {
      case 'monday':
      case 'mon':
      case 'pazartesi':
      case '1':
        return DateTime.monday;
      case 'tuesday':
      case 'tue':
      case 'salı':
      case 'sali':
      case '2':
        return DateTime.tuesday;
      case 'wednesday':
      case 'wed':
      case 'çarşamba':
      case 'carsamba':
      case '3':
        return DateTime.wednesday;
      case 'thursday':
      case 'thu':
      case 'perşembe':
      case 'persembe':
      case '4':
        return DateTime.thursday;
      case 'friday':
      case 'fri':
      case 'cuma':
      case '5':
        return DateTime.friday;
      case 'saturday':
      case 'sat':
      case 'cumartesi':
      case '6':
        return DateTime.saturday;
      case 'sunday':
      case 'sun':
      case 'pazar':
      case '7':
      case '0':
        return DateTime.sunday;
      default:
        return null;
    }
  }
}

final homeProvider =
    AsyncNotifierProvider.autoDispose<
      HomeNotifier,
      DashboardData
    >(() {
      return HomeNotifier();
    });
