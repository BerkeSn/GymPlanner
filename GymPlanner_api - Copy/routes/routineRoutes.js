const router = require('express').Router();
const routineController = require('../controllers/routineController');
const checkAuth = require('../middleware/authMiddleware');

// Her rotanın arasına 'checkAuth' ekledik
router.post('/add', checkAuth, routineController.addToRoutine);
router.get('/', checkAuth, routineController.getRoutineByDay);
router.put('/update-exercise', checkAuth, routineController.updateRoutineExercise);
router.post('/remove', checkAuth, routineController.removeFromRoutine);

module.exports = router;