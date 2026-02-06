const db = require('../models');
const Exercise = db.Exercise;

exports.createExercise = async (req, res) => {
  try {
    const { name, region, description, imageUrl } = req.body;
    const newExercise = await Exercise.create({
      name,
      region,
      description,
      imageUrl
    });

    res.status(201).json({
      message: "Hareket eklendi!",
      data: newExercise
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getAllExercises = async (req, res) => {
  try {
    const { region } = req.query;
    let whereCondition = {};

    if (region) {
      whereCondition.region = region;
    }

    const exercises = await Exercise.findAll({ where: whereCondition });
    res.status(200).json(exercises);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getExerciseById = async (req, res) => {
  try {
    const exercise = await Exercise.findByPk(req.params.id);
    if (!exercise) return res.status(404).json({ message: "Hareket bulunamadı" });
    res.status(200).json(exercise);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};