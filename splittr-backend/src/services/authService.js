const AWS = require('aws-sdk');
const prisma = require('../models/prismaClient');
require('dotenv').config();
const { getSecretValueByKey, setRegion } = require('../utils/awsSecrets');

const SECRET_NAME = 'dev-api';

let cognito;
let CLIENT_ID;

async function initialize() {
  setRegion('us-east-1');
  const secrets = await getSecrets();
  const { region, clientId } = secrets;

  if (!region || !clientId) {
    throw new Error('AWS_REGION or COGNITO_CLIENT_ID is missing in the secrets');
  }

  cognito = new AWS.CognitoIdentityServiceProvider({ region });
  CLIENT_ID = clientId;
}

async function getSecrets() {
  const region = await getSecretValueByKey(SECRET_NAME, 'AWS_REGION');
  const clientId = await getSecretValueByKey(SECRET_NAME, 'COGNITO_CLIENT_ID');

  if (!region || !clientId) {
    throw new Error('AWS_REGION or COGNITO_CLIENT_ID is missing in the secrets');
  }

  return { region, clientId };
}

async function signUp(email, password, fullName) {
  await initialize(); // Ensure initialization is complete

  let cognitoUserId;

  try {
    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (user) {
      throw new Error('Already exists');
    }

    const prismaTransaction = await prisma.$transaction(async (prismaTx) => {
      try {
        await prismaTx.user.create({
          data: {
            email,
            fullName,
            userId: email,
          },
        });

        const cognitoParams = {
          ClientId: CLIENT_ID,
          Username: email,
          Password: password,
          UserAttributes: [
            { Name: 'email', Value: email },
            { Name: 'name', Value: fullName },
          ],
        };

        console.log(cognitoParams);

        const cognitoResponse = await cognito.signUp(cognitoParams).promise();
        cognitoUserId = cognitoResponse.UserSub;

        const updatedUser = await prismaTx.user.update({
          where: { email },
          data: { userId: cognitoUserId },
        });

        return updatedUser;
      } catch (error) {
        throw new Error(`${error.message}`);
      }
    });

    return prismaTransaction;
  } catch (error) {
    if (error.message.includes('Already exists')) {
      throw new Error('User already exists for this email.');
    } else if (error.message.includes('Password did not conform with policy')) {
      throw new Error('Password does not meet policy requirements.');
    } else {
      throw new Error(error);
    }
  }
}

async function confirmSignUp(email, code) {
  await initialize(); // Ensure initialization is complete

  try {
    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      throw new Error('No Data');
    } else if (user.verified) {
      throw new Error('Verified');
    }

    const params = {
      ClientId: CLIENT_ID,
      ConfirmationCode: code,
      Username: email,
    };
    await cognito.confirmSignUp(params).promise();

    await prisma.user.update({
      where: { email },
      data: { verified: true },
    });
  } catch (error) {
    console.log(error);
    if (error.message.includes('Invalid')) {
      throw new Error('Confirmation code is incorrect.');
    } else if (error.message.includes('No Data')) {
      throw new Error('User does not exist');
    } else if (error.message.includes('Verified')) {
      throw new Error('User is already verified.');
    } else {
      throw new Error('Internal error. Please try again later.');
    }
  }
}

async function resendConfirmationCode(email) {
  await initialize(); // Ensure initialization is complete

  try {
    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      throw new Error('No Data');
    } else if (user.verified) {
      throw new Error('Verified.');
    }

    const params = {
      ClientId: CLIENT_ID,
      Username: email,
    };
    await cognito.resendConfirmationCode(params).promise();

    return 'A new confirmation code has been sent to your email.';
  } catch (error) {
    if (error.message.includes('No Data')) {
      throw new Error('User does not exist.');
    } else if (error.message.includes('Verified')) {
      throw new Error('User is already verified.');
    } else if (error.message.includes('limit')) {
      throw new Error('Code limit exceeded. Please try again later.');
    } else {
      throw new Error('ResendConfirmationCode failed. Please try again later.');
    }
  }
}

async function signIn(email, password) {
  await initialize(); // Ensure initialization is complete

  try {
    const params = {
      AuthFlow: 'USER_PASSWORD_AUTH',
      ClientId: CLIENT_ID,
      AuthParameters: {
        USERNAME: email,
        PASSWORD: password,
      },
    };

    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      throw new Error('Not found');
    }

    const data = await cognito.initiateAuth(params).promise();
    const { IdToken, AccessToken, RefreshToken } = data.AuthenticationResult;

    return { IdToken, AccessToken, RefreshToken };
  } catch (error) {
    if (error.message.includes('Not found')) {
      throw new Error('User does not exist.');
    } else if (error.message.includes('Incorrect')) {
      throw new Error('Incorrect Password.');
    } else if (error.message.includes('not confirmed')) {
      throw new Error('Please Verify your email.');
    } else {
      throw new Error('Internal error. Please try again later.');
    }
  }
}

async function refreshToken(refreshToken) {
  await initialize(); // Ensure initialization is complete

  try {
    const params = {
      AuthFlow: 'REFRESH_TOKEN_AUTH',
      ClientId: CLIENT_ID,
      AuthParameters: {
        REFRESH_TOKEN: refreshToken,
      },
    };
    const data = await cognito.initiateAuth(params).promise();
    return data.AuthenticationResult;
  } catch (error) {
    if (error.message.includes('InvalidRefreshTokenException')) {
      throw new Error('Refresh token is invalid or expired.');
    } else {
      throw new Error('Internal error. Please try again later.');
    }
  }
}

module.exports = {
  signUp,
  confirmSignUp,
  resendConfirmationCode,
  signIn,
  refreshToken,
};
