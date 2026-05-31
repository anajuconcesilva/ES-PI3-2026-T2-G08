import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";

import { Timestamp } from "firebase-admin/firestore";

import { requireAuthenticatedUser } from "../shared/auth";

import { db } from "../../startups/shared/firebase";

import {
  getWalletByUserId,
  updateWallet,
} from "../repositories/walletRepository";

import {
  getStartupById,
} from "../../dashboard/repositories/dashboardRepository";

import { createTransaction } from "../../transactions/repositories/transactionRepository";

export const sellToken = onCall(async (request) => {

  const user = requireAuthenticatedUser(request);

  const {
    startupId,
    quantity,
    tokenPrice,
  } = request.data;

  if (!startupId || typeof startupId !== "string") {
    throw new HttpsError(
      "invalid-argument",
      "Startup inválida"
    );
  }

  if (
    typeof quantity !== "number" ||
    quantity <= 0
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Quantidade inválida"
    );
  }

  if (
    typeof tokenPrice !== "number" ||
    tokenPrice <= 0
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Preço do token inválido"
    );
  }

  const total = quantity * tokenPrice;

  const wallet = await getWalletByUserId(user.uid);

  if (!wallet) {
    throw new HttpsError(
      "not-found",
      "Carteira não encontrada"
    );
  }

  const investment =
    wallet.investments[startupId];

  if (!investment) {
    throw new HttpsError(
      "not-found",
      "Investimento não encontrado"
    );
  }

  if (investment.quantity < quantity) {
    throw new HttpsError(
      "failed-precondition",
      "Tokens insuficientes"
    );
  }

  // Calcula custo médio dos tokens
  const averageCost =
    investment.investedValue /
    investment.quantity;

  // Remove do valor investido apenas
  // a parcela correspondente aos tokens vendidos
  investment.investedValue -=
    averageCost * quantity;

  investment.quantity -= quantity;

  wallet.balance += total;

  if (investment.quantity <= 0) {
    delete wallet.investments[startupId];

      await db
        .collection("startups")
        .doc(startupId)
        .collection("investors")
        .doc(user.uid)
        .delete();
  }

  await updateWallet(user.uid, wallet);

  const startup =
    await getStartupById(startupId);

  await createTransaction({
    userId: user.uid,
    type: "sell",
    startupId,
    startupName: startup?.name ?? "Startup",
    quantity,
    amount: total,
    createdAt: Timestamp.now(),
  });

  return {
    success: true,
    message: "Venda realizada com sucesso",
    wallet,
  };
});