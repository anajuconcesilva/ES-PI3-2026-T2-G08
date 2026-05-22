import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";

import { FieldValue } from "firebase-admin/firestore";

import { requireAuthenticatedUser } from "../shared/auth";

import {
  createTransaction,
} from "../../transactions/repositories/transactionRepository";

import {
  getWalletByUserId,
  addBalance as addBalanceToWallet,
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

  // =====================
  // CONVERTER PARA CENTAVOS
  // =====================
  const valueInCents = Math.round(value * 100);

  // =====================
  // ATUALIZAR SALDO
  // =====================

  await addBalanceToWallet(
    user.uid,
    valueInCents
  );

  // =====================
  // PEGAR WALLET ATUALIZADA
  // =====================

  const wallet =
    await getWalletByUserId(user.uid);

  // =====================
  // CRIAR TRANSAÇÃO
  // =====================

  await createTransaction({
    userId: user.uid,
    type: "deposit",
    amount: valueInCents,
    createdAt: FieldValue.serverTimestamp(),
  });

  return {
    success: true,
    message: "Saldo adicionado com sucesso",
    wallet,
  };
});
