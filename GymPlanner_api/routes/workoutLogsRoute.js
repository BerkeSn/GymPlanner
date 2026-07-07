const express = require('express')
const router = express.Router()
const workoutLogsRoute = require('../controllers/workoutLogsController')
const auth = require('../middleware/authMiddleware')
const { authLimiter } = require('../middleware/limiter')

router.get(
  '/getWorkoutLogs',
  auth,
  // authLimiter,
  workoutLogsRoute.getWorkoutLogs
)

router.get(
  '/getWorkoutLogById/:id',
  auth,
  // authLimiter,
  workoutLogsRoute.getWorkoutLogById
)

router.post(
  '/createWorkoutLog/:workoutRoutineId',
  auth,
  // authLimiter,
  workoutLogsRoute.createWorkoutLog
)
router.post(
  '/updateWorkoutLog/:id',
  auth,
  // authLimiter,
  workoutLogsRoute.updateWorkoutLog
)
router.put(
  '/deleteWorkoutLog/:id',
  auth,
  // authLimiter,
  workoutLogsRoute.deleteWorkoutLog
)

router.post(
  '/startWorkoutLog/:workoutRoutineId',
  auth,
  // authLimiter,
  workoutLogsRoute.startWorkoutLog
)

router.post(
  '/addSetToWorkoutLog/:workoutLogId',
  auth,
  // authLimiter,
  workoutLogsRoute.addSetToWorkoutLog
)

router.delete(
  '/removeSetFromWorkoutLog/:workoutLogId/:setId',
  auth,
  // authLimiter,
  workoutLogsRoute.removeSetFromWorkoutLog
)

router.get(
  '/getExerciseProgress/:exerciseId',
  auth,
  // authLimiter,
  workoutLogsRoute.getExerciseProgress
)

module.exports = router
