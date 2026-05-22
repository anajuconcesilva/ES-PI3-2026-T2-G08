import { onCall, HttpsError } from "firebase-functions/v2/https";
import { FieldValue } from "firebase-admin/firestore";
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

  // Validação de Saldo para COMPRA
  if (type === "BUY" && wallet.balance < total) {
    throw new HttpsError("failed-precondition", "Saldo insuficiente para criar esta oferta");
  }

  // Validação de Tokens para VENDA
  if (type === "SELL") {
    const investment = wallet.investments[startupId];

    if (!investment) {
      throw new HttpsError("failed-precondition", "Você não possui tokens desta startup para vender");
    }

    // Suporte a formato antigo (número) e novo (objeto)
    const currentQuantity = typeof investment === 'number' ? investment : investment.quantity;

    if (currentQuantity < quantity) {
      throw new HttpsError("failed-precondition", "Quantidade insuficiente de tokens na carteira");
    }
  }

  const offer = await createOfferRepository({
    userId: user.uid,
    startupId,
    type,
    quantity,
    tokenPrice,
    status: "OPEN",
    createdAt: FieldValue.serverTimestamp(),
  });

  return {
    success: true,
    offer,
  };
});
