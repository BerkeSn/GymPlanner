const { Model } = require('sequelize')

module.exports = (sequelize, DataTypes) => {
  class WorkoutRoutine extends Model {
    static associate (models) {
      WorkoutRoutine.belongsTo(models.User, {
        foreignKey: 'userId',
        as: 'user'
      })
      WorkoutRoutine.hasMany(models.RoutineExercise, {
        foreignKey: 'workoutRoutineId',
        as: 'routineExercises'
      })
    }
  }

  WorkoutRoutine.init(
    {
      name: {
        type: DataTypes.STRING,
        allowNull: false
      },
      description: {
        type: DataTypes.STRING,
        allowNull: true
      },
      isActive: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false
      }
    },
    {
      sequelize,
      modelName: 'WorkoutRoutine'
    }
  )
  return WorkoutRoutine
}
