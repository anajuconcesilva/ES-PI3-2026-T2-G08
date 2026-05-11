import { onCall } from "firebase-functions/v2/https";

import { requireAuthenticatedUser } from "../shared/auth";

import { getWalletByUserId } from "../repositories/walletRepository";

export const getWallet = onCall(async (request) => {

  const user = requireAuthenticatedUser(request);

  let wallet = await getWalletByUserId(user.uid);

  if (!wallet) {
    wallet = {
      balance: 0,
      investments: {},
    };
  }

  return wallet;
});