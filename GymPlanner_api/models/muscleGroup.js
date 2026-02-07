const {Model} = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    class MuscleGroup extends Model {
        static associate(models) {
            MuscleGroup.hasMany(models.Exercise, 
                { foreignKey: 'muscleGroupId', as: 'exercises' }
            )
        }
    }

    MuscleGroup.init({
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
        }
    }, {
        sequelize,
        modelName: 'MuscleGroup',
        timestamps: false
    });
    return MuscleGroup;
}