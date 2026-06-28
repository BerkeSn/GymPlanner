const express = require('express')
const router = express.Router()
const workoutRoutineRoute = require('../controllers/workoutRoutineController')
const auth = require('../middleware/authMiddleware')
const { authLimiter } = require('../middleware/limiter')

router.post(
  '/createWorkoutRoutine',
  auth,
  // authLimiter,
  workoutRoutineRoute.createWorkoutRoutine
)

router.get(
  '/getWorkoutRoutines',
  auth,
  // authLimiter,
  workoutRoutineRoute.getWorkoutRoutines
)

router.get(
  '/getWorkoutRoutineById/:id',
  auth,
  workoutRoutineRoute.getWorkoutRoutineById
)

router.post(
  '/updateWorkoutRoutine/:id',
  auth,
  workoutRoutineRoute.updateWorkoutRoutine
)

router.delete(
  '/deleteWorkoutRoutine/:id',
  auth,
  workoutRoutineRoute.deleteWorkoutRoutine
)

router.module.exports = router
