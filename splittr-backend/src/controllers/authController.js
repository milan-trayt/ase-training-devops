const authService = require('../services/authService');

async function signUp(req, res) {
  const { email, password, fullName } = req.body;
  try {
    await authService.signUp(email, password, fullName);
    res.status(201).send('User signed up');
  } catch (error) {
    res.status(500).send(error.message);
  }
}

async function confirmSignUp(req, res) {
  const { email, code } = req.body;
  try {
    await authService.confirmSignUp(email, code);
    res.status(200).send('User confirmed');
  } catch (error) {
    res.status(400).send(error.message);
  }
}

async function signIn(req, res) {
  const { email, password } = req.body;
  try {
    const { IdToken, AccessToken, RefreshToken } = await authService.signIn(email, password);
    res.status(200).send({ IdToken, AccessToken, RefreshToken });
  } catch (error) {
    res.status(401).send(error.message);
  }
}

async function refreshToken(req, res) {
  const { refreshToken } = req.body;
  try {
    const { IdToken } = await authService.refreshToken(refreshToken);
    res.status(200).send({ IdToken });
  } catch (error) {
    res.status(401).send(error.message);
  }
}

module.exports = {
  signUp,
  confirmSignUp,
  signIn,
  refreshToken,
};
