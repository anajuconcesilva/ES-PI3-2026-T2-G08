//Código feito por Lucas David de Sousa
//RA: 25895152

import { getFirestore } from "firebase-admin/firestore";

import {
  StartupDocument,
} from "../../startups/types/index";

const db = getFirestore();

export async function getStartupTransactions(
  startupId: string,
  startDate: Date
) {

  const snapshot = await db
    .collection("transactions")
    .where("startupId", "==", startupId)
    .where("type", "in", ["buy", "sell"])
    .where("createdAt", ">=", startDate)
    .orderBy("createdAt", "asc")
    .get();

  return snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  }));
}

export const getStartupById = async (
  startupId: string
): Promise<(StartupDocument & { id: string }) | null> => {

  const startupDoc =
    await db
      .collection("startups")
      .doc(startupId)
      .get();

  if (!startupDoc.exists) {
    return null;
  }

  return {
    id: startupDoc.id,
    ...(startupDoc.data() as StartupDocument),
  };
};