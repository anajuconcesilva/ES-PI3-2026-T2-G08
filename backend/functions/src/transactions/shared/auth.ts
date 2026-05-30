// Código feito por Lucas David de Sousa
// RA: 25895152

import {
  CallableRequest,
  HttpsError,
} from "firebase-functions/v2/https";

export function requireAuthenticatedUser(
  request: CallableRequest
) {

  if (!request.auth) {

    throw new HttpsError(
      "unauthenticated",
      "Usuário precisa estar autenticado."
    );
  }

  return request.auth;
}