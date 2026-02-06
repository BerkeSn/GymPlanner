const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class WeeklyRoutine extends Model {
    static associate(models) {
      WeeklyRoutine.belongsTo(models.User, { foreignKey: 'userId', as: 'user' });
      WeeklyRoutine.belongsToMany(models.Exercise, { 
        through: models.RoutineExercise, 
        foreignKey: 'routineId',
        as: 'exercises'
      });
      WeeklyRoutine.hasMany(models.RoutineExercise, { foreignKey: 'routineId', as: 'routineDetails' });
    }
  }

  WeeklyRoutine.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    dayOfWeek: { 
      type: DataTypes.INTEGER, 
      allowNull: false 
    },
    isActive: { 
      type: DataTypes.BOOLEAN, 
      defaultValue: true 
    }
  }, {
    sequelize,
    modelName: 'WeeklyRoutine',
    timestamps: true
  });

  return WeeklyRoutine;
};