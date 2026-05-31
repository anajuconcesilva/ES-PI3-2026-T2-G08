/**
 * Código feito por Felipe Lima Miranda
 * RA: 25023932
 */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { allowedStages } from "../shared/constants";
import { requireAuthenticatedUser } from "../shared/auth";
import { normalizeString } from "../shared/validation";
import { listStartupItems } from "../repositories/startupRepository";
import { StartupStage } from "../types";

/**
  * Lista as startups cadastradas no catálogo do MesclaInvest.
  *
  * Esta Firebase Function é callable porque será consumida diretamente pelo app mobile.
  * O app pode enviar, em 'data', os campos:
  *
  * - 'stage': filtro opcional por estágio.
  * - 'search': texto opcional para buscar no catálogo.
  *
  * A função exige usuário autenticado e retorna um objeto com:
  *
  * - 'count': quantidade de startups retornadas.
  * - 'filters': filtros aplicados e estágios disponíveis.
  * - 'data': lista resumida de startups para uso em telas de catálogo.
  */
export const listStartups = onCall(async (request) => {
  requireAuthenticatedUser(request);

  const stage = normalizeString(request.data?.stage);

  const search = normalizeString(request.data?.search)
    ?.toLocaleLowerCase("pt-BR");

  if (stage && !allowedStages.includes(stage as StartupStage)) {
    throw new HttpsError(
      "invalid-argument",
      "Filtro stage inválido. Use nova, em_operacao ou em_expansao."
    );
  }

  const startups = (await listStartupItems())
    .filter((startup) => !stage || startup.stage === stage)
    .filter((startup) => {
      if (!search) {
        return true;
      }

      const searchable = [
        startup.name,
        startup.shortDescription,
        startup.stage,
        ...startup.tags,
      ].join(" ").toLocaleLowerCase("pt-BR");

      return searchable.includes(search);
    })
    .sort((left, right) => left.name.localeCompare(right.name, "pt-BR"));

  return {
    count: startups.length,
    filters: {
      availableStages: allowedStages,
      stage: stage ?? null,
      search: search ?? null,
    },
    data: startups,
  };
});