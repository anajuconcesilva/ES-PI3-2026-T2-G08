import {db} from "../shared/firebase";
import {UserDocument} from "../types";

const usersCollection = db.collection("users");

export async function findUserByEmail(email: string): Promise<{id: string} & UserDocument | null> {
  const snapshot = await usersCollection
    .where("email", "==", email)
    .limit(1)
    .get();

  if (snapshot.empty) return null;

  const doc = snapshot.docs[0];

  return {
    id: doc.id,
    ...(doc.data() as UserDocument),
  };
}