const express = require('express');
const cors = require('cors');
const db = require('./models');
require('dotenv').config();

// ROTA DOSYALARINI ÇAĞIR
const authRoutes = require('./routes/authRoutes');
const exerciseRoutes = require('./routes/exerciseRoutes');
const routineRoutes = require('./routes/routineRoutes');
const logRoutes = require('./routes/logRoutes');
const socialRoutes = require('./routes/socialRoutes');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ROTALARI KULLAN
app.use('/api/auth', authRoutes);       // http://localhost:3000/api/auth
app.use('/api/exercises', exerciseRoutes); // http://localhost:3000/api/exercises
app.use('/api/routines', routineRoutes);
app.use('/api/logs', logRoutes);
app.use('/api/social', socialRoutes);


app.get('/', (req, res) => {
  res.send('GymPlanner API Hazır Boss!');
});

const PORT = process.env.PORT || 3000;

// force: false -> Tabloları silmez
// alter: true -> Değişiklik varsa günceller
db.sequelize.sync({ alter: true }).then(() => {
  console.log('✅ Veritabanı senkronize.');
  app.listen(PORT, () => {
    console.log(`🚀 Sunucu http://localhost:${PORT} portunda çalışıyor.`);
  });
});