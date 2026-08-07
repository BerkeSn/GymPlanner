const e = require('express');
const db = require('../models');

exports.createExercise = async (req, res) => {
    try {
        const { name, description, imageUrl, difficulty, muscleGroupId, equipmentId, availableAt } = req.body;

        if (!name || !muscleGroupId || !equipmentId) {
            return res.status(400).json({ 
                success: false, 
                message: "İsim, Kas Grubu (ID) ve Ekipman (ID) zorunludur Agam." 
            });
        }

        const existingExercise = await db.Exercise.findOne({ where: { name } });
        if (existingExercise) {
            return res.status(400).json({ success: false, message: "Bu hareket zaten ekli." });
        }

        const muscleGroup = await db.MuscleGroup.findByPk(muscleGroupId);
        if (!muscleGroup) {
            return res.status(404).json({ success: false, message: "Böyle bir Kas Grubu bulunamadı." });
        }

        const equipment = await db.Equipment.findByPk(equipmentId);
        if (!equipment) {
            return res.status(404).json({ success: false, message: "Böyle bir Ekipman bulunamadı." });
        }

        const newExercise = await db.Exercise.create({
            name,
            description,
            imageUrl,
            difficulty,
            muscleGroupId,
            equipmentId,
            availableAt
        });

        res.status(201).json({
            success: true,
            message: "Hareket başarıyla oluşturuldu!",
            exercise: newExercise
        });

    } catch (error) {
        console.error("Create Exercise Hatası:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.getAllExercises = async (req, res) => {
    try {
        const exercises = await db.Exercise.findAll({
            include: [
                {
                    model: db.MuscleGroup,
                    as: 'muscleGroup',
                    attributes: ['name']
                },
                {
                    model: db.Equipment,
                    as: 'equipment',
                    attributes: ['name']
                }
            ],
            order: [['name', 'ASC']]
        });

        res.status(200).json({
            success: true,
            count: exercises.length,
            exercises
        });

    } catch (error) {
        console.error("Get All Exercise Hatası:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.getExerciseById = async (req, res) => {
    try {
        const { id } = req.params;
        const exercise = await db.Exercise.findByPk(id, {
            include: [
                {
                    model: db.MuscleGroup,
                    as: 'muscleGroup',
                    attributes: ['name']
                },
                {
                    model: db.Equipment,
                    as: 'equipment',
                    attributes: ['name']
                }
            ]
        });

        if (!exercise) {
            return res.status(404).json({ success: false, message: "Hareket bulunamadı." });
        }

        res.status(200).json({
            success: true,
            exercise
        });

    } catch (error) {
        console.error("Get Exercise By ID Hatası:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.getExerciseByMuscleGroupId = async (req, res) => {
    try {
        const { muscleGroupId } = req.params;
        const exercises = await db.Exercise.findAll({
            where: { muscleGroupId },
            include: [
                {
                    model: db.MuscleGroup,
                    as: 'muscleGroup',
                    attributes: ['name']
                },
                {
                    model: db.Equipment,
                    as: 'equipment',
                    attributes: ['name']
                }
            ],
            order: [['name', 'ASC']]
        });
        
        res.status(200).json({
            success: true,
            count: exercises.length,
            exercises
        });

    } catch (error) {
        console.error("Get Exercise By Muscle Group ID Hatası:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.getExerciseByEquipmentId = async (req, res) => {
    try {
        const { equipmentId } = req.params;
        const exercises = await db.Exercise.findAll({
            where: { equipmentId },
            include: [
                {
                    model: db.MuscleGroup,
                    as: 'muscleGroup',
                    attributes: ['name']
                },
                {
                    model: db.Equipment,
                    as: 'equipment',
                    attributes: ['name']
                }
            ],
            order: [['name', 'ASC']]
        });
        
        res.status(200).json({
            success: true,
            count: exercises.length,
            exercises
        });

    } catch (error) {
        console.error("Get Exercise By Equipment ID Hatası:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};