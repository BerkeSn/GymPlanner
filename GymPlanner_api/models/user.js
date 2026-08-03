const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class User extends Model {
    static associate(models) {
      User.hasMany(models.BodyMeasurement,
        { foreignKey: 'userId', as: 'bodyMeasurements' }
      );
      User.hasMany(models.WorkoutRoutine,
        { foreignKey: 'userId', as: 'workoutRoutines' }
      );
      User.hasMany(models.WorkoutLog,
        { foreignKey: 'userId', as: 'workoutLogs' }
      );
      User.hasMany(models.UserFavorite, {
        foreignKey: 'userId',
        as: 'favorites'
      });

      User.hasMany(models.Friendship, {
        foreignKey: 'requesterId',
        as: 'sentRequests'
      });
      
      User.hasMany(models.Friendship, {
        foreignKey: 'receiverId',
        as: 'receivedRequests'
      });
      User.hasMany(models.ConversationParticipant, {
        foreignKey: 'userId',
        as: 'conversationParticipations'
      });
      User.hasMany(models.Message, {
        foreignKey: 'senderId',
        as: 'sentMessages'
      });

      User.hasOne(models.CalorieSettings, { foreignKey: 'userId', as: 'calorieSettings' });
      User.hasMany(models.CalorieEntry, { foreignKey: 'userId', as: 'calorieEntries' });

      User.hasMany(models.MealEntry, { foreignKey: 'userId', as: 'mealEntries' });
      
      User.hasMany(models.WalkSession, { foreignKey: 'userId', as: 'walkSessions' });
    }
  }

  User.init({
    name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    surname: {
      type: DataTypes.STRING,
      allowNull: false
    },
    username: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true
      }
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false
    },
    phone: {
      type: DataTypes.STRING,
      allowNull: true,
      unique: true
    },
    birthdate: {
      type: DataTypes.DATEONLY,
      allowNull: true
    },
    gender: {
      type: DataTypes.ENUM('male', 'female', 'other'),
      allowNull: false,
      defaultValue: 'other'
    },
    locationPreference: {
      type: DataTypes.ENUM('Home', 'Gym'),
      allowNull: false,
      defaultValue: 'Gym'
    },
    goal: {
    type: DataTypes.ENUM('Lose Weight', 'Gain Muscle', 'Maintain', 'Improve Endurance'),
    allowNull: false,
    defaultValue: 'Maintain'
  },
  activityLevel: {
    type: DataTypes.ENUM('sedentary', 'light', 'moderate', 'active'),
    allowNull: false,
    defaultValue: 'moderate'
  },
  }, {
    sequelize,
    modelName: 'User',
  });
  return User;
};