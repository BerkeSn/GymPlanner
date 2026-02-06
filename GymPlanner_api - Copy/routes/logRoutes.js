const router = require('express').Router();
const logController = require('../controllers/logController');
const checkAuth = require('../middleware/authMiddleware');

router.post('/', checkAuth, logController.createLog);
router.get('/history', checkAuth, logController.getLogsByExercise);
router.delete('/:id', checkAuth, logController.deleteLog);

module.exports = router;