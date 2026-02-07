const {Model} = require('sequelize');

module.exports = (sequelize, DataTypes) => {
    class Equipment extends Model {
        static associate(models) {
            Equipment.hasMany(models.Exercise, 
                { foreignKey: 'equipmentId', as: 'exercises' }
            )
        }
    }
    Equipment.init({
        name: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true
        },
    }, {
        sequelize,
        modelName: 'Equipment',
        timestamps: false
    });
    return Equipment;
}