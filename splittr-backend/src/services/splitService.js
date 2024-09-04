const prisma = require('../models/prismaClient');
const transactionService = require('./transactionService');

async function getSplits(userId) {
  try {
    return await prisma.split.findMany({
      where: { userId },
      include: { participants: true },
    });
  } catch (error) {
    console.error('Error fetching splits:', error);
    throw new Error('Unable to fetch splits');
  }
}

async function createSplit({ split_name, amount, participants, userId }) {
  if (!Array.isArray(participants) || participants.length === 0) {
    throw new Error('Participants should be a non-empty array.');
  }

  const amountPerParticipant = amount / (participants.length + 1);

  const createdSplit = await prisma.$transaction(async (prisma) => {
    const split = await prisma.split.create({
      data: {
        name: split_name,
        userId,
        participants: {
          create: participants.map(name => ({
            name,
            amount: amountPerParticipant,
          })),
        },
      },
      include: {
        participants: true,
      },
    });

    await transactionService.createTransaction(
      userId,
      `Split created: ${split_name}`,
      'expense',
      amount
    );

    return split;
  });

  return createdSplit;
}

async function paidByOne({ splitId, participantName, amount, userId }) {
  const split = await prisma.split.findUnique({
    where: { id: splitId },
    include: { participants: true },
  });

  if (!split) {
    throw new Error('Split not found.');
  }


  const participant = split.participants.find(p => p.name === participantName);

  if (!participant) {
    throw new Error('Participant not found in this split.');
  }

  if (amount > participant.amount) {
    throw new Error('Amount to deduct exceeds participant\'s balance.');
  }

  await transactionService.createTransaction(
    userId,
    `Payment for ${split.name} - ${participant.name}`,
    'income',
    amount,
  );

  await prisma.participant.update({
    where: { id: participant.id },
    data: { amount: participant.amount - amount },
  });

  return { message: 'Payment recorded and participant updated' };
}

async function paidByAll({ splitId, userId }) {
  const split = await prisma.split.findUnique({
    where: { id: splitId },
    include: { participants: true },
  });

  if (!split) {
    throw new Error('Split not found.');
  }

  const participants = split.participants;

  if (participants.length === 0) {
    throw new Error('No participants found for this split.');
  }

  await Promise.all(participants.map(async participant => {
    await transactionService.createTransaction(
      userId,
      `Payment for ${split.name} - ${participant.name}`,
      'income',
      participant.amount,
    );
  }));

  await prisma.participant.updateMany({
    where: { splitId },
    data: { amount: 0 },
  });

  return { message: 'Payments recorded and all participants updated' };
}

module.exports = {
  getSplits,
  createSplit,
  paidByAll,
  paidByOne
};
