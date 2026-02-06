const bcrypt = require('bcryptjs'); // Şifreleme kütüphanesini çağırdık

module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define("User", {
    username: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true // Aynı kullanıcı adı 2 kere alınamaz
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true, // Aynı email ile 2 kere kayıt olunamaz
      validate: {
        isEmail: true // Email formatı kontrolü (örn: a@b olmaz, a@b.com olmalı)
      }
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false
    },
    role: {
      type: DataTypes.ENUM('coach', 'gymrat'),
      defaultValue: 'gymrat'
    },
    bio: {
      type: DataTypes.STRING
    }
  }, {
    // HOOKS: Veritabanına yazmadan hemen önce araya giren fonksiyonlar
    hooks: {
      // 1. Yeni kullanıcı oluşturulurken şifreyi şifrele
      beforeCreate: async (user) => {
        if (user.password) {
          const salt = await bcrypt.genSalt(10);
          user.password = await bcrypt.hash(user.password, salt);
        }
      },
      // 2. Profil güncellenirken EĞER şifre değiştiyse tekrar şifrele
      beforeUpdate: async (user) => {
        if (user.changed('password')) {
          const salt = await bcrypt.genSalt(10);
          user.password = await bcrypt.hash(user.password, salt);
        }
      }
    }
  });

  // INSTANCE METHOD: Giriş yaparken şifre kontrolü için özel fonksiyon
  // Bu fonksiyonu authController'da kullanacağız.
  User.prototype.validPassword = async function(password) {
    return await bcrypt.compare(password, this.password);
  };

  // İLİŞKİLER (Associations)
  User.associate = (models) => {
    // Bir kullanıcının birden fazla haftalık programı olabilir
    User.hasMany(models.WeeklyRoutine, { 
      foreignKey: 'userId',
      onDelete: 'CASCADE' // Kullanıcı silinirse programları da silinsin
    });

    // Bir kullanıcının birden fazla antrenman logu olabilir
    User.hasMany(models.WorkoutLog, { 
      foreignKey: 'userId',
      onDelete: 'CASCADE' 
    });
    
    // Arkadaşlık İlişkileri (Çoka-Çok - Self Referencing)
    User.belongsToMany(User, { 
      as: 'Friends', 
      through: models.Friendship, 
      foreignKey: 'requesterId', 
      otherKey: 'addresseeId' 
    });
    
    // Mesajlar (Gönderen ve Alan olarak 2 ayrı ilişki)
    User.hasMany(models.Message, { 
      foreignKey: 'senderId', 
      as: 'SentMessages' 
    });
    User.hasMany(models.Message, { 
      foreignKey: 'receiverId', 
      as: 'ReceivedMessages' 
    });
  };

  return User;
};