/**
 * Código feito por Laura Cristine Soares, RA: 24802431
 *
  * ================================
 * GET PROFILE - FIREBASE FUNCTION
 * ================================
 *
 * Responsável por consultar o perfil do usuário autenticado.
 */

import { onCall, HttpsError } from "firebase-functions/https";
import { findByAuthUid } from "../repositories/userRepository";

export const getProfile = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  const user = await findByAuthUid(request.auth.uid);

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
      saldo: user.saldo,
      mfaEnabled: user.mfaEnabled ?? false,
      mfaVerified: user.mfaVerified ?? false,
    },
  };
});