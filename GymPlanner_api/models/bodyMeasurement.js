const { Model } = require('sequelize')

module.exports = (sequelize, DataTypes) => {
  class BodyMeasurement extends Model {
    static associate (models) {
      BodyMeasurement.belongsTo(models.User, {
        foreignKey: 'userId',
        as: 'user'
      })
    }
  }

  BodyMeasurement.init(
    {
      date: {
        type: DataTypes.DATEONLY,
        allowNull: false
      },
      weight: {
        type: DataTypes.FLOAT,
        allowNull: false
      },
      height: {
        type: DataTypes.FLOAT,
        allowNull: false
      },
      neck: {
        type: DataTypes.FLOAT,
        allowNull: true
      },
      waist: {
        type: DataTypes.FLOAT,
        allowNull: true
      },
      bodyFatPercentage: {
        type: DataTypes.FLOAT,
        allowNull: true
      },
      muscleMass: {
        type: DataTypes.FLOAT,
        allowNull: true
      },
      goal: {
        type: DataTypes.ENUM('Lose Weight', 'Gain Muscle', 'Maintain'),
        allowNull: false,
        defaultValue: 'Maintain'
      }
    },
    {
      sequelize,
      modelName: 'BodyMeasurement',
      paranoid: true,
      timestamps: true
    }
  )
  return BodyMeasurement
}
