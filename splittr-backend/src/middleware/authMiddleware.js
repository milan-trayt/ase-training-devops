const { CognitoJwtVerifier } = require('aws-jwt-verify');
const { getSecretValueByKey, setRegion } = require('../utils/awsSecrets');

const SECRET_NAME = 'dev-api';

async function getVerifier() {
  try {
    setRegion('us-east-1');
    const userPoolId = await getSecretValueByKey(SECRET_NAME, 'COGNITO_USER_POOL_ID');
    const clientId = await getSecretValueByKey(SECRET_NAME, 'COGNITO_CLIENT_ID');

    if (!userPoolId || !clientId) {
      throw new Error('COGNITO_USER_POOL_ID or COGNITO_CLIENT_ID is missing in the secrets');
    }

    return CognitoJwtVerifier.create({
      userPoolId,
      tokenUse: 'access',
      clientId,
    });
  } catch (err) {
    console.error('Error fetching verifier configuration:', err);
    throw err;
  }
}

async function verifyToken(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Token is missing' });
  }

  try {
    const verifier = await getVerifier();
    const payload = await verifier.verify(token);

    req.userId = payload.sub;
    next();
  } catch (err) {
    console.error('Error verifying token:', err);

    const statusCode = 401;
    let errorMessage = 'Invalid token';

    if (err.name === 'TokenExpiredError') {
      errorMessage = 'Token has expired';
    } else if (err.name === 'JsonWebTokenError') {
      errorMessage = 'Malformed token';
    }

    return res.status(statusCode).json({ error: errorMessage });
  }
}

module.exports = verifyToken;
