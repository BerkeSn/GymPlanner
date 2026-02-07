const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    class WorkoutSetLog extends Model {
        static associate(models) {
            WorkoutSetLog.belongsTo(models.WorkoutLog,
                { foreignKey: 'workoutLogId', as: 'workoutLog' }
            );
            WorkoutSetLog.belongsTo(models.Exercise,
                { foreignKey: 'exerciseId', as: 'exercise' }
            );
        }
    }

    WorkoutSetLog.init({
        setNumber: {
            type: DataTypes.INTEGER,
            allowNull: false
        },
        reps: {
            type: DataTypes.INTEGER,
            allowNull: false
        },
        weight: {
            type: DataTypes.FLOAT,
            allowNull: false
        }
    }, {
        sequelize,
        modelName: 'WorkoutSetLog'
    });
    return WorkoutSetLog;
}