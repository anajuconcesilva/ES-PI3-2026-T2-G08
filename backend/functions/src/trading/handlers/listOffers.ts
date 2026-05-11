import { onCall } from "firebase-functions/v2/https";

import { listOpenOffers }
from "../repositories/tradingRepository";

export const listOffers = onCall(async () => {

  const offers = await listOpenOffers();

  return {
    offers,
  };
});
