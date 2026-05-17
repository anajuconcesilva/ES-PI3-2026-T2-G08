import {
  onCall,
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

  const transactions =
    await getTransactionsByUserId(user.uid);

  return {
    data: transactions,
  };
});