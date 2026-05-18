import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";

import { requireAuthenticatedUser } from "../shared/auth";

import {
  getWalletByUserId,
} from "../repositories/walletRepository";

export const getWallet = onCall(async (request) => {

  const user = requireAuthenticatedUser(request);

  const wallet =
    await getWalletByUserId(user.uid);

  if (!wallet) {
    throw new HttpsError(
      "not-found",
      "Carteira não encontrada"
    );
  }

  return {
    wallet,
  };
});
