const express = require('express')
const router = express.Router()
const userFavoriteRoute = require('../controllers/userFavoriteController')
const auth = require('../middleware/authMiddleware')
const { authLimiter } = require('../middleware/limiter')

router.post(
  '/toggleFavorite/:exerciseId',
  auth,
  // authLimiter,
  userFavoriteRoute.toggleFavorite
)

router.get('/getMyFavorites', auth, userFavoriteRoute.getMyFavorites)

module.exports = router
