const db = require('../models');


exports.createMuscleGroup = async (req, res) => {
    try {
        const { name, description, imageUrl } = req.body;
        if (!name) {
            return res.status(400).json({ success: false, message: "Lütfen kas grubunun adını girin." });
        }
        const existingMuscleGroup = await db.MuscleGroup.findOne({ where: { name } });
        if (existingMuscleGroup) {
            return res.status(400).json({ success: false, message: "Bu isimde bir kas grubu zaten mevcut." });
        }
        const newMuscleGroup = await db.MuscleGroup.create({ name, description, imageUrl });
        res.status(201).json({ success: true, muscleGroup: newMuscleGroup });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.getAllMuscleGroups = async (req, res) => {
    try {
        const muscleGroups = await db.MuscleGroup.findAll({
            attributes: ["id", "name", "description", "imageUrl"]
        });
        res.status(200).json({ success: true, muscleGroups });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};