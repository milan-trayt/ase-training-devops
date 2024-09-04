const express = require('express');
const router = express.Router();
const splitController = require('../controllers/splitController');
const verifyToken = require('../middleware/authMiddleware');

router.post('/create', verifyToken, splitController.createSplit);

router.post('/paidByOne', verifyToken, splitController.paidByOne);

router.post('/paidByAll', verifyToken, splitController.paidByAll);

module.exports = router;
