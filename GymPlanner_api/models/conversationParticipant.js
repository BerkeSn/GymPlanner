const { Model } = require('sequelize')

module.exports = (sequelize, DataTypes) => {
  class ConversationParticipant extends Model {
    static associate (models) {
      ConversationParticipant.belongsTo(models.Conversation, {
        foreignKey: 'conversationId',
        as: 'conversation'
      })
      ConversationParticipant.belongsTo(models.User, {
        foreignKey: 'userId',
        as: 'user'
      })
    }
  }

  ConversationParticipant.init(
    {
      lastReadAt: {
        type: DataTypes.DATE,
        allowNull: true
      }
    },
    {
      sequelize,
      modelName: 'ConversationParticipant',
      timestamps: true,
      indexes: [
        { unique: true, fields: ['conversationId', 'userId'] }
      ]
    }
  )
  return ConversationParticipant
}