const db = require('../models');
const WeeklyRoutine = db.WeeklyRoutine;
const Exercise = db.Exercise;
const RoutineExercise = db.RoutineExercise;

// 1. Programa Hareket Ekle (Upsert Mantığı)
exports.addToRoutine = async (req, res) => {
  try {
    const { userId, dayOfWeek, exerciseId, targetSets, targetReps, orderIndex } = req.body;

    // 1. O gün için bir rutin var mı? Yoksa oluştur.
    const [routine, created] = await WeeklyRoutine.findOrCreate({
      where: { userId, dayOfWeek },
      defaults: { isActive: true }
    });

    // 2. Rutine hareketi ve hedefleri ekle
    // addExercise metodu Sequelize'un otomatik oluşturduğu bir metoddur.
    // 'through' kısmı pivot tablosuna (RoutineExercise) ekstra veri yazar.
    await routine.addExercise(exerciseId, {
      through: {
        targetSets,
        targetReps,
        orderIndex
      }
    });

    res.status(200).json({ message: "Hareket programa eklendi Boss!", routineId: routine.id });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 2. O Günün Programını Getir
exports.getRoutineByDay = async (req, res) => {
  try {
    const { userId, dayOfWeek } = req.query; // Query string'den alıyoruz

    const routine = await WeeklyRoutine.findOne({
      where: { userId, dayOfWeek },
      include: [{
        model: Exercise,
        as: 'exercises',
        // Pivot tablosundaki verileri de (hedef set/tekrar) getirmesi için:
        through: {
          attributes: ['targetSets', 'targetReps', 'orderIndex']
        }
      }]
    });

    if (!routine) {
      return res.status(404).json({ message: "Bugün için plan bulunamadı." });
    }

    res.status(200).json(routine);

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 3. Programdan Hareket Sil
exports.removeFromRoutine = async (req, res) => {
  try {
    const { routineId, exerciseId } = req.body;
    
    // Doğrudan pivot tablosundan siliyoruz
    await RoutineExercise.destroy({
        where: { routineId, exerciseId }
    });

    res.status(200).json({ message: "Hareket programdan kaldırıldı." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 4. Rutindeki Hareketin Hedeflerini Güncelle (UPDATE)
exports.updateRoutineExercise = async (req, res) => {
  try {
    const { routineId, exerciseId, targetSets, targetReps, orderIndex } = req.body;

    // RoutineExercise, bizim tanımladığımız Pivot Modeldi.
    // Doğrudan o tabloda, bu rutin ve bu harekete ait satırı bulup güncelliyoruz.
    const [updatedCount] = await RoutineExercise.update(
      { targetSets, targetReps, orderIndex }, // Değişecek alanlar
      { where: { routineId, exerciseId } }    // Hangi satır?
    );

    if (updatedCount === 0) {
      return res.status(404).json({ message: "Bu rutinde böyle bir hareket bulunamadı." });
    }

    res.status(200).json({ message: "Program güncellendi Boss!" });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};