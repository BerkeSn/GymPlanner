const db = require('../models');
const User = db.User;

exports.register = async (req, res) => {
  try {
    const { username, email, password, role, bio } = req.body;

    if (!username || !email || !password) {
      return res.status(400).json({ message: "Lütfen tüm alanları doldurun Boss!" });
    }

    const newUser = await User.create({
      username,
      email,
      password,
      role: role || 'gymrat',
      bio
    });

    res.status(201).json({
      message: "Kullanıcı başarıyla oluşturuldu!",
      user: newUser
    });

  } catch (error) {
    res.status(500).json({
      message: "Kayıt sırasında bir hata oluştu.",
      error: error.message
    });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ where: { email } });

    if (!user) {
      return res.status(404).json({ message: "Böyle bir kullanıcı bulunamadı." });
    }

    if (user.password !== password) {
      return res.status(401).json({ message: "Şifre yanlış Boss!" });
    }

    res.status(200).json({
      message: "Giriş başarılı!",
      user: {
        id: user.id,
        username: user.username,
        role: user.role
      }
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 3. Profil Güncelle (UPDATE)
exports.updateProfile = async (req, res) => {
  try {
    const { id } = req.params; // URL'den ID'yi alıyoruz (/api/auth/update/1 gibi)
    const { bio, password, email } = req.body; // Değişmesini istediğimiz veriler

    // DİKKAT: Şifre güncelleme varsa hashleme gerekir (Şimdilik düz yapıyoruz ama ilerde değişecek)
    
    const [updated] = await User.update(req.body, {
      where: { id: id }
    });

    if (!updated) {
      return res.status(404).json({ message: "Kullanıcı bulunamadı." });
    }

    // Güncel kullanıcıyı geri döndürelim
    const updatedUser = await User.findByPk(id);

    res.status(200).json({ 
      message: "Profil güncellendi.", 
      user: updatedUser 
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};