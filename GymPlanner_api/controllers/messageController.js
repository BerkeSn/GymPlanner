const db = require('../models');
const Message = db.Message;
const { Op } = require('sequelize');

// 1. Mesaj Gönder
exports.sendMessage = async (req, res) => {
  try {
    const { senderId, receiverId, content, messageType, mediaUrl } = req.body;

    const message = await Message.create({
      senderId,
      receiverId,
      content,
      messageType, // 'text' veya 'image'
      mediaUrl
    });

    res.status(201).json(message);

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 2. İki Kişi Arasındaki Konuşmayı Getir
exports.getConversation = async (req, res) => {
  try {
    const { userId1, userId2 } = req.query;

    const messages = await Message.findAll({
      where: {
        [Op.or]: [
          { senderId: userId1, receiverId: userId2 },
          { senderId: userId2, receiverId: userId1 }
        ]
      },
      order: [['createdAt', 'ASC']] // Eskiden yeniye
    });

    res.status(200).json(messages);

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};