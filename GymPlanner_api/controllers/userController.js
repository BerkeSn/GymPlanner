const db = require('../models');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// Register
exports.register = async (req, res) => {
  try {
    const { username, email, password, name, surname, phone, birthdate, gender } = req.body;

    if (!username || !email || !password || !name || !surname || !gender) {
      return res.status(400).json({ message: "Lütfen tüm alanları doldurun" });
    }

    const existingUsername = await db.User.findOne({ where: { username } });
    if (existingUsername) {
      return res.status(400).json({ message: "Bu kullanıcı adı zaten alınmış." });
    }

    const existingUser = await db.User.findOne({ where: { email } });

    if (existingUser) {
      return res.status(400).json({ message: "Bu email zaten kayıtlı." });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const newUser = await db.User.create({
      username,
      email,
      password: hashedPassword,
      name,
      surname,
      phone,
      birthdate,
      gender
    });

    const userResponse = newUser.toJSON();
    delete userResponse.password;

    const token = jwt.sign(
      { id: newUser.id },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.status(201).json({
      message: "Kullanıcı başarıyla oluşturuldu!",
      user: userResponse,
      token: token
    });

  } catch (error) {
    res.status(500).json({
      message: "Kayıt sırasında bir hata oluştu.",
      error: error.message
    });
  }
};

// Login
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await db.User.findOne({ where: { email } });

    if (!user) {
      return res.status(401).json({ success: false, message: "E-posta veya şifre hatalı." });
    }

    const isValid = await bcrypt.compare(password, user.password);

    if (!isValid) {
      return res.status(401).json({ success: false, message: "E-posta veya şifre hatalı." });
    }

    const token = jwt.sign(
      {
        id: user.id,
      },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    const userData = user.toJSON();
    delete userData.password;

    res.status(200).json({
      success: true,
      message: "Giriş başarılı!",
      token: token,
      user: userData
    });

  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// Update
exports.updateProfile = async (req, res) => {
  try {
    const userId = req.userData.id;
    const { username, name, surname, phone, birthdate, gender, locationPreference } = req.body;

    if (username) {
      const userWithSameName = await db.User.findOne({ where: { username } });

      if (userWithSameName && userWithSameName.id !== userId) {
        return res.status(400).json({
          success: false,
          message: "Bu kullanıcı adı başkası tarafından kullanılıyor Agam, başka bir tane seç."
        });
      }
    }

    // 3. Güncelleme İşlemi
    const [updatedRows] = await db.User.update(
      { username, name, surname, phone, birthdate, gender, locationPreference },
      { where: { id: userId } }
    );

    // 4. Kritik Müdahale: Güncelleme sonucuna bakmadan önce, son halini çekiyoruz.
    const updatedUser = await db.User.findByPk(userId, {
      attributes: { exclude: ['password'] }
    });

    if (!updatedUser) {
      return res.status(404).json({ success: false, message: "Kullanıcı bulunamadı." });
    }

    res.status(200).json({
      success: true,
      message: updatedRows > 0 ? "Profil başarıyla güncellendi." : "Herhangi bir değişiklik yapılmadı.",
      user: updatedUser
    });

  } catch (error) {
    console.error("Update Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};