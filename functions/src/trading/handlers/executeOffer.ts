import { onCall } from "firebase-functions/v2/https";

import { requireAuthenticatedUser }
from "../../wallet/shared/auth";

import {
  getOfferById,
  updateOffer,
} from "../repositories/tradingRepository";

import {
  getWalletByUserId,
  updateWallet,
} from "../../wallet/repositories/walletRepository";

export const executeOffer = onCall(async (request) => {

  const user = requireAuthenticatedUser(request);

  const data = request.data as any;

  const { offerId } = data;

  if (!offerId) {
    throw new Error("Oferta inválida");
  }

  const offer = await getOfferById(offerId);

  if (!offer) {
    throw new Error("Oferta não encontrada");
  }

  if (offer.status !== "OPEN") {
    throw new Error("Oferta já executada");
  }

  if (offer.userId === user.uid) {
    throw new Error("Não é possível executar sua própria oferta");
  }

  const sellerId =
    offer.type === "SELL"
      ? offer.userId
      : user.uid;

  const buyerId =
    offer.type === "SELL"
      ? user.uid
      : offer.userId;

  const sellerWallet =
    await getWalletByUserId(sellerId);

  const buyerWallet =
    await getWalletByUserId(buyerId);

  if (!sellerWallet || !buyerWallet) {
    throw new Error("Carteira não encontrada");
  }

  const total =
    offer.quantity * offer.tokenPrice;

  // Verifica saldo comprador
  if (buyerWallet.balance < total) {
    throw new Error("Saldo insuficiente");
  }

  const sellerInvestment =
    sellerWallet.investments[offer.startupId];

  // Verifica tokens vendedor
  if (
    !sellerInvestment ||
    sellerInvestment.quantity < offer.quantity
  ) {
    throw new Error("Tokens insuficientes");
  }

  // Remove saldo comprador
  buyerWallet.balance -= total;

  // Adiciona saldo vendedor
  sellerWallet.balance += total;

  // Remove tokens vendedor
  sellerInvestment.quantity -= offer.quantity;

  // Adiciona tokens comprador
  const buyerInvestment =
    buyerWallet.investments[offer.startupId];

  if (buyerInvestment) {

    buyerInvestment.quantity += offer.quantity;

    buyerInvestment.investedValue += total;

  } else {

    buyerWallet.investments[offer.startupId] = {
      quantity: offer.quantity,
      investedValue: total,
    };
  }

  // Remove startup se zerar tokens
  if (sellerInvestment.quantity === 0) {
    delete sellerWallet.investments[offer.startupId];
  }

  await updateWallet(
    sellerId,
    sellerWallet
  );

  await updateWallet(
    buyerId,
    buyerWallet
  );

  await updateOffer(
    offerId,
    {
      status: "EXECUTED",
    }
  );

  return {
    success: true,
  };
});