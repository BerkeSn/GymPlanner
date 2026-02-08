const express = require('express');
const router = express.Router();
const equipmentRoute = require('../controllers/equipmentController');
const auth = require('../middleware/authMiddleware');
const { authLimiter } = require('../middleware/limiter');

router.post(
    '/createEquipment',
    auth,
    // authLimiter,
    equipmentRoute.createEquipment
);

router.get(
    '/getAllEquipment',
    auth,
    // authLimiter,
    equipmentRoute.getAllEquipment
);


module.exports = router;