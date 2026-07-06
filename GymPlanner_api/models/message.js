const { Model } = require('sequelize')

module.exports = (sequelize, DataTypes) => {
  class Message extends Model {
    static associate (models) {
      Message.belongsTo(models.Conversation, {
        foreignKey: 'conversationId',
        as: 'conversation'
      })
      Message.belongsTo(models.User, {
        foreignKey: 'senderId',
        as: 'sender'
      })
    }
  }

  Message.init(
    {
      type: {
        type: DataTypes.ENUM('text', 'image', 'location'),
        allowNull: false,
        defaultValue: 'text'
      },
      content: {
        type: DataTypes.TEXT,
        allowNull: true
      },
      imageUrl: {
        type: DataTypes.STRING,
        allowNull: true
      }
    },
    {
      sequelize,
      modelName: 'Message',
      timestamps: true
    }
  )
  return Message
}