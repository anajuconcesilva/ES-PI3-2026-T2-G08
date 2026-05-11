/**
 * Código feito por Laura Cristine Soares, RA: 24802431
 *
 * ================================
 * VERIFY MFA - FIREBASE FUNCTION
 * ================================
 *
 * Responsável por validar o código de autenticação multifator (MFA).
 *
 * Fluxo:
 * 1. Verifica se o usuário está autenticado
 * 2. Valida se o código foi informado
 * 3. Busca os dados do usuário no Firestore
 * 4. Verifica se o MFA está ativado
 * 5. Verifica se existe código gerado
 * 6. Verifica se o código expirou
 * 7. Compara o código informado com o código salvo
 * 8. Marca o MFA como validado
 * 9. Limpa o código temporário após sucesso
 * 10. Retorna confirmação ao cliente
 *
 * Segurança:
 * - Apenas usuários autenticados podem validar MFA
 * - O código só pode ser usado antes da expiração
 * - O código é removido após validação bem-sucedida
 */

import { onCall, HttpsError } from "firebase-functions/https";
import { db } from "../shared/firebase";

/**
 * API responsável por validar o código MFA
 */
export const verifyMfa = onCall(async (request) => {
  // =========================
  // 1. VERIFICAR AUTENTICAÇÃO
  // =========================
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  const uid = request.auth.uid;
  const code = request.data?.code;

  // =========================
  // 2. VALIDAR CÓDIGO ENVIADO
  // =========================
  if (!code) {
    throw new HttpsError("invalid-argument", "Informe o código MFA");
  }

  // =========================
  // 3. BUSCAR USUÁRIO
  // =========================
  const userDoc = await db.collection("users").doc(uid).get();

  if (!userDoc.exists) {
    throw new HttpsError("not-found", "Usuário não encontrado");
  }

  const userData = userDoc.data();

  // =========================
  // 4. VERIFICAR MFA ATIVADO
  // =========================
  if (!userData?.mfaEnabled) {
    throw new HttpsError("failed-precondition", "MFA não está ativado");
  }

  // =========================
  // 5. VERIFICAR CÓDIGO GERADO
  // =========================
  if (!userData?.mfaCode || !userData?.mfaExpiresAt) {
    throw new HttpsError("failed-precondition", "Nenhum código MFA foi gerado");
  }

  // =========================
  // 6. VERIFICAR EXPIRAÇÃO
  // =========================
  if (Date.now() > userData.mfaExpiresAt) {
    throw new HttpsError("deadline-exceeded", "Código MFA expirado");
  }

  // =========================
  // 7. COMPARAR CÓDIGO
  // =========================
  if (code !== userData.mfaCode) {
    throw new HttpsError("permission-denied", "Código MFA inválido");
  }

  // =========================
  // 8. ATUALIZAR FIRESTORE
  // =========================
  await db.collection("users").doc(uid).set(
    {
      mfaVerified: true,
      mfaVerifiedAt: Date.now(),
      mfaCode: null,
      mfaExpiresAt: null,
    },
    { merge: true }
  );

  // =========================
  // 9. RETORNO
  // =========================
  return {
    data: {
      message: "MFA validado com sucesso",
      verified: true,
    },
  };
});