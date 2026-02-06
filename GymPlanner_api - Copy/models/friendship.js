const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Friendship extends Model {
    static associate(models) {
    }
  }

  Friendship.init({
    status: {
      type: DataTypes.ENUM('pending', 'accepted', 'blocked'),
      defaultValue: 'pending'
    }
  }, {
    sequelize,
    modelName: 'Friendship',
    timestamps: true
  });

  return Friendship;
};