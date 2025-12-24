const router = require('express').Router();
const friendshipController = require('../controllers/friendshipController');
const messageController = require('../controllers/messageController');

// Arkadaşlık
router.post('/friend-request', friendshipController.sendRequest);
router.post('/accept-request', friendshipController.acceptRequest);
router.get('/friends/:userId', friendshipController.getFriends);

// Mesaj
router.post('/message', messageController.sendMessage);
router.get('/conversation', messageController.getConversation);

module.exports = router;