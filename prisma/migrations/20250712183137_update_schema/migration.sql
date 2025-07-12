/*
  Warnings:

  - Added the required column `round` to the `Invitation` table without a default value. This is not possible if the table is not empty.
  - Added the required column `round` to the `Participants` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Invitation" ADD COLUMN     "round" INTEGER NOT NULL;

-- AlterTable
ALTER TABLE "Participants" ADD COLUMN     "round" INTEGER NOT NULL;
