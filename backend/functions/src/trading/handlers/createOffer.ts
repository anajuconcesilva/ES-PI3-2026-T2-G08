import { onCall } from "firebase-functions/v2/https";

import { requireAuthenticatedUser }
from "../../wallet/shared/auth";

import { createOffer as createOfferRepository }
from "../repositories/tradingRepository";

import { getWalletByUserId }
from "../../wallet/repositories/walletRepository";

export const createOffer = onCall(async (request) => {

  const user = requireAuthenticatedUser(request);

  const {
    startupId,
    type,
    quantity,
    tokenPrice,
  } = request.data;

  if (
    !startupId ||
    !type ||
    quantity <= 0 ||
    tokenPrice <= 0
  ) {
    throw new Error("Dados inválidos");
  }

  const wallet = await getWalletByUserId(user.uid);

  if (!wallet) {
    throw new Error("Carteira não encontrada");
  }

  const total = quantity * tokenPrice;

  // Oferta de compra
  if (type === "BUY") {

    if (wallet.balance < total) {
      throw new Error("Saldo insuficiente");
    }
  }

  // Oferta de venda
  if (type === "SELL") {

    const investment =
      wallet.investments[startupId];

    if (!investment) {
      throw new Error("Tokens não encontrados");
    }

    if (investment.quantity < quantity) {
      throw new Error("Quantidade insuficiente de tokens");
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