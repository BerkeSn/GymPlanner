const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class RoutineExercise extends Model {
    static associate(models) {
      RoutineExercise.belongsTo(models.WeeklyRoutine, { foreignKey: 'routineId' });
      RoutineExercise.belongsTo(models.Exercise, { foreignKey: 'exerciseId' });
    }
  }

  RoutineExercise.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    targetSets: { 
      type: DataTypes.INTEGER, 
      defaultValue: 3 
    },
    targetReps: { 
      type: DataTypes.STRING, 
      defaultValue: "10" 
    },
    orderIndex: { 
      type: DataTypes.INTEGER, 
      defaultValue: 0 
    }
  }, {
    sequelize,
    modelName: 'RoutineExercise',
    timestamps: true
  });

  return RoutineExercise;
};