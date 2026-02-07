const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    class WorkoutLog extends Model {
        static associate(models) {
            WorkoutLog.belongsTo(models.WorkoutRoutine,
                { foreignKey: 'workoutRoutineId', as: 'workoutRoutine' }
            );
            WorkoutLog.hasMany(models.WorkoutSetLog,
                { foreignKey: 'workoutLogId', as: 'workoutSetLogs', onDelete: 'CASCADE' }
            );
            WorkoutLog.belongsTo(models.User,
                { foreignKey: 'userId', as: 'user' }
            );
        }
    }

    WorkoutLog.init({
        date: {
            type: DataTypes.DATE,
            allowNull: false
        },
    }, {
        sequelize,
        modelName: 'WorkoutLog'
    });
    return WorkoutLog;
}