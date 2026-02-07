const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    class Friendship extends Model {
        static associate(models) {
            Friendship.belongsTo(models.User, { 
                foreignKey: 'requesterId', 
                as: 'requester' 
            });
            Friendship.belongsTo(models.User, { 
                foreignKey: 'receiverId', 
                as: 'receiver' 
            });
        }
    }

    Friendship.init({
        status: {
            type: DataTypes.ENUM('pending', 'accepted', 'rejected'),
            allowNull: false,
            defaultValue: 'pending'
        }
    }, {
        sequelize,
        modelName: 'Friendship',
        timestamps: true 
    });
    return Friendship;
};