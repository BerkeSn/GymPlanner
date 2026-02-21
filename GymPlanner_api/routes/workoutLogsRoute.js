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

module.exports = router
