import { onCall, HttpsError } from "firebase-functions/v2/https";

import { requireAuthenticatedUser } from "../../wallet/shared/auth";
import { createOffer as createOfferRepository } from "../repositories/tradingRepository";
import { getWalletByUserId } from "../../wallet/repositories/walletRepository";

export const createOffer = onCall(async (request) => {

  const user = requireAuthenticatedUser(request);

  const { startupId, type, quantity, tokenPrice } = request.data;

  if (!startupId || !type || quantity <= 0 || tokenPrice <= 0) {
    throw new HttpsError("invalid-argument", "Dados inválidos");
  }

  const wallet = await getWalletByUserId(user.uid);

  if (!wallet) {
    throw new HttpsError("not-found", "Carteira não encontrada");
  }

  const total = quantity * tokenPrice;

  if (type === "BUY" && wallet.balance < total) {
    throw new HttpsError("failed-precondition", "Saldo insuficiente");
  }

  if (type === "SELL") {

    const investment = wallet.investments[startupId];

    if (!investment) {
      throw new HttpsError("failed-precondition", "Tokens não encontrados");
    }

    if (investment.quantity < quantity) {
      throw new HttpsError("failed-precondition", "Quantidade insuficiente de tokens");
    }
  }

  const offer = await createOfferRepository({
    userId: user.uid,
    startupId,
    type,
    quantity,
    tokenPrice,
    status: "OPEN",
    createdAt: Date.now(),
  });

  return {
    success: true,
    offer,
  };
});