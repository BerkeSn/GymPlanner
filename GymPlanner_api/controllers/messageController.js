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

// 2. İki Kişi Arasındaki Konuşmayı Getir (PAGINATION EKLENDİ)
exports.getConversation = async (req, res) => {
  try {
    const { userId1, userId2, page, limit } = req.query;

    const pageNum = parseInt(page) || 1;
    const limitNum = parseInt(limit) || 20; // Mesajlaşmada genelde daha çok veri çekilir
    const offset = (pageNum - 1) * limitNum;

    const { count, rows } = await Message.findAndCountAll({
      where: {
        [Op.or]: [
          { senderId: userId1, receiverId: userId2 },
          { senderId: userId2, receiverId: userId1 }
        ]
      },
      order: [['createdAt', 'DESC']], // En yeni mesajı önce getir (WhatsApp mantığı)
      limit: limitNum,
      offset: offset
    });

    // Mesajlar tersten (yeni -> eski) gelir, frontend bunu ters çevirip gösterir.
    res.status(200).json({
      totalMessages: count,
      totalPages: Math.ceil(count / limitNum),
      currentPage: pageNum,
      messages: rows
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};