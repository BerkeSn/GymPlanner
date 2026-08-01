const db = require('../models')

exports.createWorkoutLog = async (req, res) => {
  try {
    const userId = req.user.id
    const workoutRoutineId = req.params.workoutRoutineId
    const { date, workoutSetLogs } = req.body

    if (!workoutRoutineId) {
      return res
        .status(400)
        .json({ success: false, error: 'workoutRoutineId is required' })
    }

    const workoutLog = await db.WorkoutLog.create({
      date: date || new Date(),
      workoutRoutineId: workoutRoutineId,
      userId
    })

    if (
      workoutSetLogs &&
      Array.isArray(workoutSetLogs) &&
      workoutSetLogs.length > 0
    ) {
      const setsWithLogId = workoutSetLogs.map(set => ({
        ...set,
        workoutLogId: workoutLog.id
      }))

      await db.WorkoutSetLog.bulkCreate(setsWithLogId)
    }

    res.status(201).json({ workoutLog, workoutSetLogs })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
}

exports.getWorkoutLogs = async (req, res) => {
  try {
    const userId = req.user.id

    const workoutLogs = await db.WorkoutLog.findAll({
      where: { userId },
      include: [
        {
          model: db.WorkoutSetLog,
          as: 'workoutSetLogs',
          include: [{ model: db.Exercise, as: 'exercise' }]
        },
        {
          model: db.WorkoutRoutine,
          as: 'workoutRoutine'
        }
      ],
      order: [['date', 'DESC']]
    })
    res.json(workoutLogs)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
}

exports.getWorkoutLogById = async (req, res) => {
  try {
    const userId = req.user.id
    const workoutLogId = req.params.id

    const workoutLog = await db.WorkoutLog.findOne({
      where: { id: workoutLogId, userId },
      include: [
        {
          model: db.WorkoutSetLog,
          as: 'workoutSetLogs',
          include: [{ model: db.Exercise, as: 'exercise' }]
        },
        {
          model: db.WorkoutRoutine,
          as: 'workoutRoutine'
        }
      ]
    })
    if (!workoutLog) {
      return res.status(404).json({ error: 'Workout log not found' })
    }
    res.json(workoutLog)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
}

exports.deleteWorkoutLog = async (req, res) => {
  try {
    const userId = req.user.id
    const workoutLogId = req.params.id

    const workoutLog = await db.WorkoutLog.findOne({
      where: { id: workoutLogId, userId }
    })
    if (!workoutLog) {
      return res.status(404).json({ error: 'Workout log not found' })
    }

    await workoutLog.destroy()
    res.status(200).json({ message: 'Workout log deleted successfully' })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
}

exports.updateWorkoutLog = async (req, res) => {
  try {
    const userId = req.user.id
    const workoutLogId = req.params.id
    const { date, workoutSetLogs } = req.body

    const workoutLog = await db.WorkoutLog.findOne({
      where: { id: workoutLogId, userId }
    })

    if (!workoutLog) {
      return res.status(404).json({ error: 'Workout log not found' })
    }

    if (date) {
      workoutLog.date = date
    }

    if (workoutSetLogs && Array.isArray(workoutSetLogs)) {
      await db.WorkoutSetLog.destroy({ where: { workoutLogId } })
      const setsWithLogId = workoutSetLogs.map(set => ({
        ...set,
        workoutLogId
      }))
      await db.WorkoutSetLog.bulkCreate(setsWithLogId)
    }

    await workoutLog.save()
    res.json({ workoutLog, workoutSetLogs })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
}

// YENİ: Antrenman oturumu başlat (serbest akış — hareket sırası yok)
exports.startWorkoutLog = async (req, res) => {
  try {
    const userId = req.user.id
    const { workoutRoutineId } = req.params

    const routine = await db.WorkoutRoutine.findOne({
      where: { id: workoutRoutineId, userId }
    })
    if (!routine) {
      return res
        .status(404)
        .json({ success: false, message: 'Program bulunamadı.' })
    }

    const workoutLog = await db.WorkoutLog.create({
      date: new Date(),
      workoutRoutineId,
      userId
    })

    res.status(201).json({ success: true, workoutLog })
  } catch (error) {
    console.error('Start Workout Log Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

// YENİ: Antrenman sırasında tek bir set anlık kaydet
exports.addSetToWorkoutLog = async (req, res) => {
  try {
    const userId = req.user.id
    const { workoutLogId } = req.params
    const { exerciseId, setNumber, reps, weight } = req.body

    if (!exerciseId || !setNumber || reps === undefined || weight === undefined) {
      return res.status(400).json({
        success: false,
        message: 'exerciseId, setNumber, reps ve weight zorunludur.'
      })
    }

    const workoutLog = await db.WorkoutLog.findOne({
      where: { id: workoutLogId, userId }
    })
    if (!workoutLog) {
      return res
        .status(404)
        .json({ success: false, message: 'Antrenman oturumu bulunamadı.' })
    }

    const setLog = await db.WorkoutSetLog.create({
      workoutLogId,
      exerciseId,
      setNumber,
      reps,
      weight
    })

    res.status(201).json({ success: true, setLog })
  } catch (error) {
    console.error('Add Set Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

// YENİ: Yanlış girilen bir seti geri al
exports.removeSetFromWorkoutLog = async (req, res) => {
  try {
    const userId = req.user.id
    const { workoutLogId, setId } = req.params

    const workoutLog = await db.WorkoutLog.findOne({
      where: { id: workoutLogId, userId }
    })
    if (!workoutLog) {
      return res
        .status(404)
        .json({ success: false, message: 'Antrenman oturumu bulunamadı.' })
    }

    const setLog = await db.WorkoutSetLog.findOne({
      where: { id: setId, workoutLogId }
    })
    if (!setLog) {
      return res.status(404).json({ success: false, message: 'Set bulunamadı.' })
    }

    await setLog.destroy()
    res.status(200).json({ success: true, message: 'Set silindi.' })
  } catch (error) {
    console.error('Remove Set Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

// YENİ: Bir harekete ait tüm geçmiş — grafik + takvim ekranı için
exports.getExerciseProgress = async (req, res) => {
  try {
    const userId = req.user.id
    const { exerciseId } = req.params

    const setLogs = await db.WorkoutSetLog.findAll({
      where: { exerciseId },
      include: [
        {
          model: db.WorkoutLog,
          as: 'workoutLog',
          where: { userId },
          attributes: ['id', 'date']
        }
      ]
    })

    const grouped = {}
    setLogs.forEach(log => {
      const logId = log.workoutLog.id
      if (!grouped[logId]) {
        grouped[logId] = {
          workoutLogId: logId,
          date: log.workoutLog.date,
          sets: []
        }
      }
      grouped[logId].sets.push({
        id: log.id,
        setNumber: log.setNumber,
        reps: log.reps,
        weight: log.weight
      })
    })

    const history = Object.values(grouped).map(entry => {
      const weights = entry.sets.map(s => s.weight)
      const maxWeight = Math.max(...weights)
      const totalVolume = entry.sets.reduce((sum, s) => sum + s.reps * s.weight, 0)
      // Epley formülü: 1RM = ağırlık * (1 + tekrar/30)
      const estimated1RM = Math.max(
        ...entry.sets.map(s => s.weight * (1 + s.reps / 30))
      )
      return {
        ...entry,
        maxWeight,
        totalVolume,
        estimated1RM: Math.round(estimated1RM * 100) / 100
      }
    })

    history.sort((a, b) => new Date(a.date) - new Date(b.date))

    res.status(200).json({ success: true, history })
  } catch (error) {
    console.error('Get Exercise Progress Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

exports.getStreakAnalytics = async (req, res) => {
  try {
    const userId = req.user.id

    const logs = await db.WorkoutLog.findAll({
      where: { userId },
      attributes: ['date'],
      order: [['date', 'ASC']]
    })

    // Aynı güne ait birden fazla WorkoutLog olabilir (aynı gün 2 antrenman),
    // tekilleştiriyoruz — streak günlük bazda hesaplanır.
    const uniqueDates = [
      ...new Set(logs.map(l => l.date.toISOString().split('T')[0]))
    ].sort()

    // En uzun streak: ardışık günleri tara
    let longestStreak = 0
    let tempStreak = 0
    let previousDate = null

    for (const dateStr of uniqueDates) {
      if (previousDate) {
        const diffDays =
          (new Date(dateStr) - new Date(previousDate)) / (1000 * 60 * 60 * 24)
        tempStreak = diffDays === 1 ? tempStreak + 1 : 1
      } else {
        tempStreak = 1
      }
      longestStreak = Math.max(longestStreak, tempStreak)
      previousDate = dateStr
    }

    // Güncel streak: bugünden geriye doğru kesintisiz günleri say
    const dateSet = new Set(uniqueDates)
    let currentStreak = 0
    const cursor = new Date()
    while (dateSet.has(cursor.toISOString().split('T')[0])) {
      currentStreak++
      cursor.setDate(cursor.getDate() - 1)
    }

    res.status(200).json({
      success: true,
      currentStreak,
      longestStreak,
      totalActiveDays: uniqueDates.length,
      activeDates: uniqueDates
    })
  } catch (error) {
    console.error('Get Streak Analytics Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}