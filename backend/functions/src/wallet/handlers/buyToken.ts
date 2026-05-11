import { onCall } from "firebase-functions/v2/https";

import { requireAuthenticatedUser } from "../shared/auth";

import {
  getWalletByUserId,
  updateWallet,
} from "../repositories/walletRepository";

export const buyToken = onCall(async (request) => {

  const user = requireAuthenticatedUser(request);

  const {
    startupId,
    quantity,
    tokenPrice,
  } = request.data;

  if (!startupId || quantity <= 0 || tokenPrice <= 0) {
    throw new Error("Dados inválidos");
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
    throw new Error("Saldo insuficiente");
  }

  wallet.balance -= total;

  const investment = wallet.investments[startupId];

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

  return {
    success: true,
    wallet,
  };
});