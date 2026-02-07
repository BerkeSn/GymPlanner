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
      allowNull: true
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
  }, {
    sequelize,
    modelName: 'User',
  });
  return User;
};