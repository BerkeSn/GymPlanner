const db = require('../models')
const { Op } = require('sequelize')

// Arkadaşla sohbet başlat (varsa mevcut olanı döner)
exports.startConversation = async (req, res) => {
  try {
    const userId = req.user.id
    const { friendId } = req.params

    if (userId == friendId) {
      return res.status(400).json({ success: false, message: 'Kendinle sohbet başlatamazsın.' })
    }

    const friendship = await db.Friendship.findOne({
      where: {
        status: 'accepted',
        [Op.or]: [
          { requesterId: userId, receiverId: friendId },
          { requesterId: friendId, receiverId: userId }
        ]
      }
    })

    if (!friendship) {
      return res.status(403).json({ success: false, message: 'Sadece arkadaşlarınla mesajlaşabilirsin.' })
    }

    const candidateConversations = await db.Conversation.findAll({
      where: { isGroup: false },
      include: [{ model: db.ConversationParticipant, as: 'participants' }]
    })

    const targetIds = [Number(userId), Number(friendId)].sort().join(',')
    let conversation = candidateConversations.find(c => {
      const ids = c.participants.map(p => p.userId).sort().join(',')
      return ids === targetIds && c.participants.length === 2
    })

    if (!conversation) {
      conversation = await db.Conversation.create({ isGroup: false })
      await db.ConversationParticipant.bulkCreate([
        { conversationId: conversation.id, userId },
        { conversationId: conversation.id, userId: friendId }
      ])
    }

    res.status(200).json({
      success: true,
      conversationId: conversation.id,
      message: 'Sohbet hazır.'
    })
  } catch (error) {
    console.error('Start Conversation Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

// Kullanıcının sohbet listesi
exports.getConversations = async (req, res) => {
  try {
    const userId = req.user.id

    const myParticipations = await db.ConversationParticipant.findAll({
      where: { userId },
      attributes: ['conversationId', 'lastReadAt']
    })
    const conversationIds = myParticipations.map(p => p.conversationId)
    const lastReadMap = {}
    myParticipations.forEach(p => { lastReadMap[p.conversationId] = p.lastReadAt })

    const conversations = await db.Conversation.findAll({
      where: { id: conversationIds },
      include: [
        {
          model: db.ConversationParticipant,
          as: 'participants',
          include: [{ model: db.User, as: 'user', attributes: ['id', 'username', 'name', 'surname'] }]
        },
        {
          model: db.Message,
          as: 'messages',
          limit: 1,
          order: [['createdAt', 'DESC']],
          include: [{ model: db.User, as: 'sender', attributes: ['id', 'username'] }]
        }
      ],
      order: [['updatedAt', 'DESC']]
    })

    const result = conversations.map(c => {
      const lastMessage = c.messages[0] || null
      const lastReadAt = lastReadMap[c.id]
      const isUnread =
        lastMessage &&
        lastMessage.senderId !== userId &&
        (!lastReadAt || new Date(lastMessage.createdAt) > new Date(lastReadAt))

      return {
        id: c.id,
        isGroup: c.isGroup,
        name: c.name,
        participants: c.participants.map(p => p.user),
        lastMessage,
        isUnread: !!isUnread
      }
    })

    res.status(200).json({ success: true, conversations: result })
  } catch (error) {
    console.error('Get Conversations Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

// Bir sohbetin mesaj geçmişi (sayfalama ile)
exports.getMessages = async (req, res) => {
  try {
    const userId = req.user.id
    const { conversationId } = req.params
    const page = parseInt(req.query.page) || 1
    const limit = parseInt(req.query.limit) || 30

    const participant = await db.ConversationParticipant.findOne({
      where: { conversationId, userId }
    })
    if (!participant) {
      return res.status(403).json({ success: false, message: 'Bu sohbete erişim yetkin yok.' })
    }

    const messages = await db.Message.findAll({
      where: { conversationId },
      include: [{ model: db.User, as: 'sender', attributes: ['id', 'username'] }],
      order: [['createdAt', 'DESC']],
      limit,
      offset: (page - 1) * limit
    })

    res.status(200).json({ success: true, messages: messages.reverse() })
  } catch (error) {
    console.error('Get Messages Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

// Mesaj gönder
exports.sendMessage = async (req, res) => {
  try {
    const userId = req.user.id
    const { conversationId } = req.params
    const { type, content, imageUrl } = req.body

    const participant = await db.ConversationParticipant.findOne({
      where: { conversationId, userId }
    })
    if (!participant) {
      return res.status(403).json({ success: false, message: 'Bu sohbete mesaj gönderemezsin.' })
    }
    if (!content && !imageUrl) {
      return res.status(400).json({ success: false, message: 'Mesaj içeriği boş olamaz.' })
    }

    const newMessage = await db.Message.create({
      conversationId,
      senderId: userId,
      type: type || 'text',
      content,
      imageUrl
    })

    await db.Conversation.update({ updatedAt: new Date() }, { where: { id: conversationId } })

    const messageWithSender = await db.Message.findByPk(newMessage.id, {
      include: [{ model: db.User, as: 'sender', attributes: ['id', 'username'] }]
    })

    if (req.io) {
      const otherParticipants = await db.ConversationParticipant.findAll({
        where: { conversationId, userId: { [Op.ne]: userId } }
      })
      otherParticipants.forEach(p => {
        req.io.to(p.userId.toString()).emit('new_message', {
          conversationId: Number(conversationId),
          message: messageWithSender
        })
      })
    }

    res.status(201).json({ success: true, message: messageWithSender })
  } catch (error) {
    console.error('Send Message Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

// Sohbeti okundu olarak işaretle
exports.markAsRead = async (req, res) => {
  try {
    const userId = req.user.id
    const { conversationId } = req.params

    const participant = await db.ConversationParticipant.findOne({
      where: { conversationId, userId }
    })
    if (!participant) {
      return res.status(404).json({ success: false, message: 'Katılımcı bulunamadı.' })
    }

    participant.lastReadAt = new Date()
    await participant.save()

    if (req.io) {
      const otherParticipants = await db.ConversationParticipant.findAll({
        where: { conversationId, userId: { [Op.ne]: userId } }
      })
      otherParticipants.forEach(p => {
        req.io.to(p.userId.toString()).emit('message_read', {
          conversationId: Number(conversationId),
          readerId: userId
        })
      })
    }

    res.status(200).json({ success: true, message: 'Sohbet okundu olarak işaretlendi.' })
  } catch (error) {
    console.error('Mark As Read Hatası:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}