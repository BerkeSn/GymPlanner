const db = require('../models');
const WorkoutLog = db.WorkoutLog;
const Exercise = db.Exercise;

// 1. Antrenman Logu Gir (Setleri Kaydet)
exports.createLog = async (req, res) => {
  try {
    const { userId, exerciseId, date, setData, nextWeekGoal } = req.body;

    // setData örneği: [{ "set": 1, "reps": 12, "weight": 80 }, { "set": 2, "reps": 10, "weight": 85 }]
    
    const newLog = await WorkoutLog.create({
      userId,
      exerciseId,
      date: date || new Date(),
      setData, // JSONB olarak olduğu gibi kaydediyoruz
      nextWeekGoal
    });

    res.status(201).json({ message: "Antrenman kaydedildi, tebrikler!", log: newLog });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 2. Bir Hareketin Geçmişini Getir (İlerleme Takibi)
exports.getLogsByExercise = async (req, res) => {
  try {
    const { userId, exerciseId } = req.query;

    const logs = await WorkoutLog.findAll({
      where: { userId, exerciseId },
      order: [['date', 'DESC']], // En yeni en üstte
      limit: 10 // Son 10 antrenman
    });

    res.status(200).json(logs);

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};