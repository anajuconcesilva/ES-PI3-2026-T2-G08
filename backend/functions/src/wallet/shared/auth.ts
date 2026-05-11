import { CallableRequest } from "firebase-functions/v2/https";

export function requireAuthenticatedUser(request: CallableRequest) {
  if (!request.auth) {
    throw new Error("Usuário não autenticado");
  }

  return request.auth;
}