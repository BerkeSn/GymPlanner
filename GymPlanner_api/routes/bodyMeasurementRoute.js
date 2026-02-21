const express = require('express')
const router = express.Router()
const bodyMeasurementRoute = require('../controllers/bodyMeasurementController')
const auth = require('../middleware/authMiddleware')
const { authLimiter } = require('../middleware/limiter')

router.post(
  '/createMeasurement',
  auth,
  // authLimiter,
  bodyMeasurementRoute.createMeasurement
)

router.get(
  '/getAllBodyMeasurements',
  auth,
  // authLimiter,
  bodyMeasurementRoute.getAllBodyMeasurements
)

router.post(
  '/updateMeasurement/:id',
  auth,
  // authLimiter,
  bodyMeasurementRoute.updateBodyMeasurement
)

router.put(
  '/deleteMeasurement/:id',
  auth,
  // authLimiter,
  bodyMeasurementRoute.deleteMeasurement
)

module.exports = router
