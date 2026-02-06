const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  try {
    const token = req.headers.authorization.split(" ")[1];

    if (!token) {
      return res.status(401).json({ 
        success: false,
        message: "Yetkisiz Giriş! Lütfen giriş yapın." 
      });
    }
    
    try {
    const decodedToken = jwt.verify(token, process.env.JWT_SECRET);
    req.userData = { id: decodedToken.id };
    } catch (err) {
      return res.status(401).json({ 
        success: false,
        message: "Geçersiz Token! Lütfen tekrar giriş yapın." 
      });
    }
    next(); 

  } catch (error) {
    return res.status(401).json({ 
      success: false,
      message: "Yetkisiz Giriş! Lütfen giriş yapın." 
    });
  }
};