const router = require('express').Router();
const routineController = require('../controllers/routineController');

router.post('/add', routineController.addToRoutine);
router.get('/', routineController.getRoutineByDay);
router.post('/remove', routineController.removeFromRoutine);

module.exports = router;