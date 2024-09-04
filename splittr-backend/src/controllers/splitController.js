const splitService = require('../services/splitService');

async function getSplit(req, res) {
  const userId = req.userId;

  try {
    const splits = await splitService.getSplits(userId);
    res.status(200).send(splits);
  } catch (error) {
    res.status(500).send(error.message);
  }
}

async function createSplit(req, res) {
  const { split_name, amount, participants } = req.body;
  const userId = req.userId;

  try {
    const split = await splitService.createSplit({ split_name, amount, participants, userId });
    res.status(201).send(split);
  } catch (error) {
    res.status(500).send(error.message);
  }
}

async function paidByOne(req, res) {
  const { splitId, participantName, amount } = req.body;
  const userId = req.userId;

  try {
    const result = await splitService.paidByOne({ splitId, participantName, amount, userId });
    res.status(200).send(result);
  } catch (error) {
    res.status(500).send(error.message);
  }
}

async function paidByAll(req, res) {
  const { splitId } = req.body;
  const  userId = req.userId;

  try {
    const result = await splitService.paidByAll({ splitId, userId });
    res.status(200).send(result);
  } catch (error) {
    res.status(500).send(error.message);
  }
}

module.exports = {
  getSplit,
  createSplit,
  paidByOne,
  paidByAll
};
