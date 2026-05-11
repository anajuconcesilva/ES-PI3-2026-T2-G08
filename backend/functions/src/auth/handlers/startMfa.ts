/**
 * Código feito por Laura Cristine Soares, RA: 24802431
 *
 * ================================
 * START MFA - FIREBASE FUNCTION
 * ================================
 *
 * Responsável por iniciar o fluxo de autenticação multifator (MFA).
 *
 * Fluxo:
 * 1. Verifica se o usuário está autenticado
 * 2. Gera um código numérico temporário de 6 dígitos
 * 3. Define tempo de expiração do código
 * 4. Salva os dados do MFA no Firestore
 * 5. Retorna mensagem de sucesso e o código gerado
 *
 * Segurança:
 * - Apenas usuários autenticados podem iniciar o MFA
 * - O código expira após 5 minutos
 * - Os dados são armazenados no documento do próprio usuário
 */

import { onCall, HttpsError } from "firebase-functions/https";
import { db } from "../shared/firebase";

/**
 * API responsável por gerar e iniciar o código MFA
 */
export const startMfa = onCall(async (request) => {
  // =========================
  // 1. VERIFICAR AUTENTICAÇÃO
  // =========================
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  const uid = request.auth.uid;

  // =========================
  // 2. GERAR CÓDIGO MFA
  // =========================
  const code = Math.floor(100000 + Math.random() * 900000).toString();

  // =========================
  // 3. DEFINIR EXPIRAÇÃO
  // =========================
  const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutos

  // =========================
  // 4. SALVAR NO FIRESTORE
  // =========================
  await db.collection("users").doc(uid).set(
    {
      mfaEnabled: true,
      mfaCode: code,
      mfaExpiresAt: expiresAt,
      mfaVerified: false,
      mfaVerifiedAt: null,
    },
    { merge: true }
  );

  // =========================
  // 5. RETORNO
  // =========================
  return {
    data: {
      message: "Código MFA gerado com sucesso",
      code,
    },
  };
});