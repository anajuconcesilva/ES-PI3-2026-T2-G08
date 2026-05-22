import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";

import { Timestamp } from "firebase-admin/firestore";

import { db } from "../../startups/shared/firebase";

import { requireAuthenticatedUser } from "../shared/auth";

import {
  getStartupById,
} from "../../dashboard/repositories/dashboardRepository";

import {
  getWalletByUserId,
  updateWallet,
} from "../repositories/walletRepository";

import { createTransaction } from "../../transactions/repositories/transactionRepository";

export const buyToken = onCall(async (request) => {

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

  let wallet = await getWalletByUserId(user.uid);

  if (!wallet) {
    wallet = {
      balance: 0,
      investments: {},
    };
  }

  if (wallet.balance < total) {
    throw new HttpsError(
      "failed-precondition",
      "Saldo insuficiente"
    );
  }

  wallet.balance -= total;

  const investment =
    wallet.investments[startupId];

  if (investment) {

    investment.quantity += quantity;
    investment.investedValue += total;

  } else {

    wallet.investments[startupId] = {
      quantity,
      investedValue: total,
    };
  }

  await updateWallet(user.uid, wallet);

  await db
    .collection("startups")
    .doc(startupId)
    .collection("investors")
    .doc(user.uid)
    .set({
      uid: user.uid,
      investedAt: Timestamp.now(),
    }, { merge: true });

  const startup =
    await getStartupById(startupId);

  await createTransaction({
    userId: user.uid,
    type: "buy",
    startupId,
    startupName: startup?.name ?? "Startup",
    quantity,
    amount: total,
    createdAt: Timestamp.now(),
  });

  return {
    success: true,
    message: "Compra realizada com sucesso",
    wallet,
  };
});