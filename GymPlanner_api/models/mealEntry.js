const { Model } = require('sequelize')

module.exports = (sequelize, DataTypes) => {
  class MealEntry extends Model {
    static associate (models) {
      MealEntry.belongsTo(models.User, { foreignKey: 'userId', as: 'user' })
    }
  }

  MealEntry.init(
    {
      date: {
        type: DataTypes.DATEONLY,
        allowNull: false
      },
      mealType: {
        type: DataTypes.ENUM('Breakfast', 'Lunch', 'Dinner', 'Snack'),
        allowNull: false,
        defaultValue: 'Snack'
      },
      name: {
        type: DataTypes.STRING,
        allowNull: false
      },
      servingWeight: {
        type: DataTypes.FLOAT,
        allowNull: true
      },
      calories: {
        type: DataTypes.INTEGER,
        allowNull: false
      },
      protein: {
        type: DataTypes.FLOAT,
        allowNull: true,
        defaultValue: 0
      },
      carbs: {
        type: DataTypes.FLOAT,
        allowNull: true,
        defaultValue: 0
      },
      fats: {
        type: DataTypes.FLOAT,
        allowNull: true,
        defaultValue: 0
      }
    },
    {
      sequelize,
      modelName: 'MealEntry',
      timestamps: true
    }
  )
  return MealEntry
}