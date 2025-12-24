const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Exercise extends Model {
    static associate(models) {
      Exercise.belongsToMany(models.User, { through: 'UserFavorites', as: 'favoritedBy' });
      Exercise.belongsToMany(models.WeeklyRoutine, { 
        through: models.RoutineExercise, 
        foreignKey: 'exerciseId',
        as: 'routines'
      });
      
      Exercise.hasMany(models.WorkoutLog, { foreignKey: 'exerciseId', as: 'logs' });
    }
  }

  Exercise.init({
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true
    },
    name: { 
      type: DataTypes.STRING, 
      allowNull: false 
    },
    region: { 
      type: DataTypes.STRING,
      allowNull: false 
    }, 
    description: { 
      type: DataTypes.TEXT,
      allowNull: true
    },
    imageUrl: { 
      type: DataTypes.STRING,
      allowNull: true
    }
  }, {
    sequelize,
    modelName: 'Exercise',
    timestamps: true,
    paranoid: false // Hareketler genelde silinmez, ama istersen true yapabilirsin
  });

  return Exercise;
};