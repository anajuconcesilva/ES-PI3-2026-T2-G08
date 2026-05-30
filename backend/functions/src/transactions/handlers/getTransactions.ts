// Código feito por Lucas David de Sousa
// RA: 25895152

import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";

import {
  requireAuthenticatedUser,
} from "../shared/auth";

import {
  getTransactionsByUserId,
} from "../repositories/transactionRepository";

export const getTransactions =
onCall(async (request) => {

  const user =
    requireAuthenticatedUser(request);

  try {
    const transactions =
      await getTransactionsByUserId(
        user.uid
      );

    return {
      data: transactions,
    };

  } catch (error) {
    console.error(
      "Erro ao buscar transações:",
      error
    );

    throw new HttpsError(
      "internal",
      "Erro ao carregar histórico"
    );
  }
});