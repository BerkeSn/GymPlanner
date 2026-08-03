const db = require('../models')
const { Op } = require('sequelize')

const ACTIVITY_MULTIPLIERS = {
  sedentary: 1.2,
  light: 1.375,
  moderate: 1.55,
  active: 1.725
}

const GOAL_ADJUSTMENTS = {
  'Lose Weight': -500,
  'Gain Muscle': 300,
  'Maintain': 0,
  'Improve Endurance': 0
}

function calculateAge (birthdate) {
  const today = new Date()
  const birth = new Date(birthdate)
  let age = today.getFullYear() - birth.getFullYear()
  const monthDiff = today.getMonth() - birth.getMonth()
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
    age--
  }
  return age
}

function calculateBMR ({ gender, weight, height, age }) {
  const maleBMR = 10 * weight + 6.25 * height - 5 * age + 5
  const femaleBMR = 10 * weight + 6.25 * height - 5 * age - 161
  if (gender === 'male') return maleBMR
  if (gender === 'female') return femaleBMR
  return (maleBMR + femaleBMR) / 2
}

exports.getTarget = async (req, res) => {
  try {
    const userId = req.user.id
    const user = await db.User.findByPk(userId)

    if (!user.birthdate) {
      return res.status(400).json({
        success: false,
        message: 'Kalori hesabı için önce profilinden doğum tarihini gir.'
      })
    }

    const latestMeasurement = await db.BodyMeasurement.findOne({
      where: { userId },
      order: [['date', 'DESC']]
    })

    if (!latestMeasurement) {
      return res.status(400).json({
        success: false,
        message: 'Kalori hesabı için önce bir vücut ölçümü ekle (boy/kilo).'
      })
    }

    const settings = await db.CalorieSettings.findOne({ where: { userId } })
    const activityLevel = settings?.activityLevel || 'moderate'

    const age = calculateAge(user.birthdate)
    const bmr = calculateBMR({
      gender: user.gender,
      weight: latestMeasurement.weight,
      height: latestMeasurement.height,
      age
    })

    const tdee = bmr * ACTIVITY_MULTIPLIERS[user.activityLevel]
    const adjustment = GOAL_ADJUSTMENTS[user.goal] || 0 
    const targetCalories = Math.round(tdee + adjustment)

    res.status(200).json({
      success: true,
      target: {
        bmr: Math.round(bmr),
        tdee: Math.round(tdee),
        goal: latestMeasurement.goal,
        activityLevel,
        targetCalories
      }
    })
  } catch (error) {
    console.error('Get Calorie Target Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

exports.getSettings = async (req, res) => {
  try {
    const userId = req.user.id
    const settings = await db.CalorieSettings.findOne({ where: { userId } })
    res.status(200).json({ success: true, activityLevel: settings?.activityLevel || 'moderate' })
  } catch (error) {
    res.status(500).json({ success: false, error: error.message })
  }
}

exports.updateSettings = async (req, res) => {
  try {
    const userId = req.user.id
    const { activityLevel } = req.body

    if (!Object.keys(ACTIVITY_MULTIPLIERS).includes(activityLevel)) {
      return res.status(400).json({ success: false, message: 'Geçersiz aktivite seviyesi.' })
    }

    const [settings] = await db.CalorieSettings.findOrCreate({
      where: { userId },
      defaults: { activityLevel }
    })
    if (settings.activityLevel !== activityLevel) {
      settings.activityLevel = activityLevel
      await settings.save()
    }

    res.status(200).json({ success: true, activityLevel: settings.activityLevel })
  } catch (error) {
    console.error('Update Calorie Settings Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

exports.logEntry = async (req, res) => {
  try {
    const userId = req.user.id
    const { date, calories } = req.body

    if (calories === undefined || calories === null) {
      return res.status(400).json({ success: false, message: 'Kalori miktarı zorunludur.' })
    }

    const entryDate = date || new Date().toISOString().split('T')[0]

    const [entry] = await db.CalorieEntry.findOrCreate({
      where: { userId, date: entryDate },
      defaults: { calories }
    })
    if (entry.calories !== calories) {
      entry.calories = calories
      await entry.save()
    }

    res.status(200).json({ success: true, entry })
  } catch (error) {
    console.error('Log Calorie Entry Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

exports.getEntries = async (req, res) => {
  try {
    const userId = req.user.id
    const days = parseInt(req.query.days) || 30

    const fromDate = new Date()
    fromDate.setDate(fromDate.getDate() - days)

    const entries = await db.CalorieEntry.findAll({
      where: {
        userId,
        date: { [Op.gte]: fromDate.toISOString().split('T')[0] }
      },
      order: [['date', 'ASC']]
    })

    res.status(200).json({ success: true, entries })
  } catch (error) {
    console.error('Get Calorie Entries Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}