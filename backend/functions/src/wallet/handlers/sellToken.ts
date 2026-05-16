import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";

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

  investment.quantity -= quantity;

  wallet.balance += total;

  if (investment.quantity === 0) {
    delete wallet.investments[startupId];
  }

  await updateWallet(user.uid, wallet);

  return {
    success: true,
    message: "Venda realizada com sucesso",
    wallet,
  };
});