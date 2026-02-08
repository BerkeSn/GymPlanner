const express = require('express');
const router = express.Router();
const routineExerciseRoute = require('../controllers/routineExerciseController');
const auth = require('../middleware/authMiddleware');
const { authLimiter } = require('../middleware/limiter');

router.post(
    '/addExerciseToRoutine/:routineId',
    auth,
    // authLimiter,
    routineExerciseRoute.addExerciseToRoutine
);

router.get(
    '/getExercisesByRoutineId/:routineId',
    auth,
    routineExerciseRoute.getExercisesByRoutineId
);


module.exports = router;