const express = require('express')
const fs = require('fs')
const router = express.Router()

// Route dosyalarını filtrele
const routeFiles = fs.readdirSync(__dirname).filter(file => {
  return (
    file.indexOf('.js') !== -1 &&
    file !== 'index.js' &&
    file.endsWith('Route.js')
  )
})

routeFiles.forEach(file => {
  try {
    const route = require(`./${file}`)

    const routePath = file.replace('Route.js', '').toLowerCase()

    router.use(`/${routePath}`, route)

  } catch (error) {
    console.error(`❌ Route yüklenirken hata oluştu: ${file}`, error)
  }
})

module.exports = router
