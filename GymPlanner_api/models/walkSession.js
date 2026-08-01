// models/walkSession.js

const { Model } = require('sequelize')

module.exports = (sequelize, DataTypes) => {
  class WalkSession extends Model {
    static associate (models) {
      WalkSession.belongsTo(models.User, { foreignKey: 'userId', as: 'user' })
    }
  }

  WalkSession.init(
    {
      startTime: {
        type: DataTypes.DATE,
        allowNull: false
      },
      endTime: {
        type: DataTypes.DATE,
        allowNull: false
      },
      durationSeconds: {
        type: DataTypes.INTEGER,
        allowNull: false
      },
      distanceMeters: {
        type: DataTypes.FLOAT,
        allowNull: false,
        defaultValue: 0
      },
      steps: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
      },
      calories: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0
      },
      // [{lat, lng}, ...] — rota noktaları, mobil tarafta çizim için.
      routePoints: {
        type: DataTypes.JSONB,
        allowNull: true,
        defaultValue: []
      }
    },
    {
      sequelize,
      modelName: 'WalkSession',
      timestamps: true
    }
  )
  return WalkSession
}