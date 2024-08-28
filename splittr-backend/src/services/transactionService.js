const prisma = require('../models/prismaClient');

async function getTransactions(userId, startDate, endDate) {
  const query = {
    where: {
      userId,
    },
  };

  if (startDate && !endDate) {
    query.where.date = {
      gte: new Date(startDate),
      lte: new Date(),
    };
  }
  
  if (!startDate && endDate) {
    query.where.date = {
      gte: new Date('1970-01-01T00:00:00Z'),
      lte: new Date(endDate),
    };
  }

  if (startDate && endDate) {
    query.where.date = {
      gte: new Date(startDate),
      lte: new Date(endDate),
    };
  }

  return prisma.transaction.findMany(query);
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
