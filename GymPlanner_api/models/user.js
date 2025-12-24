const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class User extends Model {
    static associate(models) {
        
      User.belongsToMany(models.Exercise, { through: 'UserFavorites', as: 'favorites' });
      User.hasMany(models.WeeklyRoutine, { foreignKey: 'userId', as: 'routines' });
      User.hasMany(models.WorkoutLog, { foreignKey: 'userId', as: 'logs' });
      User.belongsToMany(models.User, { 
        as: 'Friends', 
        through: models.Friendship, 
        foreignKey: 'requesterId', 
        otherKey: 'addresseeId' 
      });

      User.hasMany(models.Message, { foreignKey: 'senderId', as: 'sentMessages' });
      User.hasMany(models.Message, { foreignKey: 'receiverId', as: 'receivedMessages' });
    }
  }

  User.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
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
      validate: { isEmail: true }
    },
    password: { 
      type: DataTypes.STRING, 
      allowNull: false 
    },
    role: { 
      type: DataTypes.ENUM('coach', 'gymrat'), 
      defaultValue: 'gymrat' 
    },
    profileImage: { 
      type: DataTypes.STRING,
      allowNull: true
    },
    bio: { 
      type: DataTypes.TEXT,
      allowNull: true
    }
  }, {
    sequelize,
    modelName: 'User',
    timestamps: true,
    paranoid: true,
  });

  return User;
};