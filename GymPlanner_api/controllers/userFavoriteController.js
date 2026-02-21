const db = require('../models')

exports.toggleFavorite = async (req, res) => {
  try {
    const userId = req.user.id
    const exerciseId = req.params.exerciseId

    const exercise = await db.Exercise.findByPk(exerciseId)
    if (!exercise) {
      return res
        .status(404)
        .json({ success: false, message: 'Böyle bir hareket bulunamadı Boss.' })
    }

    const existingFavorite = await db.UserFavorite.findOne({
      where: { userId, exerciseId }
    })

    if (existingFavorite) {
      await existingFavorite.destroy()
      return res.status(200).json({
        success: true,
        isFavorite: false,
        message: 'Hareket favorilerden çıkarıldı.'
      })
    } else {
      await db.UserFavorite.create({ userId, exerciseId })
      return res.status(201).json({
        success: true,
        isFavorite: true,
        message: 'Hareket favorilere eklendi! ⭐'
      })
    }
  } catch (error) {
    console.error('Toggle Favorite Hatası:', error)
    res.status(500).json({
      success: false,
      error: 'Favori işlemi sırasında bir hata oluştu.'
    })
  }
}

exports.getMyFavorites = async (req, res) => {
  try {
    const userId = req.user.id

    const favorites = await db.UserFavorite.findAll({
      where: { userId },
      include: [
        {
          model: db.Exercise,
          as: 'exercise'
        }
      ],
      order: [['createdAt', 'DESC']]
    })

    res.status(200).json({
      success: true,
      count: favorites.length,
      favorites,
      message: 'Favorilerin başarıyla getirildi Kanka.'
    })
  } catch (error) {
    console.error('Get Favorites Hatası:', error)
    res.status(500).json({
      success: false,
      error: 'Favoriler getirilirken bir hata oluştu.'
    })
  }
}
