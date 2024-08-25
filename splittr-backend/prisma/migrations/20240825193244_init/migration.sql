/*
  Warnings:

  - You are about to drop the column `userId` on the `Transaction` table. All the data in the column will be lost.
  - You are about to drop the column `cognitoId` on the `User` table. All the data in the column will be lost.
  - Added the required column `email` to the `Transaction` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "Transaction" DROP CONSTRAINT "Transaction_userId_fkey";

-- DropIndex
DROP INDEX "User_cognitoId_key";

-- AlterTable
ALTER TABLE "Transaction" DROP COLUMN "userId",
ADD COLUMN     "email" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "User" DROP COLUMN "cognitoId";

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_email_fkey" FOREIGN KEY ("email") REFERENCES "User"("email") ON DELETE RESTRICT ON UPDATE CASCADE;
