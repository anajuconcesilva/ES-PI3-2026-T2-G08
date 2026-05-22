import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";
import { requireAuthenticatedUser } from "../../wallet/shared/auth";
import { FieldValue } from "firebase-admin/firestore";

export const executeOffer = onCall(async (request) => {

  const user = requireAuthenticatedUser(request);

  const { offerId } = request.data;

  if (!offerId) {
    throw new HttpsError("invalid-argument", "Oferta inválida");
  }

  const db = getFirestore();

  return await db.runTransaction(async (transaction) => {
    const offerRef = db.collection("offers").doc(offerId);
    const offerSnap = await transaction.get(offerRef);

    if (!offerSnap.exists) {
      throw new HttpsError("not-found", "Oferta não encontrada");
    }

    const offer = offerSnap.data() as any;

    if (offer.status !== "OPEN") {
      throw new HttpsError("failed-precondition", "Esta oferta já foi executada por outro usuário");
    }

    if (offer.userId === user.uid) {
      throw new HttpsError("permission-denied", "Você não pode executar sua própria oferta");
    }

    // Define quem é quem
    const sellerId = offer.type === "SELL" ? offer.userId : user.uid;
    const buyerId = offer.type === "SELL" ? user.uid : offer.userId;

    const sellerRef = db.collection("users").doc(sellerId);
    const buyerRef = db.collection("users").doc(buyerId);

    const sellerDoc = await transaction.get(sellerRef);
    const buyerDoc = await transaction.get(buyerRef);

    if (!sellerDoc.exists || !buyerDoc.exists) {
      throw new HttpsError("not-found", "Carteira de um dos envolvidos não encontrada");
    }

    const sellerData = sellerDoc.data()!;
    const buyerData = buyerDoc.data()!;

    const sellerWallet = sellerData.wallet || { balance: 0, investments: {} };
    const buyerWallet = buyerData.wallet || { balance: 0, investments: {} };

    const total = offer.quantity * offer.tokenPrice;

    // Valida comprador
    if (buyerWallet.balance < total) {
      throw new HttpsError("failed-precondition", "O comprador não possui saldo suficiente");
    }

    // Valida vendedor (Suporte a formato antigo e novo)
    const investment = sellerWallet.investments[offer.startupId];
    if (!investment) {
      throw new HttpsError("failed-precondition", "O vendedor não possui os tokens");
    }

    const sellerQty = typeof investment === 'number' ? investment : investment.quantity;

    if (sellerQty < offer.quantity) {
      throw new HttpsError("failed-precondition", "O vendedor não possui tokens suficientes");
    }

    // --- ATUALIZAÇÃO ---

    // 1. Financeiro
    buyerWallet.balance -= total;
    sellerWallet.balance += total;

    // 2. Tokens Vendedor
    if (typeof investment === 'number') {
        const newQty = investment - offer.quantity;
        if (newQty === 0) delete sellerWallet.investments[offer.startupId];
        else sellerWallet.investments[offer.startupId] = { quantity: newQty, investedValue: 0 };
    } else {
        investment.quantity -= offer.quantity;
        if (investment.quantity === 0) delete sellerWallet.investments[offer.startupId];
    }

    // 3. Tokens Comprador
    const bInv = buyerWallet.investments[offer.startupId];
    if (bInv) {
        if (typeof bInv === 'number') {
            buyerWallet.investments[offer.startupId] = {
                quantity: bInv + offer.quantity,
                investedValue: total
            };
        } else {
            bInv.quantity += offer.quantity;
            bInv.investedValue += total;
        }
    } else {
        buyerWallet.investments[offer.startupId] = {
            quantity: offer.quantity,
            investedValue: total,
        };
    }

    const startupRef = db.collection("startups").doc(offer.startupId);

    // Gravações
    transaction.update(sellerRef, { wallet: sellerWallet });
    transaction.update(buyerRef, { wallet: buyerWallet });
    transaction.update(offerRef, {
      status: "EXECUTED",
      executedAt: FieldValue.serverTimestamp(),
      executedBy: user.uid
    });

    transaction.update(startupRef, {
      currentTokenPriceCents: offer.tokenPrice,
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Logs
    const logRef = db.collection("transactions");
    transaction.set(logRef.doc(), { userId: buyerId, type: "buy", startupId: offer.startupId, quantity: offer.quantity, amount: total, createdAt: FieldValue.serverTimestamp() });
    transaction.set(logRef.doc(), { userId: sellerId, type: "sell", startupId: offer.startupId, quantity: offer.quantity, amount: total, createdAt: FieldValue.serverTimestamp() });

    return { success: true };
  });
});
