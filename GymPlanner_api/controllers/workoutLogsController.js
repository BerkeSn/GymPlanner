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
