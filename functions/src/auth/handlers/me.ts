import { onCall, HttpsError } from "firebase-functions/https";

export const me = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  return {
    data: {
      uid: request.auth.uid,
      email: request.auth.token.email,
    },
  };
});