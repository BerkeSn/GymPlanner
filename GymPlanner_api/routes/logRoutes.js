const router = require('express').Router();
const logController = require('../controllers/logController');

router.post('/', logController.createLog);
router.get('/history', logController.getLogsByExercise);
router.delete('/:id', logController.deleteLog);

module.exports = router;