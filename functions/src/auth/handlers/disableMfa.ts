import { onCall, HttpsError } from "firebase-functions/https";
import { db } from "../shared/firebase";

export const disableMfa = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  const uid = request.auth.uid;

  const userRef = db.collection("users").doc(uid);
  const userDoc = await userRef.get();

  if (!userDoc.exists) {
    throw new HttpsError("not-found", "Usuário não encontrado");
  }

  await userRef.set(
    {
      mfaEnabled: false,
      mfaCode: null,
      mfaExpiresAt: null,
      mfaVerified: false,
      mfaVerifiedAt: null,
    },
    { merge: true }
  );

  return {
    data: {
      message: "MFA desativado com sucesso",
    },
  };
});