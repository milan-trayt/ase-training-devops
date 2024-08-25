const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.post('/signup', authController.signUp);
router.post('/verify', authController.confirmSignUp);
router.post('/signin', authController.signIn);
router.post('/refresh', authController.refreshToken);

module.exports = router;
