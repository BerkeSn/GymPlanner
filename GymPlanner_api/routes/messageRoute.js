const express = require('express')
const router = express.Router()
const messageRoute = require('../controllers/messageController')
const auth = require('../middleware/authMiddleware')

router.post('/startConversation/:friendId', auth, messageRoute.startConversation)
router.get('/getConversations', auth, messageRoute.getConversations)
router.get('/getMessages/:conversationId', auth, messageRoute.getMessages)
router.post('/sendMessage/:conversationId', auth, messageRoute.sendMessage)
router.post('/markAsRead/:conversationId', auth, messageRoute.markAsRead)

module.exports = router