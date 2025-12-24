const db = require('../models');
const User = db.User;
const Friendship = db.Friendship;
const { Op } = require('sequelize'); // Gelişmiş sorgular için

// 1. Arkadaşlık İsteği Gönder
exports.sendRequest = async (req, res) => {
  try {
    const { requesterId, addresseeId } = req.body;

    if(requesterId === addresseeId) return res.status(400).json({message: "Kendine istek atamazsın Boss!"});

    const existing = await Friendship.findOne({
      where: { requesterId, addresseeId }
    });

    if (existing) return res.status(400).json({ message: "Zaten bir istek var veya arkadaşsınız." });

    await Friendship.create({
      requesterId,
      addresseeId,
      status: 'pending'
    });

    res.status(200).json({ message: "İstek gönderildi." });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 2. İsteği Kabul Et
exports.acceptRequest = async (req, res) => {
  try {
    const { requesterId, addresseeId } = req.body; // İsteği atan ve kabul eden

    // Durumu güncelle
    const updated = await Friendship.update(
      { status: 'accepted' },
      { where: { requesterId, addresseeId, status: 'pending' } }
    );

    if (updated[0] === 0) return res.status(404).json({ message: "Bekleyen istek bulunamadı." });

    res.status(200).json({ message: "Artık arkadaşsınız!" });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 3. Arkadaş Listesini Getir
exports.getFriends = async (req, res) => {
  try {
    const { userId } = req.params;

    // Burada biraz SQL büyüsü gerekebilir ama Sequelize ile şöyle yaparız:
    // Hem 'requester' hem 'addressee' olduğum ve durumun 'accepted' olduğu kayıtları bul.
    // Şimdilik basitçe Friendship tablosundan çekelim.
    
    const friends = await Friendship.findAll({
        where: {
            [Op.or]: [{ requesterId: userId }, { addresseeId: userId }],
            status: 'accepted'
        }
    });

    res.status(200).json(friends);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};