const express = require('express');
const router = express.Router();
const exerciseRoute = require('../controllers/exerciseController');
const auth = require('../middleware/authMiddleware');
const { authLimiter } = require('../middleware/limiter');

router.post(
    '/createExercise',
    auth,
    // authLimiter,
    exerciseRoute.createExercise
);

router.get(
    '/getAllExercises',
    auth,
    // authLimiter,
    exerciseRoute.getAllExercises
);

router.get(
    '/getExercisesByMuscleGroup/:muscleGroupId',
    auth,
    // authLimiter,
    exerciseRoute.getExerciseByMuscleGroupId
);

router.get(
    '/getExercisesByEquipment/:equipmentId',
    auth,
    // authLimiter,
    exerciseRoute.getExerciseByEquipmentId
);

router.get(
    '/getExerciseById/:id',
    auth,
    // authLimiter,
    exerciseRoute.getExerciseById
);


module.exports = router;