const db = require('../models')
const data = require('./exercises.json')

async function run() {
  try {
    await db.sequelize.authenticate()
    console.log('✅ Veritabanına bağlanıldı.')

    let created = 0
    let skipped = 0

    for (const item of data) {
      const [muscleGroup] = await db.MuscleGroup.findOrCreate({
        where: { name: item.muscleGroup },
        defaults: { name: item.muscleGroup }
      })

      const [equipment] = await db.Equipment.findOrCreate({
        where: { name: item.equipment },
        defaults: { name: item.equipment }
      })

      const [exercise, wasCreated] = await db.Exercise.findOrCreate({
        where: { name: item.name },
        defaults: {
          description: item.description,
          difficulty: item.difficulty || 'Beginner',
          muscleGroupId: muscleGroup.id,
          equipmentId: equipment.id
        }
      })

      wasCreated ? created++ : skipped++
    }

    console.log(`✅ Seed tamamlandı. Eklenen: ${created}, zaten var olan: ${skipped}`)
    process.exit(0)
  } catch (error) {
    console.error('❌ Seed hatası:', error)
    process.exit(1)
  }
}

run()