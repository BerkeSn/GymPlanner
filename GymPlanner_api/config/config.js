require('dotenv').config();

module.exports = {
  username: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  host: process.env.DB_HOST,
  dialect: 'postgres',

  logging: false,
  dialectOptions: {
    ssl: process.env.NODE_ENV === 'production' 
      ? { require: true, rejectUnauthorized: false } 
      : false
  }
};
