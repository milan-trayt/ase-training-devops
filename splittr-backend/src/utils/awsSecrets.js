const AWS = require('aws-sdk');

const secretCache = {};
const cacheTTL = 3600000; // 1 hour cache TTL in milliseconds

// Function to set AWS region
function setRegion(region) {
  AWS.config.update({ region: region });
}

/**
 * Fetches and caches a secret from AWS Secrets Manager.
 * @param {string} secretName - The name of the secret.
 * @returns {Promise<object>} - The parsed secret value.
 */
async function getSecretValue(secretName) {
  const now = Date.now();
  
  // Check cache
  if (secretCache[secretName] && (now - secretCache[secretName].timestamp < cacheTTL)) {
    return secretCache[secretName].value;
  }

  // Initialize SecretsManager with configured region
  const secretsManager = new AWS.SecretsManager(); 

  try {
    const data = await secretsManager.getSecretValue({ SecretId: secretName }).promise();
    let secretValue;

    if ('SecretString' in data) {
      secretValue = JSON.parse(data.SecretString);
    } else {
      const buff = Buffer.from(data.SecretBinary, 'base64');
      secretValue = JSON.parse(buff.toString('ascii'));
    }

    // Update cache
    secretCache[secretName] = {
      value: secretValue,
      timestamp: now
    };

    return secretValue;
  } catch (err) {
    console.error(`Error retrieving secret ${secretName}:`, err);
    throw err;
  }
}

/**
 * Retrieves a specific secret by key.
 * @param {string} secretName - The name of the secret.
 * @param {string} key - The key within the secret value to retrieve.
 * @returns {Promise<string>} - The value associated with the key.
 */
async function getSecretValueByKey(secretName, key) {
  const secret = await getSecretValue(secretName);
  return secret[key];
}

module.exports = { getSecretValue, getSecretValueByKey, setRegion };
