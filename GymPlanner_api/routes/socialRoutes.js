const router = require('express').Router();
const friendshipController = require('../controllers/friendshipController');
const messageController = require('../controllers/messageController');
const checkAuth = require('../middleware/authMiddleware');

// --- Arkadaşlık İşlemleri ---
router.post('/friend-request', checkAuth, friendshipController.sendRequest);
router.post('/accept-request', checkAuth, friendshipController.acceptRequest);
router.get('/friends/:userId', checkAuth, friendshipController.getFriends);

// --- Mesajlaşma İşlemleri ---
router.post('/message', checkAuth, messageController.sendMessage);
router.get('/conversation', checkAuth, messageController.getConversation);

module.exports = router;