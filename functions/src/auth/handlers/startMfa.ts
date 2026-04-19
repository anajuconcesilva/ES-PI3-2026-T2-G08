import { onCall, HttpsError } from "firebase-functions/https";
import { db } from "../shared/firebase";

export const startMfa = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  const uid = request.auth.uid;

  const code = Math.floor(100000 + Math.random() * 900000).toString();

  const expiresAt = Date.now() + 5 * 60 * 1000; // 5 min

  await db.collection("users").doc(uid).set(
    {
      mfaEnabled: true,
      mfaCode: code,
      mfaExpiresAt: expiresAt,
    },
    { merge: true }
  );

  return {
    data: {
      message: "Código MFA gerado",
      code,
    },
  };
});