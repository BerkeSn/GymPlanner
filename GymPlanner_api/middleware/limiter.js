const rateLimit = require('express-rate-limit');

// Genel koruma (Tüm API için)
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 Dakika (Milisaniye cinsinden)
  max: 100, // 15 dakika içinde her IP için maksimum 100 istek
  message: {
    success: false,
    message: "Çok fazla istek gönderdiniz, lütfen 15 dakika sonra tekrar deneyin."
  },
  standardHeaders: true, // `RateLimit-*` başlıklarını döner
  legacyHeaders: false, // `X-RateLimit-*` başlıklarını devre dışı bırakır
});

// Giriş denemesi koruması (Login/Register için daha sıkı!)
// Brute-force saldırılarını engellemek için
const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 Saat
  max: 5, // 1 saat içinde en fazla 5 yanlış deneme veya kayıt isteği
  message: {
    success: false,
    message: "Çok fazla giriş denemesi yaptınız. Lütfen 1 saat bekleyin."
  }
});

module.exports = { apiLimiter, authLimiter };