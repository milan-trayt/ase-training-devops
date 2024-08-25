const prisma = require('../models/prismaClient');

async function getTransactions(userId, startDate, endDate) {
  return prisma.transaction.findMany({
    where: {
      userId,
      date: {
        gte: new Date(startDate || new Date().setDate(1)),
        lte: new Date(endDate || new Date()),
      },
    },
  });
}

async function createTransaction(userId, name, type, amount) {
  return prisma.transaction.create({
    data: {
      name,
      type,
      amount,
      userId,
    },
  });
}

module.exports = {
  getTransactions,
  createTransaction,
};
