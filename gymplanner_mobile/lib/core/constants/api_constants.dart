class ApiConstants {
  ApiConstants._();

  // --- Geliştirme Ortamı ---
  // Emülatörde test ediyorsan     → 10.0.2.2
  // Gerçek telefonda test ediyorsan → 192.168.1.X (kendi IP'n)
  // Deploy ettikten sonra         → https://your-domain.com

  static const String baseUrl =
      'https://gymplanner-80ny.onrender.com/api/';

  // --- Auth ---
  static const String register = '/user/register';
  static const String login = '/user/login';
  static const String updateProfile =
      '/user/update';
  static const String getProfile =
      '/user/getProfile';

  // --- Arkadaşlık ---
  static const String addFriend =
      '/user/addFriend';
  static const String respondToRequest =
      '/user/respondToRequest';
  static const String getMyFriends =
      '/user/getMyFriends';
  static const String getPendingRequests =
      '/user/getPendingRequests';
  static const String searchUsers =
      '/user/searchUsers';

  // --- Egzersizler ---
  static const String getAllExercises =
      '/exercise/getAllExercises';
  static const String getExerciseById =
      '/exercise/getExerciseById';
  static const String getExercisesByMuscleGroup =
      '/exercise/getExercisesByMuscleGroup';
  static const String getExercisesByEquipment =
      '/exercise/getExercisesByEquipment';

  // --- Kas Grupları ---
  static const String getAllMuscleGroups =
      '/musclegroup/getAllMuscleGroups';

  // --- Ekipmanlar ---
  static const String getAllEquipment =
      '/equipment/getAllEquipment';

  // --- Workout Rutinleri ---
  static const String createWorkoutRoutine =
      '/workoutroutine/createWorkoutRoutine';
  static const String getWorkoutRoutines =
      '/workoutroutine/getWorkoutRoutines';
  static const String getWorkoutRoutineById =
      '/workoutroutine/getWorkoutRoutineById';
  static const String updateWorkoutRoutine =
      '/workoutroutine/updateWorkoutRoutine';
  static const String deleteWorkoutRoutine =
      '/workoutroutine/deleteWorkoutRoutine';

  // --- Rutin Egzersizleri ---
  static const String addExerciseToRoutine =
      '/routineexercise/addExerciseToRoutine';
  static const String getExercisesByRoutineId =
      '/routineexercise/getExercisesByRoutineId';
  static const String deleteRoutineExercise =
      '/routineexercise/deleteRoutineExercise';
  static const String updateRoutineExercise =
      '/routineexercise/updateRoutineExercise';

  // --- Antrenman Logları ---
  static const String createWorkoutLog =
      '/workoutlogs/createWorkoutLog';
  static const String getWorkoutLogs =
      '/workoutlogs/getWorkoutLogs';
  static const String getWorkoutLogById =
      '/workoutlogs/getWorkoutLogById';
  static const String updateWorkoutLog =
      '/workoutlogs/updateWorkoutLog';
  static const String deleteWorkoutLog =
      '/workoutlogs/deleteWorkoutLog';

  // --- Vücut Ölçümleri ---
  static const String createMeasurement =
      '/bodymeasurement/createMeasurement';
  static const String getAllBodyMeasurements =
      '/bodymeasurement/getAllBodyMeasurements';
  static const String updateMeasurement =
      '/bodymeasurement/updateMeasurement';
  static const String deleteMeasurement =
      '/bodymeasurement/deleteMeasurement';

  // --- Favoriler ---
  static const String toggleFavorite =
      '/userfavorite/toggleFavorite';
  static const String getMyFavorites =
      '/userfavorite/getMyFavorites';
  // --- Mesajlaşma ---
  static const String startConversation =
      '/message/startConversation';
  static const String getConversations =
      '/message/getConversations';
  static const String getMessages =
      '/message/getMessages';
  static const String sendMessage =
      '/message/sendMessage';
  static const String markAsRead =
      '/message/markAsRead';

  // --- Antrenman Oturumu (Progressive Overload) ---
  static const String startWorkoutLog =
      '/workoutlogs/startWorkoutLog';
  static const String addSetToWorkoutLog =
      '/workoutlogs/addSetToWorkoutLog';
  static const String removeSetFromWorkoutLog =
      '/workoutlogs/removeSetFromWorkoutLog';
  static const String getExerciseProgress =
      '/workoutlogs/getExerciseProgress';

  // --- Kalori Takibi ---
  static const String getCalorieTarget =
      '/calorie/getTarget';
  static const String getCalorieSettings =
      '/calorie/getSettings';
  static const String updateCalorieSettings =
      '/calorie/updateSettings';
  static const String logCalorieEntry =
      '/calorie/logEntry';
  static const String getCalorieEntries =
      '/calorie/getEntries';
}
