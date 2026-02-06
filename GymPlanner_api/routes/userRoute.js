const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const auth = require('../middleware/authMiddleware');
const { authLimiter } = require('../middleware/limiter');

router.post(
    '/register',
    authLimiter,
    userController.register
);
router.post(
    '/login',
    authLimiter,
    userController.login
);
router.put(
    '/update/',
    auth,
    userController.updateProfile
);

module.exports = router;