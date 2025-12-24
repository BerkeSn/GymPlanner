const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class WorkoutLog extends Model {
    static associate(models) {
      WorkoutLog.belongsTo(models.User, { foreignKey: 'userId', as: 'user' });
      WorkoutLog.belongsTo(models.Exercise, { foreignKey: 'exerciseId', as: 'exercise' });
    }
  }

  WorkoutLog.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    date: { 
      type: DataTypes.DATEONLY, 
      defaultValue: DataTypes.NOW 
    },
    setData: { 
      type: DataTypes.JSONB, 
      allowNull: false, 
      defaultValue: []
    },
    nextWeekGoal: { 
      type: DataTypes.STRING,
      allowNull: true
    }
  }, {
    sequelize,
    modelName: 'WorkoutLog',
    timestamps: true
  });

  return WorkoutLog;
};