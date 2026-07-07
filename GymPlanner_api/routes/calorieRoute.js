const express = require('express')
const router = express.Router()
const calorieController = require('../controllers/calorieController')
const auth = require('../middleware/authMiddleware')

router.get('/getTarget', auth, calorieController.getTarget)
router.get('/getSettings', auth, calorieController.getSettings)
router.post('/updateSettings', auth, calorieController.updateSettings)
router.post('/logEntry', auth, calorieController.logEntry)
router.get('/getEntries', auth, calorieController.getEntries)

module.exports = router