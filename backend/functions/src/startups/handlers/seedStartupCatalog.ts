/**
 * Código feito por Lucas David de Sousa(disponibilizado pelo professor), RA: 25895152
 */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { seedDemoStartups } from "../repositories/startupRepository";

/**
 * Popula o catálogo com startups demonstrativas.
 */
export const seedStartupCatalog = onCall(async () => {
  try {
    const startupIds = await seedDemoStartups();

    return {
      data: {
        count: startupIds.length,
        ids: startupIds,
      },
    };
  } catch (error) {
    throw new HttpsError(
      "internal",
      "Erro ao popular startups"
    );
  }
});