import { onCall, HttpsError } from "firebase-functions/v2/https";

import { requireAuthenticatedUser } from "../../wallet/shared/auth";

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

  const { offerId } = request.data;

  if (!offerId) {
    throw new HttpsError("invalid-argument", "Oferta inválida");
  }

  const offer = await getOfferById(offerId);

  if (!offer) {
    throw new HttpsError("not-found", "Oferta não encontrada");
  }

  if (offer.status !== "OPEN") {
    throw new HttpsError("failed-precondition", "Oferta já executada");
  }

  if (offer.userId === user.uid) {
    throw new HttpsError("permission-denied", "Não pode executar sua própria oferta");
  }

  const sellerId = offer.type === "SELL" ? offer.userId : user.uid;
  const buyerId = offer.type === "SELL" ? user.uid : offer.userId;

  const sellerWallet = await getWalletByUserId(sellerId);
  const buyerWallet = await getWalletByUserId(buyerId);

  if (!sellerWallet || !buyerWallet) {
    throw new HttpsError("not-found", "Carteira não encontrada");
  }

  const total = offer.quantity * offer.tokenPrice;

  if (buyerWallet.balance < total) {
    throw new HttpsError("failed-precondition", "Saldo insuficiente");
  }

  const sellerInvestment = sellerWallet.investments[offer.startupId];

  if (!sellerInvestment || sellerInvestment.quantity < offer.quantity) {
    throw new HttpsError("failed-precondition", "Tokens insuficientes");
  }

  buyerWallet.balance -= total;
  sellerWallet.balance += total;

  sellerInvestment.quantity -= offer.quantity;

  const buyerInvestment = buyerWallet.investments[offer.startupId];

  if (buyerInvestment) {
    buyerInvestment.quantity += offer.quantity;
    buyerInvestment.investedValue += total;
  } else {
    buyerWallet.investments[offer.startupId] = {
      quantity: offer.quantity,
      investedValue: total,
    };
  }

  if (sellerInvestment.quantity === 0) {
    delete sellerWallet.investments[offer.startupId];
  }

  await updateWallet(sellerId, sellerWallet);
  await updateWallet(buyerId, buyerWallet);

  await updateOffer(offerId, { status: "EXECUTED" });

  return {
    success: true,
  };
});