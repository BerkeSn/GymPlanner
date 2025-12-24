const express = require('express');
const router = express.Router();
const exerciseController = require('../controllers/exerciseController');
const checkAuth = require('../middleware/authMiddleware'); 

router.post('/', checkAuth, exerciseController.createExercise);
router.get('/', exerciseController.getAllExercises); 
router.get('/:id', exerciseController.getExerciseById); 

module.exports = router;