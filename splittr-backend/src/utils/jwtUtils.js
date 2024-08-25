const jwt = require('jsonwebtoken');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET;

function generateToken(payload) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: '1h' });
}

function verifyToken(token, callback) {
  jwt.verify(token, JWT_SECRET, callback);
}

module.exports = {
  generateToken,
  verifyToken,
};
