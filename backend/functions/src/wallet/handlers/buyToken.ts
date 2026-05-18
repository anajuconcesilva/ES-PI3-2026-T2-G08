import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";

import { requireAuthenticatedUser } from "../shared/auth";

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

  await createTransaction({
    userId: user.uid,
    type: "buy",
    startupId,
    quantity,
    amount: total,
    createdAt: new Date(),
  });

  return {
    success: true,
    message: "Compra realizada com sucesso",
    wallet,
  };
});