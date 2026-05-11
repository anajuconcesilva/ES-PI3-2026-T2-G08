import { onCall } from "firebase-functions/v2/https";

import { requireAuthenticatedUser } from "../shared/auth";

import {
  getWalletByUserId,
  updateWallet,
} from "../repositories/walletRepository";

export const addBalance = onCall(async (request) => {

  const user = requireAuthenticatedUser(request);

  const { value } = request.data;

  if (!value || value <= 0) {
    throw new Error("Valor inválido");
  }

  let wallet = await getWalletByUserId(user.uid);

  if (!wallet) {
    wallet = {
      balance: 0,
      investments: {},
    };
  }

  wallet.balance += value;

  await updateWallet(user.uid, wallet);

  return {
    success: true,
    wallet,
  };
});