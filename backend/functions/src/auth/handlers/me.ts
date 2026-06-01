/**
 * Código feito por Felipe Lima Miranda, RA: 25023932
 *
 * ================================
 * ME - FIREBASE FUNCTION
 * ================================
 *
 * Responsável por retornar os dados do usuário autenticado.
 *
 * Fluxo:
 * 1. Verifica se o usuário está autenticado
 * 2. Busca o documento do usuário no Firestore
 * 3. Retorna dados básicos do usuário
 * 4. Retorna também o status atual do MFA
 *
 * Objetivo:
 * - Permitir que o frontend saiba quem é o usuário autenticado
 * - Permitir que o frontend decida se deve exigir validação MFA
 *
 * Segurança:
 * - Apenas usuários autenticados podem acessar esta função
 * - O retorno é restrito aos dados do próprio usuário autenticado
 */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db } from "../shared/firebase";

/**
 * API responsável por retornar os dados do usuário autenticado
 */
export const me = onCall(async (request) => {
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
  const userDoc = await db.collection("users").doc(uid).get();

  if (!userDoc.exists) {
    throw new HttpsError("not-found", "Usuário não encontrado");
  }

  //const userData = userDoc.data();

  // =========================
  // 3. RETORNO
  // =========================
  return {
    data: {
      uid,
      email: request.auth.token.email,
    },
  };
});