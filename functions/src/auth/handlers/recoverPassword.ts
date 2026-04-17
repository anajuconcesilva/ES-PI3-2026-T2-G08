import {onCall, HttpsError} from "firebase-functions/https";
import bcrypt from "bcryptjs";

import {findUserByEmail, updateUserPassword} from "../repositories/userRepository";
import {normalizeString} from "../shared/validation";
import {transporter} from "../shared/email";

export const recoverPassword = onCall(async (request) => {
  const email = normalizeString(request.data?.email);

  if (!email) {
    throw new HttpsError("invalid-argument", "Informe o email.");
  }

  const user = await findUserByEmail(email);

  if (!user) {
    throw new HttpsError("not-found", "Usuário não encontrado.");
  }

  const novaSenha = Math.random().toString(36).slice(-8);

  const hash = await bcrypt.hash(novaSenha, 10);

  await updateUserPassword(user.id, hash);

  // envio de email
  await transporter.sendMail({
    from: '"MesclaInvest" <n8365989@gmail.com>',
    to: email,
    subject: "Recuperação de senha",
    text: `Sua nova senha é: ${novaSenha}`,
  });

  return {
    data: {
      message: "Senha redefinida e enviada por email.",
    },
  };
});