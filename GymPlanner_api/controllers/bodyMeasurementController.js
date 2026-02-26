const db = require('../models')

exports.getAllBodyMeasurements = async (req, res) => {
  try {
    const userId = req.user.id
    const bodyMeasurements = await db.BodyMeasurement.findAll({
      where: { userId },
      order: [['date', 'DESC']]
    })
    res.json({
      success: true,
      bodyMeasurements,
      message: 'Body measurements retrieved successfully.'
    })
  } catch (error) {
    console.error('Error fetching body measurements:', error)
    res.status(500).json({
      success: false,
      error: 'An error occurred while fetching body measurements.'
    })
  }
}

exports.createMeasurement = async (req, res) => {
  try {
    const userId = req.user.id

    const {
      date,
      weight,
      height,
      neck,
      waist,
      bodyFatPercentage,
      muscleMass,
      goal
    } = req.body

    if (!weight || !height) {
      return res.status(400).json({
        success: false,
        message: 'Boy ve Kilo zorunludur!'
      })
    }

    const measurementDate = date || new Date().toISOString().split('T')[0]

    const newMeasurement = await db.BodyMeasurement.create({
      userId,
      date: measurementDate,
      weight,
      height,
      neck,
      waist,
      bodyFatPercentage,
      muscleMass,
      goal: goal || 'Maintain'
    })

    res.status(201).json({
      success: true,
      message: 'Ölçümler başarıyla kaydedildi!',
      measurement: newMeasurement
    })
  } catch (error) {
    console.error('Create Measurement Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

exports.updateBodyMeasurement = async (req, res) => {
  try {
    const userId = req.user.id
    const measurementId = req.params.id
    const {
      date,
      weight,
      height,
      neck,
      waist,
      bodyFatPercentage,
      muscleMass,
      goal
    } = req.body

    const measurement = await db.BodyMeasurement.findOne({
      where: { id: measurementId, userId }
    })

    if (!measurement) {
      return res.status(404).json({
        success: false,
        message: 'Ölçüm kaydı bulunamadı veya sana ait değil.'
      })
    }

    await measurement.update({
      date: date || measurement.date,
      weight: weight || measurement.weight,
      height: height || measurement.height,
      neck: neck || measurement.neck,
      waist: waist || measurement.waist,
      bodyFatPercentage: bodyFatPercentage || measurement.bodyFatPercentage,
      muscleMass: muscleMass || measurement.muscleMass,
      goal: goal || measurement.goal
    })

    res.status(200).json({
      success: true,
      message: 'Vücut ölçüleri başarıyla güncellendi.',
      measurement
    })
  } catch (error) {
    console.error('Update Measurement Hatası:', error)
    res.status(500).json({
      success: false,
      error: 'Ölçümler güncellenirken bir hata oluştu.'
    })
  }
}

exports.deleteMeasurement = async (req, res) => {
  try {
    const userId = req.user.id
    const { id } = req.params

    const measurement = await db.BodyMeasurement.findOne({
      where: { id, userId }
    })
    if (!measurement) {
      return res
        .status(404)
        .json({ success: false, message: 'Measurement not found.' })
    }

    await measurement.destroy()
    res.json({ success: true, message: 'Measurement deleted successfully.' })
  } catch (error) {
    console.error('Delete Measurement Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}
