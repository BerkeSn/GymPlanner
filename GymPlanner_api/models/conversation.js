const { Model } = require('sequelize')

module.exports = (sequelize, DataTypes) => {
  class Conversation extends Model {
    static associate (models) {
      Conversation.hasMany(models.ConversationParticipant, {
        foreignKey: 'conversationId',
        as: 'participants'
      })
      Conversation.hasMany(models.Message, {
        foreignKey: 'conversationId',
        as: 'messages'
      })
    }
  }

  Conversation.init(
    {
      isGroup: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false
      },
      name: {
        type: DataTypes.STRING,
        allowNull: true
      }
    },
    {
      sequelize,
      modelName: 'Conversation',
      timestamps: true
    }
  )
  return Conversation
}