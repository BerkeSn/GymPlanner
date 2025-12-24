const router = require('express').Router();
const logController = require('../controllers/logController');

router.post('/', logController.createLog);
router.get('/history', logController.getLogsByExercise);

module.exports = router;