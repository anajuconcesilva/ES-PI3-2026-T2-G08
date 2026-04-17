import {onCall, HttpsError} from "firebase-functions/https";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

import {findUserByEmail} from "../repositories/userRepository";
import {normalizeString} from "../shared/validation";

const SECRET = "mescla_secret";

export const login = onCall(async (request) => {
  const email = normalizeString(request.data?.email);
  const senha = normalizeString(request.data?.senha);

  if (!email || !senha) {
    throw new HttpsError("invalid-argument", "Informe email e senha.");
  }

  const user = await findUserByEmail(email);

  if (!user) {
    throw new HttpsError("not-found", "Usuário não encontrado.");
  }

  const senhaValida = await bcrypt.compare(senha, user.senha);

  if (!senhaValida) {
    throw new HttpsError("permission-denied", "Senha inválida.");
  }

  const token = jwt.sign(
    { uid: user.id, email: user.email },
    SECRET,
    { expiresIn: "1d" }
  );

  return {
    data: {
      token,
      user: {
        id: user.id,
        nome: user.nome,
        email: user.email,
      },
    },
  };
});