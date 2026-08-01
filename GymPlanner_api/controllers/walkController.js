const db = require('../models')

exports.logWalk = async (req, res) => {
  try {
    const userId = req.user.id
    const { startTime, endTime, durationSeconds, distanceMeters, steps, calories, routePoints } =
      req.body

    if (!startTime || !endTime || durationSeconds === undefined) {
      return res.status(400).json({
        success: false,
        message: 'startTime, endTime ve durationSeconds zorunludur.'
      })
    }

    const walk = await db.WalkSession.create({
      userId,
      startTime,
      endTime,
      durationSeconds,
      distanceMeters: distanceMeters || 0,
      steps: steps || 0,
      calories: calories || 0,
      routePoints: routePoints || []
    })

    res.status(201).json({ success: true, walk })
  } catch (error) {
    console.error('Log Walk Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

exports.getWalkHistory = async (req, res) => {
  try {
    const userId = req.user.id
    const walks = await db.WalkSession.findAll({
      where: { userId },
      attributes: ['id', 'startTime', 'durationSeconds', 'distanceMeters', 'steps', 'calories'],
      order: [['startTime', 'DESC']]
    })
    res.status(200).json({ success: true, walks })
  } catch (error) {
    console.error('Get Walk History Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

exports.getWalkById = async (req, res) => {
  try {
    const userId = req.user.id
    const { id } = req.params

    const walk = await db.WalkSession.findOne({ where: { id, userId } })
    if (!walk) {
      return res.status(404).json({ success: false, message: 'Yürüyüş bulunamadı.' })
    }

    res.status(200).json({ success: true, walk })
  } catch (error) {
    console.error('Get Walk By Id Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}