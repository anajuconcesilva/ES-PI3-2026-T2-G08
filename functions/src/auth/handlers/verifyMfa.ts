import { onCall, HttpsError } from "firebase-functions/https";
import { db } from "../shared/firebase";

export const verifyMfa = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  const uid = request.auth.uid;
  const code = request.data?.code;

  if (!code) {
    throw new HttpsError("invalid-argument", "Informe o código MFA");
  }

  const userDoc = await db.collection("users").doc(uid).get();

  if (!userDoc.exists) {
    throw new HttpsError("not-found", "Usuário não encontrado");
  }

  const userData = userDoc.data();

  if (!userData?.mfaEnabled) {
    throw new HttpsError("failed-precondition", "MFA não está ativado");
  }

  if (!userData?.mfaCode || !userData?.mfaExpiresAt) {
    throw new HttpsError("failed-precondition", "Nenhum código MFA foi gerado");
  }

  if (Date.now() > userData.mfaExpiresAt) {
    throw new HttpsError("deadline-exceeded", "Código MFA expirado");
  }

  if (code !== userData.mfaCode) {
    throw new HttpsError("permission-denied", "Código MFA inválido");
  }

  await db.collection("users").doc(uid).set(
    {
      mfaVerified: true,
      mfaVerifiedAt: Date.now(),
      mfaCode: null,
      mfaExpiresAt: null,
    },
    { merge: true }
  );

  return {
    data: {
      message: "MFA validado com sucesso",
      verified: true,
    },
  };
});