const db = require('../models')
const jwt = require('jsonwebtoken')
const bcrypt = require('bcryptjs')
const { Op } = require('sequelize')

// Register
exports.register = async (req, res) => {
  try {
    const {
      username,
      email,
      password,
      name,
      surname,
      phone,
      birthdate,
      gender
    } = req.body

    if (!username || !email || !password || !name || !surname || !gender) {
      return res.status(400).json({ message: 'Lütfen tüm alanları doldurun' })
    }

    const existingUsername = await db.User.findOne({ where: { username } })
    if (existingUsername) {
      return res
        .status(400)
        .json({ message: 'Bu kullanıcı adı zaten alınmış.' })
    }

    const existingUser = await db.User.findOne({ where: { email } })

    if (existingUser) {
      return res.status(400).json({ message: 'Bu email zaten kayıtlı.' })
    }

    const existingPhone = await db.User.findOne({ where: { phone } })
    if (existingPhone) {
      return res
        .status(400)
        .json({ message: 'Bu telefon numarası zaten kayıtlı.' })
    }

    const salt = await bcrypt.genSalt(10)
    const hashedPassword = await bcrypt.hash(password, salt)

    const newUser = await db.User.create({
      username,
      email,
      password: hashedPassword,
      name,
      surname,
      phone,
      birthdate,
      gender
    })

    const userResponse = newUser.toJSON()
    delete userResponse.password

    const token = jwt.sign({ id: newUser.id }, process.env.JWT_SECRET, {
      expiresIn: '24h'
    })

    res.status(201).json({
      message: 'Kullanıcı başarıyla oluşturuldu!',
      user: userResponse,
      token: token
    })
  } catch (error) {
    res.status(500).json({
      message: 'Kayıt sırasında bir hata oluştu.',
      error: error.message
    })
  }
}

// Login
exports.login = async (req, res) => {
  try {
    const { loginInput, password } = req.body

    if (!loginInput || !password) {
      return res.status(400).json({
        success: false,
        message: 'Lütfen e-posta veya kullanıcı adı ve şifrenizi girin.'
      })
    }

    const user = await db.User.findOne({
      where: {
        [Op.or]: [
          { email: loginInput },
          { username: loginInput },
          { phone: loginInput }
        ]
      }
    })

    if (!user) {
      return res
        .status(401)
        .json({ success: false, message: 'E-posta veya şifre hatalı.' })
    }

    const isValid = await bcrypt.compare(password, user.password)

    if (!isValid) {
      return res
        .status(401)
        .json({ success: false, message: 'E-posta veya şifre hatalı.' })
    }

    const token = jwt.sign(
      {
        id: user.id
      },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    )

    const userData = user.toJSON()
    delete userData.password

    res.status(200).json({
      success: true,
      message: 'Giriş başarılı!',
      token: token,
      user: userData
    })
  } catch (error) {
    res.status(500).json({ success: false, error: error.message })
  }
}

// Update Profile
exports.updateProfile = async (req, res) => {
  try {
    const userId = req.user.id
    const {
      username,
      name,
      surname,
      phone,
      birthdate,
      gender,
      locationPreference,
      email
    } = req.body

    if (username) {
      const userWithSameName = await db.User.findOne({ where: { username } })
      if (userWithSameName && userWithSameName.id !== userId) {
        return res
          .status(400)
          .json({ success: false, message: 'Kullanıcı adı kullanımda.' })
      }
    }

    if (phone) {
      const userWithSamePhone = await db.User.findOne({ where: { phone } })
      if (userWithSamePhone && userWithSamePhone.id !== userId) {
        return res
          .status(400)
          .json({ success: false, message: 'Telefon numarası kullanımda.' })
      }
    }

    if (email) {
      const userWithSameEmail = await db.User.findOne({ where: { email } })
      if (userWithSameEmail && userWithSameEmail.id !== userId) {
        return res
          .status(400)
          .json({ success: false, message: 'E-posta kullanımda.' })
      }
    }

    // --- Güncelleme Objesi Hazırlama (Sadece dolu gelenleri güncelle) ---
    const updateFields = {}
    if (username) updateFields.username = username
    if (name) updateFields.name = name
    if (surname) updateFields.surname = surname
    if (phone) updateFields.phone = phone
    if (birthdate) updateFields.birthdate = birthdate
    if (gender) updateFields.gender = gender
    if (email) updateFields.email = email
    if (locationPreference !== undefined)
      updateFields.locationPreference = locationPreference

    const [updatedRows] = await db.User.update(updateFields, {
      where: { id: userId }
    })

    const updatedUser = await db.User.findByPk(userId, {
      attributes: { exclude: ['password'] }
    })

    res.status(200).json({
      success: true,
      message:
        updatedRows > 0 ? 'Profil güncellendi.' : 'Değişiklik yapılmadı.',
      user: updatedUser
    })
  } catch (error) {
    console.error('Update Error:', error)
    res.status(500).json({ success: false, error: error.message })
  }
}

// Adding Friends
exports.addFriend = async (req, res) => {
  try {
    const requesterId = req.user.id
    const receiverId = req.params.receiverId

    if (requesterId == receiverId) {
      return res
        .status(400)
        .json({ success: false, message: 'Kendine istek atamazsın!' })
    }

    const existingFriendship = await db.Friendship.findOne({
      where: {
        [Op.or]: [
          { requesterId: requesterId, receiverId: receiverId },
          { requesterId: receiverId, receiverId: requesterId }
        ]
      }
    })

    if (existingFriendship) {
      return res.status(400).json({
        success: false,
        message:
          'Bu kullanıcıyla zaten bir etkileşimin var (İstek atılmış, arkadaşsınız veya reddedilmiş).'
      })
    }

    const newRequest = await db.Friendship.create({
      requesterId,
      receiverId
    })

    res.status(201).json({
      success: true,
      message: 'Arkadaşlık isteği başarıyla gönderildi!',
      request: newRequest
    })
  } catch (error) {
    console.error('Send Request Hatası:', error)
    res
      .status(500)
      .json({ success: false, error: 'İstek gönderilirken hata oluştu.' })
  }
}

// Respond to Friend Request (Accept/Reject)
exports.respondToRequest = async (req, res) => {
  try {
    const userId = req.user.id
    const { friendshipId } = req.params
    const { status } = req.body

    if (!['accepted', 'rejected'].includes(status)) {
      return res
        .status(400)
        .json({ success: false, message: 'Geçersiz durum kanka.' })
    }

    const friendship = await db.Friendship.findOne({
      where: { id: friendshipId, receiverId: userId, status: 'pending' }
    })

    if (!friendship) {
      return res.status(404).json({
        success: false,
        message: 'Bekleyen böyle bir istek bulunamadı veya sana ait değil.'
      })
    }

    friendship.status = status
    await friendship.save()

    res.status(200).json({
      success: true,
      message:
        status === 'accepted'
          ? 'Arkadaşlık isteği kabul edildi! 🤝'
          : 'İstek reddedildi.'
    })
  } catch (error) {
    console.error('Respond Request Hatası:', error)
    res
      .status(500)
      .json({ success: false, error: 'İstek yanıtlanırken bir hata oluştu.' })
  }
}

// Get Friends List & Pending Requests
exports.getMyFriends = async (req, res) => {
  try {
    const userId = req.user.id

    const friendships = await db.Friendship.findAll({
      where: {
        [Op.or]: [{ requesterId: userId }, { receiverId: userId }],
        status: 'accepted'
      },
      include: [
        { model: db.User, as: 'requester', attributes: ['id', 'username'] },
        { model: db.User, as: 'receiver', attributes: ['id', 'username'] }
      ]
    })

    const friendsList = friendships.map(f => {
      return f.requesterId === userId ? f.receiver : f.requester
    })

    res.status(200).json({
      success: true,
      count: friendsList.length,
      friends: friendsList
    })
  } catch (error) {
    console.error('Get Friends Hatası:', error)
    res
      .status(500)
      .json({ success: false, error: 'Arkadaşlar getirilirken hata oluştu.' })
  }
}

//
exports.getPendingRequests = async (req, res) => {
  try {
    const userId = req.user.id

    const pendingRequests = await db.Friendship.findAll({
      where: { receiverId: userId, status: 'pending' },
      include: [
        { model: db.User, as: 'requester', attributes: ['id', 'username'] }
      ]
    })

    res.status(200).json({
      success: true,
      count: pendingRequests.length,
      requests: pendingRequests
    })
  } catch (error) {
    console.error('Get Pending Requests Hatası:', error)
    res
      .status(500)
      .json({ success: false, error: 'Bekleyen istekler getirilemedi.' })
  }
}
