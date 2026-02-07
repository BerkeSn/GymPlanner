const {Model} = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    class RoutineExercise extends Model {
        static associate(models) {
            RoutineExercise.belongsTo(models.WorkoutRoutine, 
                { foreignKey: 'workoutRoutineId', as: 'workoutRoutine' }
            );
            RoutineExercise.belongsTo(models.Exercise, 
                { foreignKey: 'exerciseId', as: 'exercise' }
            );
        }
    }

    RoutineExercise.init({
        day: {
            type: DataTypes.ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
            allowNull: false
        },
        targetSets: {
            type: DataTypes.INTEGER,
            allowNull: false,
            defaultValue: 3
        },
        targetReps: {
            type: DataTypes.INTEGER,
            allowNull: false,
            defaultValue: 8
        },
    }, {
        sequelize,
        modelName: 'RoutineExercise',
        timestamps: false
    });
    return RoutineExercise;
}