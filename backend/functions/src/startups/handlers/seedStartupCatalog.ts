/**
 * Código feito por Lucas David de Sousa(disponibilizado pelo professor), RA: 25895152
 *
 */

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { seedDemoStartups } from "../repositories/startupRepository";
import { normalizeString} from "../shared/validation";

/**
  * Popula o catálogo com startups demonstrativas.
  *
  * Esta Function é callable para facilitar a execução pelo app ou pelo
  * emulador durante desenvolvimento. Em ambiente de emulator ele roda sem chave.
  * Fora do emulator, exige 'seedKey' em 'request.data.seedKey', comparando com a
  * variável de ambiente 'SEED_STARTUP_CATALOG_KEY'.
  *
  * A função retorna a quantidade de startups gravadas e os ids dos documentos.
  */
export const seedStartupCatalog = onCall(async (request) => {
  if (!process.env.FUNCTIONS_EMULATOR) {
    const seedKey = normalizeString(request.data?.seedKey);

    if (!process.env.SEED_STARTUP_CATALOG_KEY ||
      seedKey !== process.env.SEED_STARTUP_CATALOG_KEY) {
      throw new HttpsError(
        "permission-denied",
        "Seed bloqueado fora do emulator sem seedKey válido."
      );
    }
  }

  const startupIds = await seedDemoStartups();

  return {
    data: {
      count: startupIds.length,
      ids: startupIds,
    },
  };
});