const {Model} = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    class Exercise extends Model {
        static associate(models) {
            Exercise.belongsTo(models.MuscleGroup, 
                { foreignKey: 'muscleGroupId', as: 'muscleGroup' }
            );
            Exercise.belongsTo(models.Equipment, 
                { foreignKey: 'equipmentId', as: 'equipment' }
            );
        }
    }

    Exercise.init({
        name: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true
        },
        description: {
            type: DataTypes.STRING,
            allowNull: true
        },
        imageUrl: {
            type: DataTypes.STRING,
            allowNull: true
        },
        difficulty: {
            type: DataTypes.ENUM('Beginner', 'Intermediate', 'Advanced'),
            allowNull: false,
            defaultValue: 'Beginner'
        },
        availableAt: {
            type: DataTypes.ENUM('Home', 'Gym', 'Both'),
            allowNull: false,
            defaultValue: 'Gym'
        },
    }, {
        sequelize,
        modelName: 'Exercise',
    });
    return Exercise;
}