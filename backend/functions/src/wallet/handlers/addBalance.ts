import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";

import { requireAuthenticatedUser } from "../shared/auth";

import {
  getWalletByUserId,
  updateWallet,
} from "../repositories/walletRepository";

export const addBalance = onCall(async (request) => {

  const user = requireAuthenticatedUser(request);

  const { value } = request.data;

  if (
    value === undefined ||
    value === null ||
    typeof value !== "number"
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Valor inválido"
    );
  }

  if (value <= 0) {
    throw new HttpsError(
      "invalid-argument",
      "O valor deve ser maior que zero"
    );
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
    message: "Saldo adicionado com sucesso",
    wallet,
  };
});