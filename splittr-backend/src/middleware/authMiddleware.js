const { CognitoJwtVerifier } = require('aws-jwt-verify');
require('dotenv').config();

const USER_POOL_ID = process.env.COGNITO_USER_POOL_ID;
const CLIENT_ID = process.env.COGNITO_CLIENT_ID;

const verifier = CognitoJwtVerifier.create({
  userPoolId: USER_POOL_ID,
  tokenUse: 'access',
  clientId: CLIENT_ID,
});

async function verifyToken(req, res, next) {
  const token =  req.headers.authorization?.split(' ')[1];

  if (!token) return res.status(401).json({ error: 'Token is missing' });

  try {
    const payload = await verifier.verify(token);

    req.userId = payload.sub;
    next();
  } catch (err) {
    console.error('Error verifying token:', err);
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token has expired' });
    } else {
      return res.status(401).json({ error: 'Invalid token' });
    }
  }
}

module.exports = verifyToken;
