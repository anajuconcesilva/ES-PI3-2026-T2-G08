// Código feito por Laura Cristine Soares
// RA: 24802431

import { getFirestore } from "firebase-admin/firestore";

import { Offer } from "../types/trading";

function getDb() {
  return getFirestore();
}

export async function createOffer(
  offer: Offer
): Promise<Offer> {

  const docRef = await getDb()
    .collection("offers")
    .add(offer);

  return {
    id: docRef.id,
    ...offer,
  };
}

export async function listOpenOffers(): Promise<Offer[]> {

  const snapshot = await getDb()
    .collection("offers")
    .where("status", "==", "OPEN")
    .get();

  return snapshot.docs.map((doc) => ({
    id: doc.id,
    ...(doc.data() as Omit<Offer, "id">),
  }));
}

export async function getOfferById(
  offerId: string
): Promise<Offer | null> {

  const doc = await getDb()
    .collection("offers")
    .doc(offerId)
    .get();

  if (!doc.exists) {
    return null;
  }

  return {
    id: doc.id,
    ...(doc.data() as Omit<Offer, "id">),
  };
}

export async function updateOffer(
  offerId: string,
  data: Partial<Offer>
): Promise<void> {

  await getDb()
    .collection("offers")
    .doc(offerId)
    .update(data);
}