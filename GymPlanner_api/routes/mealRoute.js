const express = require('express')
const router = express.Router()
const mealController = require('../controllers/mealController')
const auth = require('../middleware/authMiddleware')

router.post('/createMeal', auth, mealController.createMeal)
router.get('/getMealsByDate', auth, mealController.getMealsByDate)
router.get('/getCalorieTrend', auth, mealController.getCalorieTrend)
router.delete('/deleteMeal/:id', auth, mealController.deleteMeal)

module.exports = router