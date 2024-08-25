const AWS = require('aws-sdk');
const prisma = require('../models/prismaClient');
require('dotenv').config();

const cognito = new AWS.CognitoIdentityServiceProvider({ region: process.env.AWS_REGION });
const CLIENT_ID = process.env.COGNITO_CLIENT_ID;

async function signUp(email, password, fullName) {
  const params = {
    ClientId: CLIENT_ID,
    Username: email,
    Password: password,
    UserAttributes: [
      { Name: 'email', Value: email },
      { Name: 'name', Value: fullName },
    ],
  };
  data = await cognito.signUp(params).promise();
  await prisma.user.create({
    data: {
      email,
      fullName,
      userId: data.UserSub,
    },
  });
}

async function confirmSignUp(email, code) {
  const params = {
    ClientId: CLIENT_ID,
    ConfirmationCode: code,
    Username: email,
  };
  await cognito.confirmSignUp(params).promise();
}

async function signIn(email, password) {
  const params = {
    AuthFlow: 'USER_PASSWORD_AUTH',
    ClientId: CLIENT_ID,
    AuthParameters: {
      USERNAME: email,
      PASSWORD: password,
    },
  };
  const data = await cognito.initiateAuth(params).promise();
  const { IdToken, AccessToken ,RefreshToken } = data.AuthenticationResult;

  return { IdToken, AccessToken, RefreshToken };
}

async function refreshToken(refreshToken) {
  const params = {
    AuthFlow: 'REFRESH_TOKEN_AUTH',
    ClientId: CLIENT_ID,
    AuthParameters: {
      REFRESH_TOKEN: refreshToken,
    },
  };
  const data = await cognito.initiateAuth(params).promise();
  return data.AuthenticationResult;
}

module.exports = {
  signUp,
  confirmSignUp,
  signIn,
  refreshToken,
};
