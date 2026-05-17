/**
 * Código feito por Laura Cristine Soares, RA: 24802431
 *
 * ================================
 * DISABLE MFA - FIREBASE FUNCTION
 * ================================
 *
 * Responsável por desativar a autenticação multifator (MFA) do usuário.
 *
 * Fluxo:
 * 1. Verifica se o usuário está autenticado
 * 2. Busca o usuário no Firestore
 * 3. Desativa o MFA
 * 4. Remove código, expiração e validação anteriores
 * 5. Retorna mensagem de sucesso
 *
 * Segurança:
 * - Apenas usuários autenticados podem desativar o MFA
 * - O estado do MFA é limpo para evitar reutilização de dados antigos
 */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db } from "../shared/firebase";

/**
 * API responsável por desativar o MFA
 */
export const disableMfa = onCall(async (request) => {
  // =========================
  // 1. VERIFICAR AUTENTICAÇÃO
  // =========================
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  const uid = request.auth.uid;

  // =========================
  // 2. BUSCAR USUÁRIO
  // =========================
  const userRef = db.collection("users").doc(uid);
  const userDoc = await userRef.get();

  if (!userDoc.exists) {
    throw new HttpsError("not-found", "Usuário não encontrado");
  }

  // =========================
  // 3. DESATIVAR MFA
  // =========================
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

  // =========================
  // 4. RETORNO
  // =========================
  return {
    data: {
      message: "MFA desativado com sucesso",
    },
  };
});