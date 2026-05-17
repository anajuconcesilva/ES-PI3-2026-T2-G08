/**
 * Código feito por Laura Cristine Soares, RA: 24802431
 *
  * ================================
 * GET PROFILE - FIREBASE FUNCTION
 * ================================
 *
 * Responsável por consultar o perfil do usuário autenticado.
 */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getUserByAuthUid } from "../repositories/userRepository";

export const getProfile = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  const user = await getUserByAuthUid(request.auth.uid);

  if (!user) {
    throw new HttpsError("not-found", "Usuário não encontrado");
  }

  return {
    data: {
      id: user.id,
      nome: user.nome,
      email: user.email,
      cpf: user.cpf,
      telefone: user.telefone,
      wallet: user.wallet,
      mfaEnabled: user.mfaEnabled ?? false,
      mfaVerified: user.mfaVerified ?? false,
    },
  };
});