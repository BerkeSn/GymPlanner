const express = require('express')
const router = express.Router()
const userController = require('../controllers/userController')
const auth = require('../middleware/authMiddleware')
const { authLimiter } = require('../middleware/limiter')

router.post('/register', authLimiter, userController.register)
router.post('/login', authLimiter, userController.login)
router.put('/update/', auth, userController.updateProfile)

router.post('/addFriend/:receiverId', auth, userController.addFriend)
router.post(
  '/respondToRequest/:friendshipId',
  auth,
  userController.respondToRequest
)
router.get('/getMyFriends', auth, userController.getMyFriends)
router.get('/getPendingRequests', auth, userController.getPendingRequests)

module.exports = router
