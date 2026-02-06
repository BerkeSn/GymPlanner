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

exports.getLogsByExercise = async (req, res) => {
  try {
    const { userId, exerciseId, page, limit } = req.query;

    // Sayfa sayısı gelmezse varsayılan 1 olsun, limit gelmezse 10 olsun.
    const pageNum = parseInt(page) || 1;
    const limitNum = parseInt(limit) || 10;
    const offset = (pageNum - 1) * limitNum;

    const { count, rows } = await WorkoutLog.findAndCountAll({
      where: { userId, exerciseId },
      order: [['date', 'DESC']],
      limit: limitNum,  // Kaç tane getireyim?
      offset: offset    // Kaç tane atlayayım?
    });

    res.status(200).json({
      totalItems: count,      // Toplam kaç kayıt var?
      totalPages: Math.ceil(count / limitNum), // Toplam kaç sayfa sürer?
      currentPage: pageNum,   // Şu an hangi sayfadayız?
      data: rows              // Ve veriler
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 3. Hatalı Logu Sil (DELETE)
exports.deleteLog = async (req, res) => {
  try {
    const { id } = req.params; // Silinecek logun ID'si URL'den gelir

    const deleted = await WorkoutLog.destroy({
      where: { id: id }
    });

    if (!deleted) {
      return res.status(404).json({ message: "Silinecek kayıt bulunamadı." });
    }

    res.status(200).json({ message: "Kayıt başarıyla silindi." });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};