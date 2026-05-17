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