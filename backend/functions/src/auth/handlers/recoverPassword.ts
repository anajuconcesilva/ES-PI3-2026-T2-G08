import { onCall, HttpsError } from "firebase-functions/v2/https";
import { initializeApp } from "firebase/app";
import { getAuth, sendPasswordResetEmail } from "firebase/auth";

const app = initializeApp({
  apiKey: "AIzaSyCMuMlyYV1d4Hg6VFfR63c0pl_JUa1GsGo",
  authDomain: "mesclainvest-b2967.firebaseapp.com",
});

const auth = getAuth(app);

export const recoverPassword = onCall(async (request) => {
  const email = request.data?.email;

  if (!email) {
    throw new HttpsError("invalid-argument", "Informe o email");
  }

  try {
    await sendPasswordResetEmail(auth, email);

    return {
      data: {
        message: "Email de recuperação enviado",
      },
    };
  } catch (error) {
    throw new HttpsError("not-found", "Usuário não encontrado");
  }
});