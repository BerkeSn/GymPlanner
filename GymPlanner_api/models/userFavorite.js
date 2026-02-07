const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    class UserFavorite extends Model {
        static associate(models) {
            UserFavorite.belongsTo(models.User, { 
                foreignKey: 'userId', 
                as: 'user' 
            });
            UserFavorite.belongsTo(models.Exercise, { 
                foreignKey: 'exerciseId', 
                as: 'exercise' 
            });
        }
    }

    UserFavorite.init({
    }, {
        sequelize,
        modelName: 'UserFavorite',
        timestamps: true,
        indexes: [
            {
                unique: true,
                fields: ['userId', 'exerciseId']
            }
        ]
    });
    return UserFavorite;
};