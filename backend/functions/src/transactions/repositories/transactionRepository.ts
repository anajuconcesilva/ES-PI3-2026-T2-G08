import { db } from "../shared/firebase";

import { Transaction } from "../types/transaction";

export const createTransaction = async (
  transaction: Transaction
) => {

  await db
    .collection("transactions")
    .add(transaction);
};

export const getTransactionsByUserId = async (
  userId: string
) => {

  const snapshot = await db
    .collection("transactions")
    .where("userId", "==", userId)
    //.orderBy("createdAt", "desc")
    .get();

  return snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  }));
};