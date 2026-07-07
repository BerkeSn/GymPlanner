const { Model } = require('sequelize')

module.exports = (sequelize, DataTypes) => {
  class CalorieEntry extends Model {
    static associate (models) {
      CalorieEntry.belongsTo(models.User, { foreignKey: 'userId', as: 'user' })
    }
  }

  CalorieEntry.init(
    {
      date: {
        type: DataTypes.DATEONLY,
        allowNull: false
      },
      calories: {
        type: DataTypes.INTEGER,
        allowNull: false
      }
    },
    {
      sequelize,
      modelName: 'CalorieEntry',
      timestamps: true,
      indexes: [{ unique: true, fields: ['userId', 'date'] }]
    }
  )
  return CalorieEntry
}