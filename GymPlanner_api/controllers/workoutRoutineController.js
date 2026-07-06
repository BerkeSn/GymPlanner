const db = require('../models')

exports.createWorkoutRoutine = async (req, res) => {
  try {
    const userId = req.user.id

    const { name, description } = req.body

    if (!name) {
      return res
        .status(400)
        .json({ success: false, message: 'Program adı zorunludur.' })
    }

    const newRoutine = await db.WorkoutRoutine.create({
      name,
      description,
      userId,
      isActive: true
    })

    res.status(201).json({
      success: true,
      message:
        'Program başlığı oluşturuldu! Şimdi içine hareket ekleyebilirsin.',
      workoutRoutine: newRoutine
    })
  } catch (error) {
    console.error('Create Routine Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

exports.getWorkoutRoutines = async (req, res) => {
  try {
    const userId = req.user.id

    const workoutRoutines = await db.WorkoutRoutine.findAll({
      where: { userId },
      include: [
        {
          model: db.RoutineExercise,
          as: 'routineExercises',
          include: [
            {
              model: db.Exercise,
              as: 'exercise',
              attributes: ['id', 'name', 'imageUrl']
            }
          ]
        }
      ],
      order: [['createdAt', 'DESC']]
    })

    res.status(200).json({ success: true, workoutRoutines })
  } catch (error) {
    res.status(500).json({ success: false, error: error.message })
  }
}

exports.getWorkoutRoutineById = async (req, res) => {
  try {
    const userId = req.user.id
    const { id } = req.params
    const workoutRoutine = await db.WorkoutRoutine.findOne({
      where: { id, userId },
      include: [
        {
          model: db.RoutineExercise,
          as: 'routineExercises',
          include: [
            {
              model: db.Exercise,
              as: 'exercise',
              attributes: ['id', 'name', 'imageUrl']
            }
          ]
        }
      ]
    })

    if (!workoutRoutine) {
      return res
        .status(404)
        .json({ success: false, message: 'Workout routine not found.' })
    }

    res.status(200).json({ success: true, workoutRoutine })
  } catch (error) {
    res.status(500).json({ success: false, error: error.message })
  }
}

exports.deleteWorkoutRoutine = async (req, res) => {
  try {
    const userId = req.user.id
    const { id } = req.params

    const workoutRoutine = await db.WorkoutRoutine.findOne({
      where: { id, userId }
    })

    if (!workoutRoutine) {
      return res
        .status(404)
        .json({ success: false, message: 'Workout routine not found.' })
    }

    await workoutRoutine.destroy()

    res
      .status(200)
      .json({ success: true, message: 'Workout routine deleted successfully.' })
  } catch (error) {
    res.status(500).json({ success: false, error: error.message })
  }
}

exports.updateWorkoutRoutine = async (req, res) => {
  try {
    const userId = req.user.id
    const { id } = req.params
    const { name, description } = req.body

    const workoutRoutine = await db.WorkoutRoutine.findOne({
      where: { id, userId }
    })

    if (!workoutRoutine) {
      return res
        .status(404)
        .json({ success: false, message: 'Workout routine not found.' })
    }

    const isActive =
      req.body.isActive !== undefined
        ? req.body.isActive
        : workoutRoutine.isActive

    const updatedName =
      name !== undefined && name !== null ? name : workoutRoutine.name

    const updatedDescription =
      description !== undefined ? description : workoutRoutine.description

    await workoutRoutine.update({
      name: updatedName,
      description: updatedDescription,
      isActive
    })

    res
      .status(200)
      .json({ success: true, message: 'Workout routine updated successfully.' })
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Program güncellenirken bir hata oluştu.',
      error: error.message
    })
  }
}
