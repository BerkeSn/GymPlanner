const express = require('express')
const router = express.Router()
const walkController = require('../controllers/walkController')
const auth = require('../middleware/authMiddleware')

router.post('/logWalk', auth, walkController.logWalk)
router.get('/getWalkHistory', auth, walkController.getWalkHistory)
router.get('/getWalkById/:id', auth, walkController.getWalkById)

module.exports = router