const db = require('../models');

// Get all equipment
exports.getAllEquipment = async (req, res) => {
    try {
        const equipment = await db.Equipment.findAll({
            attributes: ['id', 'name'],
            order: [['name', 'ASC']]
        });
        res.json({
            success: true,     
            equipment,
            message: 'Equipment retrieved successfully.'
        });
    } catch (error) {        console.error('Error fetching equipment:', error);
        res.status(500).json({ error: 'An error occurred while fetching equipment.' });
    }
};

exports.createEquipment = async (req, res) => {
    try {
        const { name } = req.body;
        if (!name) {
            return res.status(400).json({ error: 'Name is required.' });
        }

        const existingEquipment = await db.Equipment.findOne({ where: { name } });
        if (existingEquipment) {
            return res.status(400).json({ error: 'Equipment with this name already exists.' });
        }

        const newEquipment = await db.Equipment.create({ name });
        res.status(201).json({
            success: true,
            equipment: newEquipment,
            message: 'Equipment created successfully.'
        });
    } catch (error) {
        console.error('Error creating equipment:', error);
        res.status(500).json({ error: 'An error occurred while creating equipment.' });
    }
};