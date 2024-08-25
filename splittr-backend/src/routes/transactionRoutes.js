const express = require('express');
const router = express.Router();
const transactionController = require('../controllers/transactionController');
const verifyToken = require('../middleware/authMiddleware');

router.get('/transaction', verifyToken, transactionController.getTransactions);
router.post('/transaction', verifyToken, transactionController.createTransaction);

module.exports = router;
