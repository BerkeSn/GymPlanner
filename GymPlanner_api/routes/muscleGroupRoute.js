const express = require('express');
const router = express.Router();
const muscleGroupRoutes = require('../controllers/muscleGroupController');
const auth = require('../middleware/authMiddleware');
const { authLimiter } = require('../middleware/limiter');

router.post(
    '/createMuscleGroup',
    auth,
    // authLimiter,
    muscleGroupRoutes.createMuscleGroup
);

router.get(
    '/getAllMuscleGroups',
    auth,
    // authLimiter,
    muscleGroupRoutes.getAllMuscleGroups
);


module.exports = router;