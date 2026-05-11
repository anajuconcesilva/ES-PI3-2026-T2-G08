import { onCall } from "firebase-functions/v2/https";

import { requireAuthenticatedUser } from "../shared/auth";

import {
  getWalletByUserId,
  updateWallet,
} from "../repositories/walletRepository";

export const sellToken = onCall(async (request) => {

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
    throw new Error("Carteira não encontrada");
  }

  const investment = wallet.investments[startupId];

  if (!investment) {
    throw new Error("Investimento não encontrado");
  }

  if (investment.quantity < quantity) {
    throw new Error("Tokens insuficientes");
  }

  investment.quantity -= quantity;

  wallet.balance += total;

  if (investment.quantity === 0) {
    delete wallet.investments[startupId];
  }

  await updateWallet(user.uid, wallet);

  return {
    success: true,
    wallet,
  };
});