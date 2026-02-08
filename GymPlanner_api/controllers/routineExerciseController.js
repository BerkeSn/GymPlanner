const db = require('../models');

exports.addExerciseToRoutine = async (req, res) => {
    try {
        const userId = req.user.id;

        const { routineId } = req.params; 
        const { exerciseId, day, targetSets, targetReps } = req.body;

        if (!exerciseId || !day || !targetSets || !targetReps) {
            return res.status(400).json({ 
                success: false, 
                message: "Eksik bilgi: Hareket ID, Gün, Set ve Tekrar sayıları zorunludur." 
            });
        }

        const routine = await db.WorkoutRoutine.findOne({ 
            where: { id: routineId, userId } 
        });

        if (!routine) {
            return res.status(404).json({ 
                success: false, 
                message: "Program bulunamadı." 
            });
        }

        const newRoutineExercise = await db.RoutineExercise.create({
            workoutRoutineId: routineId,
            exerciseId,
            day,
            targetSets,
            targetReps
        });

        res.status(201).json({
            success: true,
            message: "Hareket programa başarıyla eklendi!",
            addedExercise: newRoutineExercise
        });

    } catch (error) {
        console.error("Add Exercise Hatası:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.getExercisesByRoutineId = async (req, res) => {
    try {
        const userId = req.user.id;
        const { routineId } = req.params;

        const routineCheck = await db.WorkoutRoutine.findOne({
            where: { id: routineId, userId }
        });

        if (!routineCheck) {
            return res.status(404).json({ 
                success: false, 
                message: "Böyle bir program bulunamadı" 
            });
        }

        const exercises = await db.RoutineExercise.findAll({
            where: { workoutRoutineId: routineId },
            include: [
                {
                    model: db.Exercise,
                    as: 'exercise',
                    attributes: ['id', 'name', 'imageUrl']
                }
            ],
            order: [['day', 'ASC']]
        });

        res.status(200).json({
            success: true,
            count: exercises.length,
            data: exercises
        });

    } catch (error) {
        console.error("Get Routine Exercises Hatası:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};