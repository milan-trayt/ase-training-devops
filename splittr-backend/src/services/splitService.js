const prisma = require('../models/prismaClient');
const transactionService = require('./transactionService');

async function createSplit({ split_name, amount, participants, userId }) {
  if (!Array.isArray(participants) || participants.length === 0) {
    throw new Error('Participants should be a non-empty array.');
  }

  const amountPerParticipant = amount / participants.length;

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

  await transactionService.createTransaction({
    userId,
    name: `Split created: ${split_name}`,
    type: 'expense',
    amount,
  });

  return split;
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

  await transactionService.createTransaction({
    userId,
    name: `Payment for ${split.name} - ${participant.name}`,
    type: 'income',
    amount,
  });

  await prisma.participant.update({
    where: { id: participant.id },
    data: { amount: participant.amount - amount },
  });

  return { message: 'Payment recorded and participant updated' };
}

async function paidByAll({ splitId }) {
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
    const user = await prisma.user.findUnique({
      where: { userId: participant.name },
    });

    if (!user) {
      throw new Error('User not found.');
    }

    await transactionService.createTransaction({
      userId: user.userId,
      name: `Payment for ${split.name} - ${participant.name}`,
      type: 'income',
      amount: participant.amount,
    });
  }));

  await prisma.participant.updateMany({
    where: { splitId },
    data: { amount: 0 },
  });

  return { message: 'Payments recorded and all participants updated' };
}

module.exports = {
  createSplit,
  paidByAll,
  paidByOne
};
