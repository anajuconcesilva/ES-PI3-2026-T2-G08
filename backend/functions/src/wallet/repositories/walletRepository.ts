// Código feito por Laura Cristine Soares
// RA: 24802431

import {
  getFirestore,
  FieldValue,
} from "firebase-admin/firestore";

import { Wallet } from "../types/wallet";

function getDb() {
  return getFirestore();
}

export async function getWalletByUserId(
  userId: string
): Promise<Wallet | null> {

  const doc = await getDb()
    .collection("users")
    .doc(userId)
    .get();

  if (!doc.exists) {
    return null;
  }

  const data = doc.data();

  return data?.wallet || {
    balance: 0,
    investments: {},
  };
}

export async function updateWallet(
  userId: string,
  wallet: Wallet
) {

  await getDb()
    .collection("users")
    .doc(userId)
    .set(
      {
        wallet,
      },
      { merge: true }
    );
}

export async function addBalance(
  userId: string,
  value: number
) {

  await getDb()
    .collection("users")
    .doc(userId)
    .update({
      "wallet.balance": FieldValue.increment(value),
    });
}
