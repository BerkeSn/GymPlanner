const { Model } = require('sequelize')

module.exports = (sequelize, DataTypes) => {
  class CalorieSettings extends Model {
    static associate (models) {
      CalorieSettings.belongsTo(models.User, { foreignKey: 'userId', as: 'user' })
    }
  }

  CalorieSettings.init(
    {
      activityLevel: {
        type: DataTypes.ENUM('sedentary', 'light', 'moderate', 'active'),
        allowNull: false,
        defaultValue: 'moderate'
      }
    },
    {
      sequelize,
      modelName: 'CalorieSettings',
      timestamps: true,
      indexes: [{ unique: true, fields: ['userId'] }]
    }
  )
  return CalorieSettings
}