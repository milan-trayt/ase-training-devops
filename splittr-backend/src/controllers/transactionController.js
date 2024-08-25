const transactionService = require('../services/transactionService');

async function getTransactions(req, res) {
  const { startDate, endDate } = req.query;
  const userId = req.userId;

  try {
    const transactions = await transactionService.getTransactions(userId, startDate, endDate);
    res.status(200).send(transactions);
  } catch (error) {
    res.status(500).send(error.message);
  }
}

async function createTransaction(req, res) {
  const { name, type, amount } = req.body;
  const userId = req.userId;

  try {
    const transaction = await transactionService.createTransaction(userId, name, type, amount);
    res.status(201).send(transaction);
  } catch (error) {
    res.status(500).send(error.message);
  }
}

module.exports = {
  getTransactions,
  createTransaction,
};
