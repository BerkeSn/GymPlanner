const express = require('express')
const cors = require('cors')
const http = require('http')
const { Server } = require('socket.io')
const fileUpload = require('express-fileupload')
const path = require('path')
const db = require('./models')
require('dotenv').config()

const apiRoutes = require('./routes')

const app = express()

const server = http.createServer(app)

const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE']
  }
})

// --- AYARLAR ---
app.use(cors())

app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ extended: true, limit: '10mb' }))

app.use((req, res, next) => {
  req.io = io
  next()
})

// Dosya Yükleme Middleware'i
app.use(fileUpload())

app.use('/uploads', express.static(path.join(__dirname, 'uploads')))

app.use('/api', apiRoutes)

app.get('/', (req, res) => {
  res.send('GymPlanner API is working!')
})

io.on('connection', socket => {
  console.log('Bir kullanıcı bağlandı! Socket ID:', socket.id)

  // Kullanıcı Flutter'dan giriş yapınca kendi odasına (kendi ID'sine) katılsın
  socket.on('join_own_room', userId => {
    socket.join(userId.toString())
    console.log(`👤 Kullanıcı ${userId} kendi odasına katıldı.`)
  })

  socket.on('disconnect', () => {
    console.log('🔴 Kullanıcı ayrıldı:', socket.id)
  })
})

const PORT = process.env.PORT || 3000

// Veritabanı Senkronizasyonu
db.sequelize.sync({ alter: true }).then(() => {
  console.log('✅ Veritabanı senkronize.')

  app.listen(PORT, () => {
    console.log(`🚀 Sunucu http://localhost:${PORT} portunda çalışıyor.`)
  })
})
