const express = require('express');
const cors = require('cors');
const fileUpload = require('express-fileupload');
const path = require('path');
const db = require('./models');
require('dotenv').config();

const apiRoutes = require('./routes'); 

const app = express();

// --- AYARLAR ---
app.use(cors());

app.use(express.json({ limit: '10mb' })); 
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Dosya Yükleme Middleware'i
app.use(fileUpload());

// Örn: http://localhost:3000/uploads/yemek.jpg
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.use('/api', apiRoutes); 

app.get('/', (req, res) => {
  res.send('GymPlanner API is working!');
});

const PORT = process.env.PORT || 3000;

// Veritabanı Senkronizasyonu
db.sequelize.sync({ force: true }).then(() => {
  console.log('✅ Veritabanı senkronize.');
  // require('./seed')(db); 
  
  app.listen(PORT, () => {
    console.log(`🚀 Sunucu http://localhost:${PORT} portunda çalışıyor.`);
  });
});