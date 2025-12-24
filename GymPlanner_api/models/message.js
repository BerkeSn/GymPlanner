const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Message extends Model {
    static associate(models) {
      Message.belongsTo(models.User, { foreignKey: 'senderId', as: 'sender' });
      Message.belongsTo(models.User, { foreignKey: 'receiverId', as: 'receiver' });
    }
  }

  Message.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    content: { 
      type: DataTypes.TEXT,
      allowNull: true
    },
    messageType: { 
      type: DataTypes.ENUM('text', 'image'), 
      defaultValue: 'text' 
    },
    mediaUrl: { 
      type: DataTypes.STRING,
      allowNull: true
    },
    isRead: { 
      type: DataTypes.BOOLEAN, 
      defaultValue: false 
    }
  }, {
    sequelize,
    modelName: 'Message',
    timestamps: true
  });

  return Message;
};