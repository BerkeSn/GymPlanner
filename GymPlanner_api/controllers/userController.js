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

    res.status(201).json({
      message: "Kullanıcı başarıyla oluşturuldu!",
      user: userResponse
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

    // 1. Kullanıcıyı bul
    const user = await db.User.findOne({ where: { email } });

    if (!user) {
      return res.status(401).json({ success: false, message: "E-posta veya şifre hatalı." });
    }

    // 2. Şifreyi kontrol et
    const isValid = await bcrypt.compare(password, user.password);

    if (!isValid) {
      return res.status(401).json({ success: false, message: "E-posta veya şifre hatalı." });
    }

    // 3. Token Oluştur (İmza atıyoruz)
    const token = jwt.sign(
      { 
        id: user.id, 
      }, 
      process.env.JWT_SECRET,
      { expiresIn: '24h' }  
    );

    const userData = user.toJSON();
    delete userData.password;

    // 4. Cevabı Gönder
    res.status(200).json({
      success: true,
      message: "Giriş başarılı!",
      token: token, // <-- İşte frontend'in saklayacağı altın anahtar
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
    const { name, surname, phone, birthdate, gender } = req.body;

    // 3. Güncelleme İşlemi
    const [updated] = await db.User.update(
      { name, surname, phone, birthdate, gender },
      { where: { id: userId } }
    );

    if (!updated) {
      return res.status(404).json({ success: false, message: "Kullanıcı bulunamadı." });
    }

    // 4. Güncel veriyi çek (Şifreyi hariç tutarak)
    const updatedUser = await User.findByPk(userId, {
        attributes: { exclude: ['password'] }
    });

    res.status(200).json({ 
      success: true,
      message: "Profil başarıyla güncellendi.", 
      user: updatedUser 
    });

  } catch (error) {
    console.error("Update Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};