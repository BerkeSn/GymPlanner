const db = require('../models')
const { Op } = require('sequelize')

exports.createMeal = async (req, res) => {
  try {
    const userId = req.user.id
    const { date, mealType, name, servingWeight, calories, protein, carbs, fats } =
      req.body

    if (!name || calories === undefined || calories === null) {
      return res.status(400).json({
        success: false,
        message: 'Öğün adı ve kalori zorunludur.'
      })
    }

    const entryDate = date || new Date().toISOString().split('T')[0]

    const meal = await db.MealEntry.create({
      userId,
      date: entryDate,
      mealType: mealType || 'Snack',
      name,
      servingWeight,
      calories,
      protein: protein || 0,
      carbs: carbs || 0,
      fats: fats || 0
    })

    res.status(201).json({ success: true, meal })
  } catch (error) {
    console.error('Create Meal Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

exports.getMealsByDate = async (req, res) => {
  try {
    const userId = req.user.id
    const date = req.query.date || new Date().toISOString().split('T')[0]

    const meals = await db.MealEntry.findAll({
      where: { userId, date },
      order: [['createdAt', 'ASC']]
    })

    const summary = meals.reduce(
      (acc, m) => ({
        totalCalories: acc.totalCalories + m.calories,
        totalProtein: acc.totalProtein + (m.protein || 0),
        totalCarbs: acc.totalCarbs + (m.carbs || 0),
        totalFats: acc.totalFats + (m.fats || 0)
      }),
      { totalCalories: 0, totalProtein: 0, totalCarbs: 0, totalFats: 0 }
    )

    res.status(200).json({ success: true, date, meals, summary })
  } catch (error) {
    console.error('Get Meals Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

exports.getCalorieTrend = async (req, res) => {
  try {
    const userId = req.user.id
    const days = parseInt(req.query.days) || 30

    const fromDate = new Date()
    fromDate.setDate(fromDate.getDate() - days)

    const meals = await db.MealEntry.findAll({
      where: {
        userId,
        date: { [Op.gte]: fromDate.toISOString().split('T')[0] }
      },
      order: [['date', 'ASC']]
    })

    const grouped = {}
    meals.forEach(m => {
      grouped[m.date] = (grouped[m.date] || 0) + m.calories
    })

    const trend = Object.entries(grouped).map(([date, totalCalories]) => ({
      date,
      totalCalories
    }))

    res.status(200).json({ success: true, trend })
  } catch (error) {
    console.error('Get Calorie Trend Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

exports.deleteMeal = async (req, res) => {
  try {
    const userId = req.user.id
    const { id } = req.params

    const meal = await db.MealEntry.findOne({ where: { id, userId } })
    if (!meal) {
      return res.status(404).json({ success: false, message: 'Öğün bulunamadı.' })
    }

    await meal.destroy()
    res.status(200).json({ success: true, message: 'Öğün silindi.' })
  } catch (error) {
    console.error('Delete Meal Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}